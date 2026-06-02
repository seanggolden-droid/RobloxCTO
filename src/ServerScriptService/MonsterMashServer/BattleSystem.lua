--[[ BattleSystem: Handles NPC wave combat arena logic ]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Constants = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("Constants"))
local StatCalculator = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("StatCalculator"))

local BattleSystem = {}
BattleSystem.ActiveBattles = {} -- [UserId] = battleState

--[[ Battle state structure
	.currentWave number
	.npcHP number
	.npcMaxHP number
	.npcDamage number
	.battleActive boolean
	.playerTotalPower number
	.lastAttackTime number
	.playerUserId number
]]

--[[ Starts a battle for the player ]]
function BattleSystem.StartBattle(player)
	local userId = player.UserId

	-- Check if already in a battle
	if BattleSystem.ActiveBattles[userId] and BattleSystem.ActiveBattles[userId].battleActive then
		return false, "Already in a battle!"
	end

	-- Get equipped monsters for power calculation
	local monsterManager = require(script.Parent.MonsterManager)
	local equipped = monsterManager.GetEquippedMonsters(player)
	local power = StatCalculator.CalculateCombatPower(equipped)

	if power <= 0 then
		return false, "Equip some monsters before battling!"
	end

	-- Initialize battle
	local battleState = {
		currentWave = 1,
		npcHP = Constants.NPC_BASE_HP,
		npcMaxHP = Constants.NPC_BASE_HP,
		npcDamage = Constants.NPC_BASE_DAMAGE,
		battleActive = true,
		playerTotalPower = power,
		battleStartTime = os.clock(),
		lastAttackTime = 0,
		playerUserId = userId,
	}

	BattleSystem.ActiveBattles[userId] = battleState

	-- Send initial battle update to client
	local remote = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("BattleUpdate")
	if remote then
		remote:FireClient(player, {
			wave = battleState.currentWave,
			waveCount = Constants.BATTLE_WAVE_COUNT,
			npcHP = battleState.npcHP,
			npcMaxHP = battleState.npcMaxHP,
			battleActive = true,
			playerPower = power,
		})
	end

	return true, nil
end

--[[ Processes a tick of combat damage from the player to the current NPC ]]
function BattleSystem.PlayerAttack(player)
	local userId = player.UserId
	local battle = BattleSystem.ActiveBattles[userId]
	if not battle or not battle.battleActive then
		return false, "No active battle."
	end

	-- Debounce (once per 0.5 seconds)
	local now = os.clock()
	if now - battle.lastAttackTime < 0.5 then
		return false, "Wait before attacking again."
	end
	battle.lastAttackTime = now

	-- Player damage = power * random(0.8, 1.2)
	local playerDamage = math.max(1, math.floor(battle.playerTotalPower * (0.8 + math.random() * 0.4)))

	battle.npcHP -= playerDamage

	local remote = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("BattleUpdate")
	if remote then
		remote:FireClient(player, {
			damageDealt = playerDamage,
			npcHP = battle.npcHP,
			npcMaxHP = battle.npcMaxHP,
			wave = battle.currentWave,
		})
	end

	-- Check if NPC is defeated
	if battle.npcHP <= 0 then
		BattleSystem.OnNPCDefeated(player, battle)
	end

	return true, nil
end

--[[ Called when the current NPC wave is defeated ]]
function BattleSystem.OnNPCDefeated(player, battle)
	if battle.currentWave >= Constants.BATTLE_WAVE_COUNT then
		-- Battle complete — all waves cleared!
		BattleSystem.CompleteBattle(player, battle)
		return
	end

	-- Advance to next wave
	battle.currentWave += 1
	battle.npcHP = Constants.NPC_BASE_HP + (Constants.NPC_HP_PER_WAVE * (battle.currentWave - 1))
	battle.npcMaxHP = battle.npcHP
	battle.npcDamage = Constants.NPC_BASE_DAMAGE + (Constants.NPC_DAMAGE_PER_WAVE * (battle.currentWave - 1))

	local remote = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("BattleUpdate")
	if remote then
		remote:FireClient(player, {
			wave = battle.currentWave,
			waveCount = Constants.BATTLE_WAVE_COUNT,
			npcHP = battle.npcHP,
			npcMaxHP = battle.npcMaxHP,
			message = string.format("Wave %d incoming!", battle.currentWave),
		})
	end
