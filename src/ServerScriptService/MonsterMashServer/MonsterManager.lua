--[[ MonsterManager: Handles gacha/hatching, equipping, evolving, XP, and monster inventory ]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("Constants"))
local Types = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("Types"))
local RarityModule = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("RarityModule"))
local StatCalculator = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("StatCalculator"))

local MonsterManager = {}

-- Gets the modules for remote events
local function GetRemote(name)
    local parent = ReplicatedStorage:FindFirstChild("MonsterMash")
    if parent then
        local rEvents = parent:FindFirstChild("RemoteEvents")
        if rEvents then
            return rEvents:FindFirstChild(name)
        end
    end
    return nil
end

--[[ Gets egg cost for a given egg rarity ]]
local function GetEggCost(eggRarity)
    local costs = {
        Common = Constants.COMMON_EGG_COST,
        Rare = Constants.RARE_EGG_COST,
        Epic = Constants.EPIC_EGG_COST,
        Legendary = Constants.LEGENDARY_EGG_COST,
        Mythical = Constants.MYTHICAL_EGG_COST,
    }
    return costs[eggRarity] or Constants.COMMON_EGG_COST
end

--[[ Checks if a player can equip a monster based on max slots ]]
local function GetEquippedCount(profile)
    local count = 0
    for _, _ in pairs(profile.equipped) do
        count += 1
    end
    return count
end

--[[ Points XP to nearest matching monster and levels it up if enough XP ]]
local function AddMonsterXP(profile, monsterUniqueId, xpAmount)
    for i, monster in ipairs(profile.inventory) do
        if monster.uniqueId == monsterUniqueId then
            monster.xp = (monster.xp or 0) + xpAmount
            local xpNeeded = StatCalculator.XPForNextLevel(monster.level)
            while monster.xp >= xpNeeded do
                monster.xp -= xpNeeded
                monster.level += 1
                -- EPS increases by 10% per level
                monster.eps = monster.eps * 1.1
                xpNeeded = StatCalculator.XPForNextLevel(monster.level)
            end
            return true
        end
    end
    return false
end

--[[ Hatch an egg for a player ]]
function MonsterManager.HatchEgg(player, eggRarity, zoneId)
    local profile = require(script.Parent.PlayerManager).PlayerData[player.UserId]
    if not profile then return nil end

    local cost = GetEggCost(eggRarity)
    if not require(script.Parent.PlayerManager).SpendEnergy(player, cost) then
        return nil, "Not enough energy! Need " .. tostring(cost) .. " Energy."
    end

    -- Roll monster
    local monster = RarityModule.HatchMonster(zoneId, eggRarity)
    table.insert(profile.inventory, monster)
    require(script.Parent.PlayerManager).SaveData(player, profile)

    return monster, nil
end

--[[ Equip or unequip a monster ]]
function MonsterManager.ToggleEquipMonster(player, monsterUniqueId)
    local profile = require(script.Parent.PlayerManager).PlayerData[player.UserId]
    if not profile then return false, "Profile not found." end

    -- Check if already equipped
    for i, equippedId in ipairs(profile.equipped) do
        if equippedId == monsterUniqueId then
            table.remove(profile.equipped, i)
            require(script.Parent.PlayerManager).SaveData(player, profile)
            return true, "unequipped"
        end
    end

    -- Check max equipped (accounts for Extra Equip game pass)
    local marketplaceHandler = script.Parent:FindFirstChild("MarketplaceHandler")
    local maxSlots = Constants.MAX_EQUIPPED_MONSTERS
    if marketplaceHandler then
        maxSlots = require(marketplaceHandler).GetMaxEquippedSlots(player)
    end
    if GetEquippedCount(profile) >= maxSlots then
        return false, string.format("You can only equip %d monsters! Buy 'Extra Equip' game pass for more.", maxSlots)
    end

    -- Check monster exists in inventory
    local monsterExists = false
    for _, monster in ipairs(profile.inventory) do
        if monster.uniqueId == monsterUniqueId then
            monsterExists = true
            break
        end
    end

    if not monsterExists then
        return false, "Monster not found in inventory."
    end

    table.insert(profile.equipped, monsterUniqueId)
    require(script.Parent.PlayerManager).SaveData(player, profile)
    return true, "equipped"
