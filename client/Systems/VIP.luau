local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerData = require(ServerScriptService.PlayerData.Manager)
local ShopConfig = require(ReplicatedStorage.Configs.Shop)

local Remotes = ReplicatedStorage.Remotes

local vipPlayers = {}

PlayerData.ProfileLoaded.Event:Connect(function(player: Player, data)
	local ownsGamepass = ShopConfig.DoesPlayerOwnGamepass("VIP", data)
	if ownsGamepass then
		table.insert(vipPlayers, player.UserId)
		Remotes.VIPJoined:FireAllClients(player.UserId)
	end
end)

Players.PlayerRemoving:Connect(function(player: Player)
	local index = table.find(vipPlayers, player.UserId)
	if index then
		table.remove(vipPlayers, index)
	end
end)

Remotes.GetVIPs.OnServerInvoke = function()
	return vipPlayers
end
