--[[ RarityModule: Handles weighted random selection for egg hatching and loot drops ]]
-- Shared module - runs on both server and client

local Constants = require(script.Parent.Constants)

local RarityModule = {}

-- Monster name pools by rarity
local MONSTER_NAMES = {
	Common = {
		"Slime", "Puddle Pup", "Mudkip", "Fluff Ball",
		"Spark Pup", "Tiny Cat", "Berry Goblin", "Dust Mite",
		"Grass Hopper", "Cuddle Fish",
	},
	Rare = {
		"Golem", "Sand Viper", "Storm Crow", "Flame Fox",
		"Frost Bear", "Thunder Ram", "Crystal Crab", "Shadow Lynx",
		"Boulder Boar", "Venom Moth",
	},
	Epic = {
		"Dragon Hatchling", "Phoenix Ember", "Thunder Bird",
		"Serpent King", "Stone Giant", "Frost Wyrm",
		"Shadow Stalker", "Magma Lord",
	},
	Legendary = {
		"Ancient Dragon", "Celestial Phoenix", "Storm Titan",
		"Abyss Leviathan", "Void Walker", "Chrono Beast",
		"Cosmic Serpent", "Starfall Knight",
	},
	Mythical = {
		"Cosmic Entity", "Void God", "Eternal One",
		"Reality Weaver", "Infinity Dragon", "Primordial Being",
	},
}

--[[ Rolls a rarity with weighted random selection
	@param zoneId string — the zone's ID to factor in rarity boosts
	@return string — the rarity key
]]
function RarityModule.RollRarity(zoneRarityBoost)
	zoneRarityBoost = zoneRarityBoost or 0

	local total = Constants.TOTAL_WEIGHT
	local roll = math.random() * total

	-- Apply zone boost by reducing Common weight
	local adjustedWeights = {}
	for rarity, data in pairs(Constants.RARITIES) do
		adjustedWeights[rarity] = data.weight
	end
	if zoneRarityBoost > 0 then
		adjustedWeights.Common = math.max(10, adjustedWeights.Common - zoneRarityBoost)
	end

	local adjustedTotal = 0
	for _, w in pairs(adjustedWeights) do
		adjustedTotal += w
	end

	roll = math.random() * adjustedTotal
	local cumulative = 0

	for rarity, data in pairs(Constants.RARITIES) do
		cumulative += adjustedWeights[rarity]
		if roll <= cumulative then
			return rarity
		end
	end

	return "Common"
end

--[[ Generates a monster from hatching
	@param rarity string — the rarity key
	@param isShiny boolean — whether the monster is shiny
	@return table — monster object
]]
function RarityModule.GenerateMonster(rarity, isShiny)
	isShiny = isShiny or false

	local namePool = MONSTER_NAMES[rarity] or MONSTER_NAMES.Common
	local name = namePool[math.random(#namePool)]

	local rarityData = Constants.RARITIES[rarity]
	local baseEps = rarityData.epsMultiplier * Constants.STARTER_MONSTER_EPS

	if isShiny then
		baseEps = baseEps * 2
	end

	local uniqueId = string.format("%s_%d_%d", rarity, tick(), math.random(1, 99999))

	return {
		name = name,
		rarity = rarity,
		eps = baseEps,
		level = 1,
		xp = 0,
		shiny = isShiny,
		id = rarity .. "_" .. name,
		uniqueId = uniqueId,
	}
end

--[[ Rolls a hatched egg: picks rarity then generates monster
	@param zoneId string — the zone ID
	@param eggRarity string — the egg type being hatched
	@return table — monster object
]]
function RarityModule.HatchMonster(zoneId, eggRarity)
	eggRarity = eggRarity or "Common"

	-- Egg rarity determines the floor rarity
	local rarities = { "Common", "Rare", "Epic", "Legendary", "Mythical" }

	-- Find the index of the egg rarity
	local floorIndex = 1
	for i, r in ipairs(rarities) do
		if r == eggRarity then
			floorIndex = i
			break
		end
	end

	-- Roll rarity (floor capped by egg type)
	local zone = nil
	for _, z in ipairs(Constants.ZONES) do
		if z.id == zoneId then
			zone = z
			break
		end
	end
	local zoneBoost = (zone and zone.eggRarityBoost) or 0

	-- Keep rolling until we get at least the egg's floor rarity
	local rolledRarity
	for _ = 1, 50 do
		rolledRarity = RarityModule.RollRarity(zoneBoost)
		local rolledIndex = 1
		for i, r in ipairs(rarities) do
			if r == rolledRarity then
				rolledIndex = i
				break
			end
		end
		if rolledIndex >= floorIndex then
			break
		end
	end

	-- 5% chance for shiny
	local isShiny = math.random() <= 0.05

	return RarityModule.GenerateMonster(rolledRarity, isShiny)
end

--[[ Get all monster names for a rarity ]]
function RarityModule.GetMonsterNames(rarity)
	return MONSTER_NAMES[rarity] or MONSTER_NAMES.Common
end

return RarityModule