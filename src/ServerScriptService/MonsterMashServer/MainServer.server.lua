--[[ MainServer: Bootstraps and wires together all server-side systems. ]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local AdService = game:GetService("AdService")

local Constants = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("Constants"))
local Types = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("Types"))
local StatCalculator = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("StatCalculator"))
local RarityModule = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("RarityModule"))
local AdsManager = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("AdsManager"))

-- Load server systems
local PlayerManager = require(script.Parent:WaitForChild("PlayerManager"))
local MonsterManager = require(script.Parent:WaitForChild("MonsterManager"))
local BattleSystem = require(script.Parent:WaitForChild("BattleSystem"))
local WorldManager = require(script.Parent:WaitForChild("WorldManager"))
local MarketplaceHandler = require(script.Parent:WaitForChild("MarketplaceHandler"))
local DailyRewardsSystem = require(script.Parent:WaitForChild("DailyRewardsSystem"))
local WorldBuilder = require(script.Parent:WaitForChild("WorldBuilder"))

-- Helper to find remote events
local function GetRemoteEvent(name)
    return ReplicatedStorage:FindFirstChild("MonsterMash"):FindFirstChild("RemoteEvents"):FindFirstChild(name)
end

-- Grab all remote events
local CollectEnergy = GetRemoteEvent("CollectEnergy")
local HatchEgg = GetRemoteEvent("HatchEgg")
local EquipMonster = GetRemoteEvent("EquipMonster")
local EvolveMonster = GetRemoteEvent("EvolveMonster")
local StartBattle = GetRemoteEvent("StartBattle")
local PlayerAttack = GetRemoteEvent("PlayerAttack")
local TeleportToZone = GetRemoteEvent("TeleportToZone")
local UnlockZone = GetRemoteEvent("UnlockZone")
local Rebirth = GetRemoteEvent("Rebirth")
local ClaimDailyReward = GetRemoteEvent("ClaimDailyReward")
local RequestInventory = GetRemoteEvent("RequestInventory")

--[[ Energy Collection Handler ]]
if CollectEnergy then
    CollectEnergy.OnServerEvent:Connect(function(player, clickPower)
        local profile = PlayerManager.PlayerData[player.UserId]
        if not profile then return end

        local equipped = MonsterManager.GetEquippedMonsters(player)

        local energyAmount = math.clamp(math.floor(clickPower or 1), 1, 100)

        -- Apply Double Energy game pass multiplier
        local energyMult = MarketplaceHandler.GetEnergyMultiplier(player)
        energyAmount = math.floor(energyAmount * energyMult)

        PlayerManager.AddEnergy(player, energyAmount)

        -- Essence from EPS on click
        local eps = StatCalculator.CalculateEPS(equipped, profile.rebirthMultiplier)
        local essenceMult = MarketplaceHandler.GetEssenceMultiplier(player)
        local essenceGain = math.floor(eps * 0.1 * essenceMult)
        if essenceGain > 0 then
            PlayerManager.AddEssence(player, essenceGain)
        end

        local energyCollected = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("EnergyCollected")
        if energyCollected then
            energyCollected:FireClient(player, profile.energy, profile.essence)
        end
    end)
end

--[[ Hatching Handler (RemoteFunction) ]]
if HatchEgg then
    HatchEgg.OnServerInvoke = function(player, eggRarity, zoneId)
        eggRarity = eggRarity or "Common"
        zoneId = zoneId or "zone1_forest"

        local monster, err = MonsterManager.HatchEgg(player, eggRarity, zoneId)

        if monster then
            local remote = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("MonsterHatched")
            if remote then
                remote:FireClient(player, monster)
            end
            return { success = true, monster = monster }
        else
            return { success = false, error = err }
        end
    end
end

--[[ Equip Monster Handler ]]
if EquipMonster then
    EquipMonster.OnServerEvent:Connect(function(player, monsterUniqueId)
        local success, message = MonsterManager.ToggleEquipMonster(player, monsterUniqueId)
    end)
end

--[[ Evolve Monster Handler ]]
if EvolveMonster then
    EvolveMonster.OnServerEvent:Connect(function(player, monsterId)
        local shiny, err = MonsterManager.EvolveMonster(player, monsterId)

        if shiny then
            local remote = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("EvolutionComplete")
            if remote then
                remote:FireClient(player, shiny)
            end
        end
    end)
end

--[[ Battle Start Handler ]]
if StartBattle then
    StartBattle.OnServerEvent:Connect(function(player)
        local success, message = BattleSystem.StartBattle(player)
    end)
end

--[[ Player Attack Handler (during battle) ]]
if PlayerAttack then
    PlayerAttack.OnServerEvent:Connect(function(player)
        local success, message = BattleSystem.PlayerAttack(player)
    end)
end

--[[ Teleport to Zone Handler ]]
if TeleportToZone then
    TeleportToZone.OnServerEvent:Connect(function(player, zoneId)
        local success, message = WorldManager.TeleportToZone(player, zoneId)
    end)
end

