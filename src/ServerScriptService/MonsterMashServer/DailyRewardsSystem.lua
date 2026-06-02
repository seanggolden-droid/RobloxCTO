--[[ DailyRewardsSystem: 7-day daily reward cycle for Monster Mash Simulator ]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("Constants"))

local DailyRewardsSystem = {}

-- 7-day reward schedule
local DAILY_REWARDS = {
	{ day = 1, rewardType = "energy", amount = 100, label = "100 Energy" },
	{ day = 2, rewardType = "essence", amount = 200, label = "200 Essence" },
	{ day = 3, rewardType = "egg", eggRarity = "Rare", label = "Rare Egg" },
	{ day = 4, rewardType = "energy", amount = 500, label = "500 Energy" },
	{ day = 5, rewardType = "essence", amount = 1000, label = "1,000 Essence" },
	{ day = 6, rewardType = "boost", label = "Lucky Boost" },
	{ day = 7, rewardType = "egg", eggRarity = "Epic", label = "Epic Egg" },
}

--[[ Get today's reward info based on the player's streak ]]
function DailyRewardsSystem.GetTodaysReward(player)
	local profile = require(script.Parent.PlayerManager).PlayerData[player.UserId]
	if not profile then return nil end

	-- Initialize daily rewards tracking
	if not profile.dailyRewards then
		profile.dailyRewards = {
			streak = 0,
			lastClaimDate = "",
			claimedDays = {},
		}
	end

	local currentStreak = profile.dailyRewards.streak or 0
	local rewardIndex = (currentStreak % 7) + 1
	return DAILY_REWARDS[rewardIndex]
end

--[[ Check if player can claim a daily reward today ]]
function DailyRewardsSystem.CanClaimToday(player)
	local profile = require(script.Parent.PlayerManager).PlayerData[player.UserId]
	if not profile or not profile.dailyRewards then return true end

	local lastDate = profile.dailyRewards.lastClaimDate or ""
	local today = os.date("%Y-%m-%d", os.time())

	return lastDate ~= today
end

--[[ Claim the daily reward for the player ]]
function DailyRewardsSystem.ClaimReward(player)
	local profile = require(script.Parent.PlayerManager).PlayerData[player.UserId]
	if not profile then return nil, "Profile not found." end

	-- Initialize if needed
	if not profile.dailyRewards then
		profile.dailyRewards = {
			streak = 0,
			lastClaimDate = "",
			claimedDays = {},
		}
	end

	local today = os.date("%Y-%m-%d", os.time())

	-- Check if already claimed today
	if profile.dailyRewards.lastClaimDate == today then
		return nil, "Already claimed today's reward!"
	end

	-- Check if streak continues (yesterday or same session)
	local yesterday = os.date("%Y-%m-%d", os.time() - 86400)
	if profile.dailyRewards.lastClaimDate == yesterday or profile.dailyRewards.lastClaimDate == "" then
		-- Continue streak
		profile.dailyRewards.streak = (profile.dailyRewards.streak or 0) + 1
	else
		-- Reset streak
		profile.dailyRewards.streak = 1
	end

	-- Cap at 7 (cycle)
	local streak = math.min(profile.dailyRewards.streak, 7)
	profile.dailyRewards.lastClaimDate = today

	-- Calculate reward index (1-based)
	local rewardIndex = ((streak - 1) % 7) + 1
	local reward = DAILY_REWARDS[rewardIndex]

	if not reward then
		return nil, "Invalid reward."
	end

	-- Apply reward
	local playerManager = require(script.Parent.PlayerManager)

	if reward.rewardType == "energy" then
		playerManager.AddEnergy(player, reward.amount)
		playerManager.SaveData(player, profile)

	elseif reward.rewardType == "essence" then
		playerManager.AddEssence(player, reward.amount)
		playerManager.SaveData(player, profile)

	elseif reward.rewardType == "egg" then
		-- Store premium egg token in profile
		if not profile.premiumEggs then profile.premiumEggs = {} end
		table.insert(profile.premiumEggs, reward.eggRarity)
		playerManager.SaveData(player, profile)

	elseif reward.rewardType == "boost" then
		if not profile.boosts then profile.boosts = {} end
		profile.boosts.luckBoostEnds = os.time() + (15 * 60) -- 15 minutes
		playerManager.SaveData(player, profile)
	end

	-- Track claimed day
	if not profile.dailyRewards.claimedDays then
		profile.dailyRewards.claimedDays = {}
	end
	profile.dailyRewards.claimedDays[today] = true

	-- Update leaderstats
	playerManager.UpdateLeaderstats(player, profile)
	playerManager.SaveData(player, profile)

	-- Send result to client
	local remote = ReplicatedStorage.MonsterMash.RemoteEvents:FindFirstChild("DailyRewardResult")
	if remote then
		remote:FireClient(player, {
			day = streak,
			reward = reward,
			streak = profile.dailyRewards.streak,
		})
	end

	return {
		day = streak,
		reward = reward,
		streak = profile.dailyRewards.streak,
	}, nil
end

--[[ Get full daily rewards status for the player ]]
function DailyRewardsSystem.GetRewardStatus(player)
	local profile = require(script.Parent.PlayerManager).PlayerData[player.UserId]
	if not profile then
		return {
			streak = 0,
			canClaimToday = true,
			rewards = DAILY_REWARDS,
		}
	end

	if not profile.dailyRewards then
		profile.dailyRewards = {
			streak = 0,
			lastClaimDate = "",
			claimedDays = {},
		}
	end

	local today = os.date("%Y-%m-%d", os.time())
	local alreadyClaimed = profile.dailyRewards.lastClaimDate == today

	return {
		streak = profile.dailyRewards.streak or 0,
		canClaimToday = not alreadyClaimed,
		rewards = DAILY_REWARDS,
		lastClaimDate = profile.dailyRewards.lastClaimDate,
	}
end

--[[ Get the list of daily rewards ]]
function DailyRewardsSystem.GetRewardList()
	return DAILY_REWARDS
end

return DailyRewardsSystem