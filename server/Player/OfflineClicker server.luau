local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local OfflineClicker = require(ReplicatedStorage.Configs.OfflineClicker)
local PlayerData = require(ServerScriptService.PlayerData.Manager)

local function CollectPi(player: Player, data)
	local firstLogin = data.Offline == 0
	if firstLogin then return end
	
	local pi = OfflineClicker.CalculateOfflinePi(player, data)
	PlayerData.AdjustPi(player, pi)
end

PlayerData.ProfileLoaded.Event:Connect(CollectPi)