--[[ Unlock Zone Handler ]]
if UnlockZone then
    UnlockZone.OnServerEvent:Connect(function(player, zoneId)
        local success, message = WorldManager.UnlockZone(player, zoneId)
    end)
end

--[[ Rebirth Handler ]]
if Rebirth then
    Rebirth.OnServerEvent:Connect(function(player)
        local equipped = MonsterManager.GetEquippedMonsters(player)
        local eps = StatCalculator.CalculateEPS(equipped, PlayerManager.PlayerData[player.UserId].rebirthMultiplier)
        local success = PlayerManager.TryRebirth(player, eps)
    end)
end

--[[ Daily Reward Claim Handler ]]
if ClaimDailyReward then
    ClaimDailyReward.OnServerEvent:Connect(function(player)
        local result, err = DailyRewardsSystem.ClaimReward(player)
        -- DailyRewardResult is fired from within ClaimReward
    end)
end

--[[ Request Inventory Handler (RemoteFunction) ]]
if RequestInventory then
    RequestInventory.OnServerInvoke = function(player)
        local profile = PlayerManager.PlayerData[player.UserId]
        if not profile then return {} end

        return {
            inventory = profile.inventory,
            equipped = profile.equipped,
            energy = profile.energy,
            essence = profile.essence,
            rank = profile.rank,
            rebirthMultiplier = profile.rebirthMultiplier,
            unlockedZones = profile.unlockedZones,
            ownedPasses = profile.ownedPasses or {},
            premiumEggs = profile.premiumEggs or {},
            boosts = profile.boosts or {},
            dailyRewards = DailyRewardsSystem.GetRewardStatus(player),
        }
    end
end

--[[ Player Join/Leave ]]
Players.PlayerAdded:Connect(function(player)
    PlayerManager.OnPlayerAdded(player)

    -- Check VIP and grant VIP Slime
    task.delay(3, function()
        if MarketplaceHandler.IsVIP(player) then
            MarketplaceHandler.GrantVIPMonster(player)
        end
    end)

    -- Check daily reward availability and notify client
    task.delay(1, function()
        local canClaim = DailyRewardsSystem.CanClaimToday(player)
        if canClaim then
            local remote = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("DailyRewardResult")
            if remote then
                remote:FireClient(player, {
                    canClaim = true,
                    todaysReward = DailyRewardsSystem.GetTodaysReward(player),
                })
            end
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    PlayerManager.OnPlayerRemoving(player)
end)

--[[ Passive Essence Generation Loop ]]
local passiveLoop = coroutine.wrap(function()
    while task.wait(1) do
        for _, player in ipairs(Players:GetPlayers()) do
            local profile = PlayerManager.PlayerData[player.UserId]
            if profile then
                local equipped = MonsterManager.GetEquippedMonsters(player)
                local eps = StatCalculator.CalculateEPS(equipped, profile.rebirthMultiplier)
                if eps > 0 then
                    local essenceMult = MarketplaceHandler.GetEssenceMultiplier(player)
                    profile.essence += eps * essenceMult
                    PlayerManager.UpdateLeaderstats(player, profile)
                end
            end
        end
    end
end)
passiveLoop()

--[[ Auto-save Timer ]]
local autoSaveLoop = coroutine.wrap(function()
    while task.wait(Constants.AUTO_SAVE_INTERVAL) do
        PlayerManager.AutoSaveAll()
    end
end)
autoSaveLoop()

--[[ NPC Attack Timer (for active battles) ]]
local npcAttackLoop = coroutine.wrap(function()
    while task.wait(2) do
        for _, player in ipairs(Players:GetPlayers()) do
            if BattleSystem.ActiveBattles[player.UserId] then
                BattleSystem.NPCAttackPlayer(player)
            end
        end
    end
end)
npcAttackLoop()

--[[ Auto-Hatch Timer (for Auto-Hatch game pass owners) ]]
local autoHatchLoop = coroutine.wrap(function()
    while task.wait(10) do
        for _, player in ipairs(Players:GetPlayers()) do
            MarketplaceHandler.TryAutoHatch(player)
        end
    end
end)
autoHatchLoop()

--[[ MarketplaceService: Game Pass purchase handler ]]
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
    if wasPurchased then
        MarketplaceHandler.OnPlayerPurchasedGamePass(player, gamePassId)
    end
end)

--[[ MarketplaceService: Developer Product receipt handler ]]
MarketplaceService.ProcessReceipt = function(receiptInfo)
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    return MarketplaceHandler.ProcessDeveloperProduct(player, receiptInfo.ProductId)
end

--[[ AdService: Rewarded video ad completion handler ]]
if AdService and AdService.PromptAdFinished then
    AdService.PromptAdFinished:Connect(function(player, adType, wasCompleted)
        if wasCompleted then
            AdsManager.OnAdRewarded(player, adType)
        end
    end)
end

--[[ Handle PlayerAttack from client battle attacks — also fire BattleSystem.PlayerAttack ]]
-- (already handled above via PlayerAttack remote event)

--[[ Build the 3D world on server start via MainBuilder ]]
task.delay(0.5, function()
    WorldBuilder.BuildAll()
end)

print("[MonsterMashServer] All systems initialized successfully.")