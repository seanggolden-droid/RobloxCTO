--[[ WorldManager: Handles zone unlocking, teleportation, and zone-based logic ]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local Constants = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("Constants"))
local Types = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("Types"))

local WorldManager = {}

--[[ Returns zone data for a given zone ID ]]
function WorldManager.GetZoneData(zoneId)
	for _, zone in ipairs(Constants.ZONES) do
		if zone.id == zoneId then
			return zone
		end
	end
	return nil
end

--[[ Checks if a player has a zone unlocked ]]
function WorldManager.IsZoneUnlocked(player, zoneId)
	local playerManager = require(script.Parent.PlayerManager)
	local profile = playerManager.PlayerData[player.UserId]
	if not profile then return false end

	for _, unlockedId in ipairs(profile.unlockedZones) do
		if unlockedId == zoneId then
			return true
		end
	end

	return false
end

--[[ Attempt to unlock a zone ]]
function WorldManager.UnlockZone(player, zoneId)
	local playerManager = require(script.Parent.PlayerManager)
	local profile = playerManager.PlayerData[player.UserId]
	if not profile then return false, "Profile not found." end

	-- Check if already unlocked
	if WorldManager.IsZoneUnlocked(player, zoneId) then
		return false, "Zone already unlocked!"
	end

	local zoneData = WorldManager.GetZoneData(zoneId)
	if not zoneData then
		return false, "Zone not found."
	end

	-- Check if previous zone is unlocked (linear progression)
	local prevUnlocked = false
	for _, zone in ipairs(Constants.ZONES) do
		if zone.id == zoneId then
			break
		end
		if WorldManager.IsZoneUnlocked(player, zone.id) then
			prevUnlocked = true
		end
	end

	-- First zone is free
	if zoneId == "zone1_forest" then
		return false, "Zone already unlocked."
	end

	-- Check the prerequisite zone is unlocked
	local foundCurrent = false
	for _, zone in ipairs(Constants.ZONES) do
		if zone.id == zoneId then
			foundCurrent = true
			break
		end
		if not foundCurrent then
			if not WorldManager.IsZoneUnlocked(player, zone.id) then
				return false, "You must unlock the previous zone first."
			end
		end
	end

	-- Check essence cost
	if profile.essence < zoneData.unlockCost then
		return false, string.format("Need %d Essence to unlock %s!", zoneData.unlockCost, zoneData.displayName)
	end

	-- Spend essence and unlock
	playerManager.SpendEssence(player, zoneData.unlockCost)
	table.insert(profile.unlockedZones, zoneId)
	playerManager.UpdateLeaderstats(player, profile)
	playerManager.SaveData(player, profile)

	-- Notify client
	local remote = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("ZoneUnlocked")
	if remote then
		remote:FireClient(player, {
			zoneId = zoneId,
			zoneName = zoneData.displayName,
		})
	end

	return true, nil
end

--[[ Teleport player to a zone ]]
function WorldManager.TeleportToZone(player, zoneId)
	if not WorldManager.IsZoneUnlocked(player, zoneId) then
		return false, "Zone not unlocked!"
	end

	local zoneData = WorldManager.GetZoneData(zoneId)
	if not zoneData then
		return false, "Zone not found."
	end

	local character = player.Character
	if not character then
		return false, "Character not found."
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return false, "Cannot teleport."
	end

	-- Teleport using CFrame
	humanoidRootPart.CFrame = CFrame.new(zoneData.teleportPosition)

	return true, nil
end

--[[ Get available zones for a player (unlocked + locked with costs) ]]
function WorldManager.GetZoneList(player)
	local playerManager = require(script.Parent.PlayerManager)
	local profile = playerManager.PlayerData[player.UserId]
	if not profile then return {} end

	local zones = {}
	for _, zone in ipairs(Constants.ZONES) do
		local isUnlocked = false
		for _, unlockedId in ipairs(profile.unlockedZones) do
			if unlockedId == zone.id then
				isUnlocked = true
				break
			end
		end

		table.insert(zones, {
			id = zone.id,
			name = zone.displayName,
			unlockCost = zone.unlockCost,
			isUnlocked = isUnlocked,
			energyMultiplier = zone.energyMultiplier,
			canAfford = profile.essence >= zone.unlockCost,
		})
	end

	return zones
end

--[[ Handle zone gate touch (for 3D gates with unlock prompt) ]]
function WorldManager.OnZoneGateTouch(player, zoneId)
	local unlocked = WorldManager.IsZoneUnlocked(player, zoneId)
	if unlocked then
		WorldManager.TeleportToZone(player, zoneId)
		return true, "Teleported!"
	else
		local zoneData = WorldManager.GetZoneData(zoneId)
		if zoneData then
			return false, string.format("Need %d Essence to unlock %s!", zoneData.unlockCost, zoneData.displayName)
		end
		return false, "Zone not found."
	end
end

return WorldManager