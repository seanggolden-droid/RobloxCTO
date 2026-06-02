--[[ AdsManager: Rewarded video ad integration using Roblox's AdService ]]
-- Shared module - runs on server, with client-facing functions

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(script.Parent.Constants)

local AdsManager = {}

-- Ad types and their rewards
AdsManager.AD_TYPES = {
	double_energy_boost = {
		id = "double_energy_boost",
		name = "2x Energy Boost",
		description = "Double energy collection for 5 minutes",
		duration = 300, -- 5 minutes in seconds
		rewardType = "boost_energy",
	},
	free_lucky_egg = {
		id = "free_lucky_egg",
		name = "Free Lucky Egg",
		description = "Get a free Rare Egg",
		rewardType = "egg",
		eggRarity = "Rare",
	},
	instant_energy_500 = {
		id = "instant_energy_500",
		name = "Instant Energy",
		description = "Get 500 Energy instantly",
		rewardType = "energy",
		amount = 500,
	},
}

-- Active ad boosts per player
local activeBoosts = {} -- [UserId] = { boostType = string, expiresAt = number }

--[[ Check if AdService is available ]]
function AdsManager.IsAdServiceAvailable()
	local success, result = pcall(function()
		return game:GetService("AdService")
	end)
	return success
end

--[[ Play a rewarded ad for the player
	@param player Player
	@param adType string — one of the keys in AD_TYPES
	@return boolean success
]]
function AdsManager.PlayRewardedAd(player, adType)
	local adConfig = AdsManager.AD_TYPES[adType]
	if not adConfig then
		warn(string.format("[AdsManager] Unknown ad type: %s", adType))
		return false
	end

	-- Check AdService availability
	local adService = game:GetService("AdService")
	if not adService then
		warn("[AdsManager] AdService not available")
		return false
	end

	-- Request rewarded video ad
	local success, result = pcall(function()
		return adService:ShowRewardedVideoAd(player.UserId, adType)
	end)

	if success then
		print(string.format("[AdsManager] Ad shown to player %s for %s", player.Name, adType))
		return true
	else
		warn(string.format("[AdsManager] Failed to show ad: %s", tostring(result)))
		return false
	end
end

--[[ Called when an ad is completed and reward should be granted ]]
function AdsManager.OnAdRewarded(player, adType)
	local adConfig = AdsManager.AD_TYPES[adType]
	if not adConfig then return end

	local profile = require(game:GetService("ServerScriptService"):FindFirstChild("MonsterMashServer"):FindFirstChild("PlayerManager")).PlayerData[player.UserId]
	if not profile then return end

	local playerManager = require(game:GetService("ServerScriptService"):FindFirstChild("MonsterMashServer"):FindFirstChild("PlayerManager"))

	if adConfig.rewardType == "energy" then
		local amount = adConfig.amount or 500
		playerManager.AddEnergy(player, amount)
		playerManager.SaveData(player, profile)

		-- Notify client
		local remote = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("EnergyCollected")
		if remote then
			remote:FireClient(player, profile.energy, profile.essence)
		end

	elseif adConfig.rewardType == "boost_energy" then
		-- 2x Energy collection boost for duration
		if not profile.boosts then profile.boosts = {} end
		profile.boosts.energyBoostEnds = os.time() + adConfig.duration
		playerManager.SaveData(player, profile)

		local remote = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("BoostActivated")
		if remote then
			remote:FireClient(player, {
				boostType = "energy",
				duration = adConfig.duration,
				multiplier = 2,
			})
		end

	elseif adConfig.rewardType == "egg" then
		-- Free egg
		local eggRarity = adConfig.eggRarity or "Rare"
		if not profile.premiumEggs then profile.premiumEggs = {} end
		table.insert(profile.premiumEggs, eggRarity)
		playerManager.SaveData(player, profile)

		local remote = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("PremiumEggGranted")
		if remote then
			remote:FireClient(player, {
				eggRarity = eggRarity,
				source = "ad",
			})
		end
	end
end

--[[ Check if a player has an active energy boost ]]
function AdsManager.GetActiveEnergyMultiplier(player)
	local profile = require(game:GetService("ServerScriptService"):FindFirstChild("MonsterMashServer"):FindFirstChild("PlayerManager")).PlayerData[player.UserId]
	if not profile or not profile.boosts then return 1 end

	if profile.boosts.energyBoostEnds and profile.boosts.energyBoostEnds > os.time() then
		return 2
	end

	return 1
end

--[[ Cleanup expired boosts ]]
function AdsManager.CleanupExpiredBoosts()
	for userId, boost in pairs(activeBoosts) do
		if os.clock() >= boost.expiresAt then
			activeBoosts[userId] = nil
		end
	end
end

--[[ Get available ad types for a player ]]
function AdsManager.GetAvailableAds(player)
	local ads = {}
	for adId, adConfig in pairs(AdsManager.AD_TYPES) do
		table.insert(ads, {
			id = adId,
			name = adConfig.name,
			description = adConfig.description,
		})
	end
	return ads
end

return AdsManager