local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerData = require(ServerScriptService.PlayerData.Manager)
local AchievementsConfig = require(ReplicatedStorage.Configs.Achievements)

local AchievementsManager = require(ServerScriptService.Achievements)
local IslandsConfig = require(ReplicatedStorage.Configs.Islands)
local Remotes = ReplicatedStorage.Remotes

local Islands = {}

local function AwardBadge(player: Player, island: string)
	local profile = PlayerData.Profiles[player]
	if not profile then return "No profile found!" end
	
	local number = table.find(IslandsConfig.IslandOrder, island)
	if not number then return end
	
	local badge = `Island #{number - 1}`
	PlayerData.GiveBadge(player, badge)
end

function Islands.UnlockIsland(player: Player, island: string, useCurrency: boolean)
	local profile = PlayerData.Profiles[player]
	if not profile then return "No profile found!" end

	local islandInfo = IslandsConfig.Config[island]
	if not islandInfo then return "No Island found!" end

	local islandRequirement = islandInfo.Requirement
	if islandRequirement then
		local isPreviousUnlocked = IslandsConfig.IsIslandUnlocked(profile.Data, islandRequirement)
		if not isPreviousUnlocked then return "Unlock previous Island first!" end 
	end

	local achievementId = AchievementsConfig.GetFirstAvailableAchievementId("Islands", profile.Data)
	if achievementId then
		local config = AchievementsConfig.GetAchievementConfig("Islands", achievementId)
		if config and config.Island == island then
			AchievementsManager.AddPoint(player, "Islands", achievementId)
		end
	end

	local isUnlocked = IslandsConfig.IsIslandUnlocked(profile.Data, island)
	if isUnlocked then return "Already Unlocked!" end

	if useCurrency then
		local price = islandInfo.Price
		if price > profile.Data.Pi then return "Not enough!" end
		PlayerData.AdjustPi(player, -price)
	end 

	profile.Data.Islands[island] = true
	Remotes.UpdateIsland:FireClient(player, island, true)
	AwardBadge(player, island)
	return "Island Unlocked!" 
end

Remotes.PurchaseIsland.OnServerEvent:Connect(function(player, island)
	Islands.UnlockIsland(player, island, true)
end)

return Islands
