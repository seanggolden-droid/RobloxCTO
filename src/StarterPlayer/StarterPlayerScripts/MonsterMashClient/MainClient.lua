--[[ MainClient: Client-side bootstrapper for Monster Mash Simulator ]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Require modules
local Constants = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("Constants"))
local Types = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("Types"))
local StatCalculator = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("StatCalculator"))

-- Load client controllers
local UIController = require(script:WaitForChild("UIController"))
local ClickHandler = require(script:WaitForChild("ClickHandler"))
local EffectManager = require(script:WaitForChild("EffectManager"))

-- Get remote events
local function GetRemoteEvent(name)
	return ReplicatedStorage:FindFirstChild("MonsterMash"):FindFirstChild("RemoteEvents"):FindFirstChild(name)
end

local CollectEnergy = GetRemoteEvent("CollectEnergy")
local HatchEgg = GetRemoteEvent("HatchEgg")
local EquipMonster = GetRemoteEvent("EquipMonster")
local EvolveMonster = GetRemoteEvent("EvolveMonster")
local StartBattle = GetRemoteEvent("StartBattle")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MonsterMashUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Initialize UI
UIController.Initialize(screenGui, player)

-- Setup ClickHandler
ClickHandler.Initialize(CollectEnergy)

-- Setup remote event listeners

-- Listen for HUD updates from server
local UpdateHUD = GetRemoteEvent("UpdateHUD")
if UpdateHUD then
	UpdateHUD.OnClientEvent:Connect(function(energy, essence, rank, rebirthMultiplier)
		UIController.UpdateStats(energy, essence, rank, rebirthMultiplier)
	end)
end

-- Listen for monster hatched
local MonsterHatched = GetRemoteEvent("MonsterHatched")
if MonsterHatched then
	MonsterHatched.OnClientEvent:Connect(function(monster)
		UIController.ShowHatchedMonster(monster)
		EffectManager.PlayHatchEffect()
	end)
end

-- Listen for battle updates
local BattleUpdate = GetRemoteEvent("BattleUpdate")
if BattleUpdate then
	BattleUpdate.OnClientEvent:Connect(function(data)
		UIController.UpdateBattleUI(data)
	end)
end

-- Listen for battle complete
local BattleComplete = GetRemoteEvent("BattleComplete")
if BattleComplete then
	BattleComplete.OnClientEvent:Connect(function(data)
		UIController.ShowBattleResults(data)
		EffectManager.PlayBattleCompleteEffect(data.battleComplete)
	end)
end

-- Listen for evolution complete
local EvolutionComplete = GetRemoteEvent("EvolutionComplete")
if EvolutionComplete then
	EvolutionComplete.OnClientEvent:Connect(function(shinyMonster)
		UIController.ShowEvolutionResult(shinyMonster)
		EffectManager.PlayEvolutionEffect()
	end)
end

-- Listen for zone unlocked
local ZoneUnlocked = GetRemoteEvent("ZoneUnlocked")
if ZoneUnlocked then
	ZoneUnlocked.OnClientEvent:Connect(function(data)
		UIController.ShowZoneUnlocked(data)
	end)
end

-- Listen for energy collected (sync)
local EnergyCollected = GetRemoteEvent("EnergyCollected")
if EnergyCollected then
	EnergyCollected.OnClientEvent:Connect(function(energy, essence)
		UIController.UpdateStats(energy, essence)
	end)
end

print("[MonsterMashClient] Initialized successfully.")

-- Return modules for debugging
return {
	UIController = UIController,
	ClickHandler = ClickHandler,
	EffectManager = EffectManager,
}