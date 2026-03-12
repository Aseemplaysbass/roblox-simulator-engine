local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BadgeService = game:GetService("BadgeService")

local BadgesConfig = require(ReplicatedStorage.Configs.Badges)
local Leaderboards = require(script.Parent.Parent.Leaderboards)
--local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)

local Remotes = ReplicatedStorage.Remotes	

local Manager = {}

Manager.Profiles = {}

Manager.ProfileLoaded = Instance.new("BindableEvent") 

function Manager.AdjustAscensions(player: Player, amount: number)
	local profile = Manager.Profiles[player]
	if not profile then return end
	profile.Data.Ascensions += amount
	player.leaderstats.Ascensions.Value = profile.Data.Ascensions
	Remotes.UpdateAscensions:FireClient(player, profile.Data.Ascensions)
	Leaderboards.AdjustLeaderboard(player, amount, "Ascensions")
end
function Manager.AdjustSigma(player: Player, amount: number)
	local profile = Manager.Profiles[player]
	if not profile then return end
	profile.Data.Sigma += amount
	player.leaderstats.Sigma.Value = profile.Data.Sigma
	Remotes.UpdateSigma:FireClient(player, profile.Data.Sigma)
	Leaderboards.AdjustLeaderboard(player, amount, "Sigma")
end
function Manager.AdjustPi(player: Player, amount: number)
	local profile = Manager.Profiles[player]
	if not profile then return end
	profile.Data.Pi += amount
	player.leaderstats.Pi.Value = profile.Data.Pi
	Remotes.UpdatePi:FireClient(player, profile.Data.Pi)
	Leaderboards.AdjustLeaderboard(player, amount, "Pi")
end
function Manager.AdjustDPS(player: Player, amount: number)
	local profile = Manager.Profiles[player]
	if not profile then return end
	profile.Data.DPS += amount
	Remotes.UpdateDPS:FireClient(player, profile.Data.DPS)
end

function Manager.GiveBadge(player: Player, badge: BadgesConfig.Badge)
	local profile = Manager.Profiles[player]
	if not profile then return end
	
	local badgeInfo = BadgesConfig.GetConfigFromName(badge)
	if not badgeInfo then return end
	
	local badgeId = badgeInfo.Id
	
	BadgeService:AwardBadge(player.UserId, badgeId)
	profile.Data.Badges[badgeId] = true
	Remotes.UpdateBadge:FireClient(player, badgeId)
end
--function Manager.AdjustHatches(player: Player, Amount: number)
--	local profile = Manager.Profiles[player]
--	if not profile then return end
--	profile.Data.Hatches += Amount
--	player.leaderstats.Hatches.Value = profile.Data.Hatches
--end

local function GetData(player: Player, directory: string)
	local profile = Manager.Profiles[player]
	if not profile then return end
	return profile.Data[directory]	
end

local function GetAutoClickMode(player: Player, ButtonType: "Fast" | "Regular")
	local profile = Manager.Profiles[player]
	if not profile then return end
	return profile.Data.Auto[ButtonType].Active
end

local function GetAllData(player: Player)
	local profile = Manager.Profiles[player]
	if not profile then return end
	return profile.Data
end

Remotes.GetData.OnServerInvoke = GetData
Remotes.GetAutoClickMode.OnServerInvoke = GetAutoClickMode
Remotes.GetAllData.OnServerInvoke = GetAllData

return Manager