end

--[[ Called when all waves are cleared ]]
function BattleSystem.CompleteBattle(player, battle)
	battle.battleActive = false

	-- Calculate rewards
	local essenceReward = Constants.BATTLE_REWARD_ESSENCE_BASE +
		(Constants.BATTLE_REWARD_ESSENCE_PER_WAVE * (battle.currentWave - 1))

	local xpReward = essenceReward * 2

	-- Award essence
	local playerManager = require(script.Parent.PlayerManager)
	playerManager.AddEssence(player, essenceReward)

	-- Award XP to equipped monsters
	local monsterManager = require(script.Parent.MonsterManager)
	monsterManager.DistributeBattleXP(player, xpReward)

	-- Save
	playerManager.SaveData(player, playerManager.PlayerData[player.UserId])

	-- Notify client
	local remote = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("BattleComplete")
	if remote then
		remote:FireClient(player, {
			wavesCleared = battle.currentWave,
			essenceReward = essenceReward,
			xpReward = xpReward,
			battleComplete = true,
		})
	end

	-- Cleanup
	BattleSystem.ActiveBattles[player.UserId] = nil
end

--[[ Player takes damage from NPCs (called on a timer) ]]
function BattleSystem.NPCAttackPlayer(player)
	local userId = player.UserId
	local battle = BattleSystem.ActiveBattles[userId]
	if not battle or not battle.battleActive then return end

	-- NPC deals damage based on wave (mitigated by player power)
	local rawDamage = battle.npcDamage
	local mitigation = math.max(0.1, 1 - (battle.playerTotalPower * 0.01))
	local actualDamage = math.max(1, math.floor(rawDamage * mitigation))

	-- For now, we track a simple health pool in the battle state
	-- Player has 100 base HP + (power * 10)
	local playerMaxHP = 100 + (battle.playerTotalPower * 10)
	if not battle.playerHP then
		battle.playerHP = playerMaxHP
	end

	battle.playerHP -= actualDamage

	local remote = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("BattleUpdate")
	if remote then
		remote:FireClient(player, {
			playerHP = battle.playerHP,
			playerMaxHP = playerMaxHP,
			npcDamage = actualDamage,
			npcHP = battle.npcHP,
			npcMaxHP = battle.npcMaxHP,
		})
	end

	-- If player HP reaches 0, they lose but still get partial rewards
	if battle.playerHP <= 0 then
		battle.battleActive = false

		-- Partial rewards for effort
		local partialReward = math.floor(
			(Constants.BATTLE_REWARD_ESSENCE_BASE * battle.currentWave) / Constants.BATTLE_WAVE_COUNT
		)

		local playerManager = require(script.Parent.PlayerManager)
		playerManager.AddEssence(player, partialReward)

		playerManager.SaveData(player, playerManager.PlayerData[player.UserId])

		local remote2 = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("BattleComplete")
		if remote2 then
			remote2:FireClient(player, {
				wavesCleared = battle.currentWave,
				essenceReward = partialReward,
				xpReward = 0,
				battleComplete = true,
				defeated = true,
			})
		end

		BattleSystem.ActiveBattles[userId] = nil
	end
end

--[[ Syncs battle state to client periodically ]]
function BattleSystem.SyncBattle(player)
	local userId = player.UserId
	local battle = BattleSystem.ActiveBattles[userId]
	if not battle then return end

	local remote = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("BattleUpdate")
	if remote then
		remote:FireClient(player, {
			wave = battle.currentWave,
			waveCount = Constants.BATTLE_WAVE_COUNT,
			npcHP = battle.npcHP,
			npcMaxHP = battle.npcMaxHP,
			battleActive = battle.battleActive,
		})
	end
end

return BattleSystem