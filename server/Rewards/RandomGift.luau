local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = ReplicatedStorage.Remotes
local PlayerData = require(ServerScriptService.PlayerData.Manager)

local GIFT_COOLDOWN = 600
local PI_PER_ASCENSION = 969

local function GiveGift(player: Player, playerData)
	local reward = PI_PER_ASCENSION * playerData.Ascensions
	reward = if reward > 0 then reward else PI_PER_ASCENSION

	PlayerData.AdjustPi(player, reward)
	playerData.RandomGift = os.time() + GIFT_COOLDOWN
	Remotes.RandomGift:FireClient(player, reward)
end

task.spawn(function()
	while true do
		for _, player in Players:GetPlayers() do
			local profile = PlayerData.Profiles[player]
			if not profile then continue end

			local lastGiftTime = profile.Data.RandomGift
			if lastGiftTime + GIFT_COOLDOWN > os.time() then continue end

			GiveGift(player, profile.Data)
		end
		task.wait(1)

	end
end)
