--[[ PlayerManager: Handles DataStore persistence, player data, leaderstats, and auto-save ]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local Constants = require(game:GetService("ReplicatedStorage"):WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("Constants"))
local Types = require(game:GetService("ReplicatedStorage"):WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("Types"))
local StatCalculator = require(game:GetService("ReplicatedStorage"):WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("StatCalculator"))

local PlayerManager = {}
PlayerManager.PlayerData = {} -- [UserId] = profile table

local dataStore = DataStoreService:GetDataStore(Constants.DATASTORE_NAME)

--[[ Creates a default profile for new players ]]
function PlayerManager.CreateDefaultProfile()
	local profile = Types.PlayerProfile()

	-- Give starter monsters
	profile.inventory = {
		{
			name = "Slime",
			rarity = "Common",
			eps = 1,
			level = 1,
			xp = 0,
			shiny = false,
			id = "Common_Slime",
			uniqueId = "starter_1_" .. tick(),
		},
		{
			name = "Fluff Ball",
			rarity = "Common",
			eps = 1,
			level = 1,
			xp = 0,
			shiny = false,
			id = "Common_Fluff Ball",
			uniqueId = "starter_2_" .. tick(),
		},
	}

	profile.equipped = { profile.inventory[1].uniqueId, profile.inventory[2].uniqueId }
	profile.unlockedZones = { "zone1_forest" }

	return profile
end

--[[ Loads a player's data from DataStore ]]
function PlayerManager.LoadData(player)
	local userId = tostring(player.UserId)
	local success, data = pcall(function()
		return dataStore:GetAsync(Constants.DATASTORE_KEY_PREFIX .. userId)
	end)

	if success and data then
		-- Ensure all fields exist with defaults
		local profile = Types.PlayerProfile()
		profile.energy = data.energy or 0
		profile.essence = data.essence or 0
		profile.rank = data.rank or 0
		profile.inventory = data.inventory or {}
		profile.equipped = data.equipped or {}
		profile.unlockedZones = data.unlockedZones or { "zone1_forest" }
		profile.settings = data.settings or { mute = false, autoSave = true }
		profile.rebirthMultiplier = data.rebirthMultiplier or 1
		return profile
	else
		local profile = PlayerManager.CreateDefaultProfile()
		-- Save the initial profile
		PlayerManager.SaveData(player, profile)
		return profile
	end
end

--[[ Saves a player's data to DataStore ]]
function PlayerManager.SaveData(player, profile)
	local userId = tostring(player.UserId)
	local success, err = pcall(function()
		dataStore:SetAsync(Constants.DATASTORE_KEY_PREFIX .. userId, profile)
	end)

	if not success then
		warn(string.format("[PlayerManager] Failed to save data for %s: %s", player.Name, err))
	end

	return success
end

--[[ Updates leaderstats for a player ]]
function PlayerManager.UpdateLeaderstats(player, profile)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local energyVal = leaderstats:FindFirstChild("Energy")
	if not energyVal then
		energyVal = Instance.new("NumberValue")
		energyVal.Name = "Energy"
		energyVal.Parent = leaderstats
	end
	energyVal.Value = profile.energy

	local essenceVal = leaderstats:FindFirstChild("Essence")
	if not essenceVal then
		essenceVal = Instance.new("NumberValue")
		essenceVal.Name = "Essence"
		essenceVal.Parent = leaderstats
	end
	essenceVal.Value = profile.essence

	local rankVal = leaderstats:FindFirstChild("Rank")
	if not rankVal then
		rankVal = Instance.new("NumberValue")
		rankVal.Name = "Rank"
		rankVal.Parent = leaderstats
	end
	rankVal.Value = profile.rank
end

--[[ Adds energy to a player profile ]]
function PlayerManager.AddEnergy(player, amount)
	local profile = PlayerManager.PlayerData[player.UserId]
	if not profile then return end

	profile.energy += amount
	PlayerManager.UpdateLeaderstats(player, profile)
end

--[[ Adds essence to a player profile ]]
function PlayerManager.AddEssence(player, amount)
	local profile = PlayerManager.PlayerData[player.UserId]
	if not profile then return end

	profile.essence += amount
	PlayerManager.UpdateLeaderstats(player, profile)
end

--[[ Spends energy from a player profile. Returns true if successful. ]]
function PlayerManager.SpendEnergy(player, amount)
	local profile = PlayerManager.PlayerData[player.UserId]
	if not profile or profile.energy < amount then
		return false
	end

	profile.energy -= amount
	PlayerManager.UpdateLeaderstats(player, profile)
	return true
end

--[[ Spends essence from a player profile. Returns true if successful. ]]
function PlayerManager.SpendEssence(player, amount)
	local profile = PlayerManager.PlayerData[player.UserId]
	if not profile or profile.essence < amount then
		return false
	end

	profile.essence -= amount
	PlayerManager.UpdateLeaderstats(player, profile)
	return true
end

--[[ Checks if player can rebirth and does it ]]
function PlayerManager.TryRebirth(player, currentEPS)
	local profile = PlayerManager.PlayerData[player.UserId]
	if not profile then return false end

	local rebirthCost = Constants.BASE_REBIRTH_COST * (Constants.REBIRTH_COST_MULTIPLIER ^ profile.rank)
	if profile.essence < rebirthCost then
		return false
	end

	profile.essence = 0
	profile.rank += 1
	profile.rebirthMultiplier = Constants.REBIRTH_MULTIPLIER ^ profile.rank
	profile.inventory = {}
	profile.equipped = {}

	-- Give starter monsters again after rebirth
	local starter1 = {
		name = "Slime",
		rarity = "Common",
		eps = Constants.STARTER_MONSTER_EPS,
		level = 1,
		xp = 0,
		shiny = false,
		id = "Common_Slime",
		uniqueId = "starter_1_" .. tick(),
	}
	local starter2 = {
		name = "Fluff Ball",
		rarity = "Common",
		eps = Constants.STARTER_MONSTER_EPS,
		level = 1,
		xp = 0,
		shiny = false,
		id = "Common_Fluff Ball",
		uniqueId = "starter_2_" .. tick(),
	}
	profile.inventory = { starter1, starter2 }
	profile.equipped = { starter1.uniqueId, starter2.uniqueId }

	PlayerManager.UpdateLeaderstats(player, profile)
	return true
end

--[[ Auto-save all loaded player data ]]
function PlayerManager.AutoSaveAll()
	for userId, profile in pairs(PlayerManager.PlayerData) do
		local player = Players:GetPlayerByUserId(tonumber(userId))
		if player then
			PlayerManager.SaveData(player, profile)
		end
	end
end

--[[ Initializes player when they join ]]
function PlayerManager.OnPlayerAdded(player)
	-- Load data
	local profile = PlayerManager.LoadData(player)
	PlayerManager.PlayerData[player.UserId] = profile

	-- Setup leaderstats
	PlayerManager.UpdateLeaderstats(player, profile)

	-- Signal the UI to update
	local monsterMash = game:GetService("ReplicatedStorage"):FindFirstChild("MonsterMash")
	if monsterMash then
		local remoteEvents = monsterMash:FindFirstChild("RemoteEvents")
		if remoteEvents then
			local updateHud = remoteEvents:FindFirstChild("UpdateHUD")
			if updateHud then
				updateHud:FireClient(player, profile.energy, profile.essence, profile.rank, profile.rebirthMultiplier)
			end
		end
	end
end

--[[ Saves and cleans up player when they leave ]]
function PlayerManager.OnPlayerRemoving(player)
	local profile = PlayerManager.PlayerData[player.UserId]
	if profile then
		PlayerManager.SaveData(player, profile)
		PlayerManager.PlayerData[player.UserId] = nil
	end
end

return PlayerManager