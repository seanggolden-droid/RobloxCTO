--[[ Type definitions for Monster Mash Simulator ]]

local Types = {}

--[[ Monster definition
@interface Monster
.name string
.rarity string
.eps number
.level number
.xp number
.shiny boolean
.id string
.uniqueId string
]]
function Types.Monster(name, rarity, eps, level, xp, shiny, id, uniqueId)
	return {
		name = name or "Unknown",
		rarity = rarity or "Common",
		eps = eps or 1,
		level = level or 1,
		xp = xp or 0,
		shiny = shiny or false,
		id = id or "",
		uniqueId = uniqueId or "",
	}
end

--[[ Player profile
@interface PlayerProfile
.energy number
.essence number
.rank number
.inventory table<Monster>
.equipped table<string>
.unlockedZones table<string>
.settings {mute: boolean, autoSave: boolean}
.rebirthMultiplier number
]]
function Types.PlayerProfile()
	return {
		energy = 0,
		essence = 0,
		rank = 0,
		inventory = {},
		equipped = {},
		unlockedZones = {},
		settings = {
			mute = false,
			autoSave = true,
		},
		rebirthMultiplier = 1,
	}
end

--[[ Remote event names ]] 
Types.REMOTE_EVENTS = {
	COLLECT_ENERGY = "CollectEnergy",
	HATCH_EGG = "HatchEgg",
	EQUIP_MONSTER = "EquipMonster",
	EVOLVE_MONSTER = "EvolveMonster",
	START_BATTLE = "StartBattle",
	UPDATE_HUD = "UpdateHUD",
	MONSTER_HATCHED = "MonsterHatched",
	BATTLE_UPDATE = "BattleUpdate",
	BATTLE_COMPLETE = "BattleComplete",
	BATTLE_REWARD = "BattleReward",
	EVOLUTION_COMPLETE = "EvolutionComplete",
	ZONE_UNLOCKED = "ZoneUnlocked",
	ENERGY_COLLECTED = "EnergyCollected",
}

return Types