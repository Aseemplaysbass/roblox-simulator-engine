local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Template = require(ReplicatedStorage.PlayerData.Template)
local Manager = require(ServerScriptService.PlayerData.Manager)
local ProfileService = require(ServerScriptService.Libs.ProfileService)

local ProfileStore = ProfileService.GetProfileStore("Test62", Template)

local KICK_MESSAGE = "Data issue, try again shortly. If issue persists, contact us!"

local function CreateLeaderstats(player: Player)
	local profile = Manager.Profiles[player]
	if not profile then return end

	local leaderstats = Instance.new("Folder", player)
	leaderstats.Name = "leaderstats"

	local pi = Instance.new("NumberValue", leaderstats)
	pi.Name = "Pi"
	pi.Value = profile.Data.Pi

	local sigma = Instance.new("NumberValue", leaderstats)
	sigma.Name = "Sigma"
	sigma.Value = profile.Data.Sigma
	
	local Ascensions = Instance.new("NumberValue", leaderstats)
	Ascensions.Name = "Ascensions"
	Ascensions.Value = profile.Data.Ascensions
end

local function LoadProfile(player: Player)
	local profile = ProfileStore:LoadProfileAsync("Player_"..player.UserId)
	if not profile then
		player:Kick(KICK_MESSAGE)
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()
	profile:ListenToRelease(function()
		Manager.Profiles[player] = profile
		player:Kick(KICK_MESSAGE)
	end)

	if player:IsDescendantOf(Players) == true then
		Manager.Profiles[player] = profile
		CreateLeaderstats(player)
		Manager.ProfileLoaded:Fire(player, profile.Data)
		
		Manager.GiveBadge(player, "Join the Adventure")
	else
		profile:Release()
	end
end

for _, player in Players:GetPlayers() do
	task.spawn(LoadProfile, player)
end

Players.PlayerAdded:Connect(LoadProfile)
Players.PlayerRemoving:Connect(function(player)
	local profile = Manager.Profiles[player]
	if profile then
		profile.Data.Offline = os.time()
		profile:Release()
	end
end)
