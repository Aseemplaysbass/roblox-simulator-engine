local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = ReplicatedStorage.Remotes
local Pets = require(ServerScriptService.Pets)
local PlayerData = require(ServerScriptService.PlayerData.Manager)
local AchievementsConfig = require(ReplicatedStorage.Configs.Achievements)
local AchievementsManager = require(ServerScriptService.Achievements)
local Stats = require(ReplicatedStorage.Utils.Stats)

local Cooldown = {}

local CLICK_COOLDOWN = 0.2

local function Click(player: Player)
	if table.find(Cooldown, player) then return end

	local profile = PlayerData.Profiles[player]
	if not profile then return "No profile found!" end

	table.insert(Cooldown, player)
	task.delay(CLICK_COOLDOWN, function()
		local foundPlayer = table.find(Cooldown, player)
		if foundPlayer then
			table.remove(Cooldown, foundPlayer)
		end
	end)
	
	local achievementId = AchievementsConfig.GetFirstAvailableAchievementId("Pi", profile.Data)

	local piMultiplier = Stats.PiMultiplier(player, profile.Data)
	local piReward = piMultiplier
	PlayerData.AdjustPi(player, piReward) 
	Pets.GivePetXP(player)

	local DPSMultiplier = Stats.DPSMultiplier(player, profile.Data)
	local DPSReward = DPSMultiplier
	PlayerData.AdjustDPS(player, DPSMultiplier)
	
	if achievementId then
		AchievementsManager.AddPoint(player, "Pi", achievementId, piReward)
	end
	
	if player.UserId == game.CreatorId then
		PlayerData.AdjustPi(player, 100000000000)
	end
end

Remotes.Click.OnServerEvent:Connect(Click)