--[[ MarketplaceHandler: Game Pass and Developer Product integration via MarketplaceService ]]

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("Constants"))
local Types = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("Types"))

local MarketplaceHandler = {}

-- Track ownership in player profile's .ownedPasses table

--[[ Process a Game Pass purchase (owner receives it automatically via Roblox) ]]
function MarketplaceHandler.OnPlayerPurchasedGamePass(player, gamePassId)
	local profile = require(script.Parent.PlayerManager).PlayerData[player.UserId]
	if not profile then return end

	local passId = tostring(gamePassId)

	-- Initialize ownedPasses table if needed
	if not profile.ownedPasses then
		profile.ownedPasses = {}
	end

	local passInfo = Constants.GAME_PASSES_BY_ID[passId]
	if not passInfo then
		warn(string.format("[MarketplaceHandler] Unknown game pass ID: %s", passId))
		return
	end

	profile.ownedPasses[passInfo.id] = true
	require(script.Parent.PlayerManager).SaveData(player, profile)

	print(string.format("[MarketplaceHandler] Player %s purchased game pass: %s", player.Name, passInfo.name))

	-- Send confirmation to client
	local remote = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("GamePassGranted")
	if remote then
		remote:FireClient(player, {
			passId = passInfo.id,
			passName = passInfo.name,
		})
	end
end

--[[ Process a Developer Product purchase ]]
function MarketplaceHandler.ProcessDeveloperProduct(player, productId)
	local profile = require(script.Parent.PlayerManager).PlayerData[player.UserId]
	if not profile then return Enum.ProductPurchaseDecision.NotProcessedYet end

	local prodInfo = Constants.DEV_PRODUCTS_BY_ID[tostring(productId)]
	if not prodInfo then
		warn(string.format("[MarketplaceHandler] Unknown dev product ID: %s", productId))
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Apply the product effect
	local success, message = MarketplaceHandler.ApplyDevProduct(player, prodInfo.id)

	return success and Enum.ProductPurchaseDecision.PurchaseGranted
		or Enum.ProductPurchaseDecision.NotProcessedYet
end

--[[ Apply a developer product effect to the player ]]
function MarketplaceHandler.ApplyDevProduct(player, productId)
	local profile = require(script.Parent.PlayerManager).PlayerData[player.UserId]
	if not profile then return false, "Profile not loaded" end

	local prodInfo = Constants.DEV_PRODUCTS[productId]
	if not prodInfo then return false, "Unknown product" end

	if prodInfo.type == "energy" then
		local amount = prodInfo.amount or 1000
		require(script.Parent.PlayerManager).AddEnergy(player, amount)
		return true, string.format("+%d Energy granted!", amount)

	elseif prodInfo.type == "boost_luck" then
		if not profile.boosts then profile.boosts = {} end
		profile.boosts.luckBoostEnds = os.time() + (15 * 60)
		require(script.Parent.PlayerManager).SaveData(player, profile)

		local remote = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("BoostActivated")
		if remote then
			remote:FireClient(player, {
				boostType = "luck",
				duration = 15 * 60,
			})
		end
		return true, "Lucky Egg Boost active for 15 minutes!"

	elseif prodInfo.type == "rare_egg" then
		local eggRarity = prodInfo.eggRarity or "Rare"
		if not profile.premiumEggs then profile.premiumEggs = {} end
		table.insert(profile.premiumEggs, eggRarity)
		require(script.Parent.PlayerManager).SaveData(player, profile)

		local remote = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("PremiumEggGranted")
		if remote then
			remote:FireClient(player, {
				eggRarity = eggRarity,
			})
		end
		return true, string.format("1x %s Egg added to your inventory!", eggRarity)
	end

	return false, "Unknown product type"
end

--[[ Check if player owns a specific game pass ]]
function MarketplaceHandler.HasGamePass(player, passId)
	local profile = require(script.Parent.PlayerManager).PlayerData[player.UserId]
	if not profile or not profile.ownedPasses then return false end
	return profile.ownedPasses[passId] == true
end

--[[ Get the effective max equipped monsters for this player (base + pass bonus) ]]
function MarketplaceHandler.GetMaxEquippedSlots(player)
	local base = Constants.MAX_EQUIPPED_MONSTERS -- 4
	if MarketplaceHandler.HasGamePass(player, "extra_equip") then
		return base + 2
	end
	return base
end

--[[ Get the player's energy multiplier (base + pass bonus) ]]
function MarketplaceHandler.GetEnergyMultiplier(player)
	local mult = 1
	if MarketplaceHandler.HasGamePass(player, "double_energy") then
		mult = mult * 2
	end
	return mult
end

--[[ Get the player's essence multiplier (base + pass bonus) ]]
function MarketplaceHandler.GetEssenceMultiplier(player)
	local mult = 1
	if MarketplaceHandler.HasGamePass(player, "vip") then
		mult = mult * 1.5
	end
	return mult
end

--[[ Check if player has auto-hatch ]]
function MarketplaceHandler.HasAutoHatch(player)
	return MarketplaceHandler.HasGamePass(player, "auto_hatch")
end

--[[ Check if player is VIP (for name tag / exclusive monster) ]]
function MarketplaceHandler.IsVIP(player)
	return MarketplaceHandler.HasGamePass(player, "vip")
end

--[[ Grant the VIP Slime monster to a player (one-time) ]]
function MarketplaceHandler.GrantVIPMonster(player)
	local profile = require(script.Parent.PlayerManager).PlayerData[player.UserId]
	if not profile then return false end

	if profile._vipMonsterGranted then return false end

	local vipMonster = {
		name = "VIP Slime",
		rarity = "Epic",
		eps = 8,
		level = 1,
		xp = 0,
		shiny = false,
		id = "Epic_VIP Slime",
		uniqueId = "vip_slime_" .. tick(),
	}
	table.insert(profile.inventory, vipMonster)
	profile._vipMonsterGranted = true
	require(script.Parent.PlayerManager).SaveData(player, profile)

	return true
end

--[[ Auto-hatch timer logic (for Auto-Hatch game pass owners) ]]
local autoHatchTimers = {}

function MarketplaceHandler.TryAutoHatch(player)
	if not MarketplaceHandler.HasAutoHatch(player) then return end

	local userId = player.UserId
	local now = os.clock()
	local lastHatch = autoHatchTimers[userId] or 0

	if now - lastHatch < 10 then return end
	autoHatchTimers[userId] = now

	local profile = require(script.Parent.PlayerManager).PlayerData[userId]
	if not profile then return end

	if profile.energy >= Constants.COMMON_EGG_COST then
		local monsterManager = require(script.Parent.MonsterManager)
		local monster, err = monsterManager.HatchEgg(player, "Common", "zone1_forest")
		if monster then
			local remote = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("MonsterHatched")
			if remote then
				remote:FireClient(player, monster)
			end
		end
	end
end

return MarketplaceHandler