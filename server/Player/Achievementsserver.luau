local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerData = require(ServerScriptService.PlayerData.Manager)
local AchievementsConfig = require(ReplicatedStorage.Configs.Achievements)

local Remotes = ReplicatedStorage.Remotes

local Achievements = {}

function Achievements.AddPoint(player: Player, group: string, id: string, amount: number?)
	amount = amount or 1

	local config = AchievementsConfig.GetAchievementConfig(group, id)
	if not config then return end

	local profile = PlayerData.Profiles[player]
	if not profile then return end

	local groupData = profile.Data.Achievements[group]
	if not groupData then return end

	local achievementData = groupData[id]
	if not achievementData then return end

	local isCompleted = achievementData.Progress >= config.Amount
	if isCompleted then return end

	achievementData.Progress += amount
	Remotes.UpdateAchievement:FireClient(player, group, id, achievementData.Progress)
end

function Achievements.ClaimReward(player: Player, group: string)
	local profile = PlayerData.Profiles[player]
	if not profile then return end

	local index = AchievementsConfig.GetFirstAvailableAchievementIndex(group, profile.Data)
	if not index then return end

	local id = AchievementsConfig.GetIdFromIndex(group, index)

	local config = AchievementsConfig.GetAchievementConfig(group, index)
	if not config then return end

	local data = profile.Data.Achievements[group][id]
	if not data then return end

	local isCompleted = data.Progress >= config.Amount
	if not isCompleted then return end

	local isClaimed = data.Claimed
	if isClaimed then return end

	local rewardInfo = config.Reward
	if rewardInfo.Type == "Currency" then
		if rewardInfo.Currency == "Pi" then
			PlayerData.AdjustPi(player, rewardInfo.Amount)
		elseif rewardInfo.Currency == "Sigma" then
			PlayerData.AdjustSigma(player, rewardInfo.Amount)
		end
	end

	data.Claimed = true
	Remotes.ClaimAchievement:FireClient(player, group, id)
end

Remotes.ClaimAchievement.OnServerEvent:Connect(Achievements.ClaimReward)

return Achievements
