--[[ Constants for Monster Mash Simulator ]]

-- Rarity definitions with weights and colors
local Constants = {}

Constants.RARITIES = {
    Common = {
        weight = 60,
        color = Color3.fromRGB(144, 238, 144), -- Light Green
        displayName = "Common",
        epsMultiplier = 1,
    },
    Rare = {
        weight = 25,
        color = Color3.fromRGB(65, 105, 225), -- Royal Blue
        displayName = "Rare",
        epsMultiplier = 2,
    },
    Epic = {
        weight = 10,
        color = Color3.fromRGB(147, 112, 219), -- Medium Purple
        displayName = "Epic",
        epsMultiplier = 4,
    },
    Legendary = {
        weight = 4.5,
        color = Color3.fromRGB(255, 165, 0), -- Orange
        displayName = "Legendary",
        epsMultiplier = 8,
    },
    Mythical = {
        weight = 0.5,
        color = Color3.fromRGB(255, 50, 50), -- Bright Red
        displayName = "Mythical",
        epsMultiplier = 16,
    },
}

Constants.TOTAL_WEIGHT = 0
for _, rarity in pairs(Constants.RARITIES) do
    Constants.TOTAL_WEIGHT += rarity.weight
end

-- Zone definitions
Constants.ZONES = {
    {
        id = "zone1_forest",
        name = "Forest Village",
        displayName = "Forest Village",
        unlockCost = 0,
        energyMultiplier = 1,
        eggRarityBoost = 0,
        teleportPosition = Vector3.new(0, 0, 0),
        isUnlocked = true,
    },
    {
        id = "zone2_desert",
        name = "Scorched Desert",
        displayName = "Scorched Desert",
        unlockCost = 5000,
        energyMultiplier = 2,
        eggRarityBoost = 5,
        teleportPosition = Vector3.new(1000, 0, 0),
        isUnlocked = false,
    },
    {
        id = "zone3_cyber",
        name = "Cyber City",
        displayName = "Cyber City",
        unlockCost = 50000,
        energyMultiplier = 4,
        eggRarityBoost = 10,
        teleportPosition = Vector3.new(2000, 0, 0),
        isUnlocked = false,
    },
}

-- Game balance constants
Constants.STARTER_MONSTER_EPS = 1
Constants.COMMON_EGG_COST = 100
Constants.RARE_EGG_COST = 500
Constants.EPIC_EGG_COST = 2500
Constants.LEGENDARY_EGG_COST = 10000
Constants.MYTHICAL_EGG_COST = 50000

Constants.REBIRTH_MULTIPLIER = 2
Constants.REBIRTH_COST_MULTIPLIER = 5
Constants.BASE_REBIRTH_COST = 25000

Constants.MAX_EQUIPPED_MONSTERS = 4
Constants.XP_PER_ENERGY = 1

-- Battle constants
Constants.BATTLE_WAVE_COUNT = 10
Constants.NPC_BASE_HP = 50
Constants.NPC_HP_PER_WAVE = 30
Constants.NPC_BASE_DAMAGE = 5
Constants.NPC_DAMAGE_PER_WAVE = 3
Constants.BATTLE_REWARD_ESSENCE_BASE = 50
Constants.BATTLE_REWARD_ESSENCE_PER_WAVE = 25

-- DataStore constants
Constants.DATASTORE_NAME = "MonsterMashData"
Constants.DATASTORE_KEY_PREFIX = "Player_"
Constants.AUTO_SAVE_INTERVAL = 60

-- Game Pass definitions
Constants.GAME_PASSES = {
    double_energy = {
        id = "double_energy",
        name = "Double Energy",
        description = "2x multiplier on all Energy collection",
        robux = 400,
        effect = "energy_multiplier",
    },
    auto_hatch = {
        id = "auto_hatch",
        name = "Auto-Hatch",
        description = "Automatically hatches eggs every 10 seconds",
        robux = 250,
        effect = "auto_hatch",
    },
    extra_equip = {
        id = "extra_equip",
        name = "Extra Equip",
        description = "Allows equipping 2 more monsters (total 6)",
        robux = 350,
        effect = "extra_slots",
    },
    vip = {
        id = "vip",
        name = "VIP",
        description = "Special name tag, 1.5x Essence, and exclusive VIP Slime monster",
        robux = 500,
        effect = "essence_multiplier_vip",
    },
}

-- Game Pass ID mapping (fill in your actual Roblox asset IDs here)
Constants.GAME_PASSES_BY_ID = {} -- key = tostring(assetId), value = game pass entry

-- Developer Product definitions
Constants.DEV_PRODUCTS = {
    instant_energy_small = {
        id = "instant_energy_small",
        name = "Small Energy Pack",
        type = "energy",
        amount = 500,
        robux = 25,
    },
    instant_energy_medium = {
        id = "instant_energy_medium",
        name = "Medium Energy Pack",
        type = "energy",
        amount = 2500,
        robux = 100,
    },
    instant_energy_large = {
        id = "instant_energy_large",
        name = "Large Energy Pack",
        type = "energy",
        amount = 10000,
        robux = 350,
    },
    lucky_egg_boost = {
        id = "lucky_egg_boost",
        name = "Lucky Egg Boost",
        type = "boost_luck",
        description = "Increases luck for higher rarity monsters for 15 minutes",
        robux = 50,
    },
    rare_egg = {
        id = "rare_egg",
        name = "Rare Egg",
        type = "rare_egg",
        eggRarity = "Rare",
        robux = 75,
    },
    epic_egg = {
        id = "epic_egg",
        name = "Epic Egg",
        type = "rare_egg",
        eggRarity = "Epic",
        robux = 200,
    },
    legendary_egg = {
        id = "legendary_egg",
        name = "Legendary Egg",
        type = "rare_egg",
        eggRarity = "Legendary",
        robux = 500,
    },
}

-- Dev Product ID mapping (fill in your actual Roblox asset IDs here)
Constants.DEV_PRODUCTS_BY_ID = {} -- key = tostring(assetId), value = dev product entry

-- Rebirth rank titles
Constants.RANK_TITLES = {
    "Rookie",
    "Trainer",
    "Beastmaster",
    "Monster Tamer",
    "Evolution Master",
    "Grand Champion",
    "Mythical Hero",
    "Legendary Lord",
    "Cosmic Overlord",
    "Monster God",
}

-- Egg definitions (which eggs can be hatched in each zone)
Constants.ZONE_EGGS = {
    zone1_forest = { "Common", "Rare", "Epic" },
    zone2_desert = { "Common", "Rare", "Epic", "Legendary" },
    zone3_cyber = { "Common", "Rare", "Epic", "Legendary", "Mythical" },
}

return Constants