end

--[[ Evolve 5 of the same monster into a shiny version ]]
function MonsterManager.EvolveMonster(player, monsterId)
    local profile = require(script.Parent.PlayerManager).PlayerData[player.UserId]
    if not profile then return nil, "Profile not found." end

    -- Find monsters with this base ID (same name and rarity)
    local matchingMonsters = {}
    for _, monster in ipairs(profile.inventory) do
        if monster.id == monsterId and not monster.shiny then
            table.insert(matchingMonsters, monster)
        end
    end

    if #matchingMonsters < 5 then
        return nil, string.format("Need 5 of the same monster! You have %d.", #matchingMonsters)
    end

    -- Remove the first 5 matching monsters
    local removedIds = {}
    for i = 1, 5 do
        local monster = matchingMonsters[i]
        removedIds[monster.uniqueId] = true

        -- Remove from equipped if needed
        for ei = #profile.equipped, 1, -1 do
            if profile.equipped[ei] == monster.uniqueId then
                table.remove(profile.equipped, ei)
            end
        end

        -- Remove from inventory
        for ii = #profile.inventory, 1, -1 do
            if profile.inventory[ii].uniqueId == monster.uniqueId then
                table.remove(profile.inventory, ii)
                break
            end
        end
    end

    -- Create shiny version
    local baseMonster = matchingMonsters[1]
    local shinyMonster = {
        name = "Shiny " .. baseMonster.name,
        rarity = baseMonster.rarity,
        eps = baseMonster.eps * 2,
        level = baseMonster.level,
        xp = 0,
        shiny = true,
        id = "Shiny_" .. baseMonster.id,
        uniqueId = "shiny_" .. tick() .. "_" .. math.random(1, 99999),
    }
    table.insert(profile.inventory, shinyMonster)

    require(script.Parent.PlayerManager).SaveData(player, profile)
    return shinyMonster, nil
end

--[[ Delete a monster from inventory ]]
function MonsterManager.DeleteMonster(player, monsterUniqueId)
    local profile = require(script.Parent.PlayerManager).PlayerData[player.UserId]
    if not profile then return false end

    -- Remove from equipped
    for i = #profile.equipped, 1, -1 do
        if profile.equipped[i] == monsterUniqueId then
            table.remove(profile.equipped, i)
        end
    end

    -- Remove from inventory
    for i = #profile.inventory, 1, -1 do
        if profile.inventory[i].uniqueId == monsterUniqueId then
            table.remove(profile.inventory, i)
            require(script.Parent.PlayerManager).SaveData(player, profile)
            return true
        end
    end

    return false
end

--[[ Get equipped monster objects for a player ]]
function MonsterManager.GetEquippedMonsters(player)
    local profile = require(script.Parent.PlayerManager).PlayerData[player.UserId]
    if not profile then return {} end

    local equipped = {}
    for _, uniqueId in ipairs(profile.equipped) do
        for _, monster in ipairs(profile.inventory) do
            if monster.uniqueId == uniqueId then
                table.insert(equipped, monster)
                break
            end
        end
    end

    return equipped
end

--[[ Distribute XP to all equipped monsters ]]
function MonsterManager.DistributeBattleXP(player, xpAmount)
    local profile = require(script.Parent.PlayerManager).PlayerData[player.UserId]
    if not profile then return end

    local equippedCount = 0
    for _, _ in ipairs(profile.equipped) do
        equippedCount += 1
    end

    if equippedCount == 0 then return end

    local xpPerMonster = math.floor(xpAmount / equippedCount)

    for _, uniqueId in ipairs(profile.equipped) do
        AddMonsterXP(profile, uniqueId, xpPerMonster)
    end

    require(script.Parent.PlayerManager).SaveData(player, profile)
end

return MonsterManager