--[[ StatCalculator: Calculates EPS (Essence Per Second) and combat stats
	based on equipped monsters, ranks, and multipliers ]]
-- Shared module - runs on both server and client

local Constants = require(script.Parent.Constants)

local StatCalculator = {}

--[[ Calculates total EPS for a player based on equipped monsters and multipliers
	@param equippedMonsters table — list of monster objects currently equipped
	@param rebirthMultiplier number — the player's rebirth multiplier
	@return number — total EPS
]]
function StatCalculator.CalculateEPS(equippedMonsters, rebirthMultiplier)
	rebirthMultiplier = rebirthMultiplier or 1

	local totalEps = 0

	for _, monster in ipairs(equippedMonsters) do
		if monster then
			local eps = monster.eps or 0
			-- Level bonus: +10% EPS per level
			local levelBonus = 1 + ((monster.level - 1) * 0.1)
			totalEps += eps * levelBonus
		end
	end

	-- Apply rebirth multiplier
	totalEps = totalEps * rebirthMultiplier

	return totalEps
end

--[[ Calculates total combat power from equipped monsters
	@param equippedMonsters table — list of monster objects
	@return number — total combat power
]]
function StatCalculator.CalculateCombatPower(equippedMonsters)
	local totalPower = 0

	for _, monster in ipairs(equippedMonsters) do
		if monster then
			local rarityMultiplier = Constants.RARITIES[monster.rarity].epsMultiplier or 1
			local levelBonus = 1 + ((monster.level - 1) * 0.15)
			local shinyBonus = monster.shiny and 2 or 1
			totalPower += rarityMultiplier * levelBonus * shinyBonus
		end
	end

	return totalPower
end

--[[ Calculates XP needed to reach next level
	@param level number — current level
	@return number — XP required
]]
function StatCalculator.XPForNextLevel(level)
	return math.floor(100 * (1.5 ^ (level - 1)))
end

--[[ Calculates essence earned from a single energy click
	@param equippedMonsters table — list of monster objects
	@param rebirthMultiplier number
	@param zoneMultiplier number
	@return number — essence gained
]]
function StatCalculator.CalculateClickValue(equippedMonsters, rebirthMultiplier, zoneMultiplier)
	rebirthMultiplier = rebirthMultiplier or 1
	zoneMultiplier = zoneMultiplier or 1

	local eps = StatCalculator.CalculateEPS(equippedMonsters, rebirthMultiplier)
	-- Click gives essence equivalent to 0.5 seconds of EPS, multiplied by zone
	return math.max(1, math.floor(eps * 0.5 * zoneMultiplier))
end

--[[ Calculates total energy needed to reach essence goal
	@param targetEssence number
	@param eps number
	@return number — seconds to reach goal
]]
function StatCalculator.TimeToReachEssence(targetEssence, eps)
	if eps <= 0 then
		return math.huge
	end
	return targetEssence / eps
end

return StatCalculator