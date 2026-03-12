local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage.Remotes
local PlayerData = require(ServerScriptService.PlayerData.Manager)
local IslandsConfig = require(ReplicatedStorage.Configs.Islands)

local debounce = {}

local function CollectChest(player: Player, chest: Model)
	if debounce[player] then return end

	local profile = PlayerData.Profiles[player]
	if not profile then return end

	local island = chest.Parent.Name
	local isIslandUnlocked = IslandsConfig.IsIslandUnlocked(profile.Data, island)
	if not isIslandUnlocked then return end

	local playerCooldown = profile.Data.Chests[island]
	if playerCooldown and playerCooldown > os.time() then return end

	local cooldown = chest:GetAttribute("cooldown")
	local currency = chest:GetAttribute("currency")
	local reward = chest:GetAttribute("reward")

	if currency == "Pi" then
		PlayerData.AdjustPi(player, reward)
	elseif currency == "Sigma" then
		PlayerData.AdjustSigma(player, reward)
	elseif currency == "Ascensions" then
		PlayerData.AdjustAscensions(player, reward)
	end

	profile.Data.Chests[island] = os.time() + cooldown
	Remotes.UpdateChest:FireClient(player, island, profile.Data.Chests[island])
	debounce[player] = true
	task.delay(0.5, function()
		debounce[player] = nil
	end)
end

local function CreateChestListener()
	for _, descendant in Workspace.Islands:GetDescendants() do
		if descendant.Name ~= "Chest" then continue end

		local touchPart = descendant.Hitbox
		touchPart.Touched:Connect(function(otherPart)
			local player = Players:GetPlayerFromCharacter(otherPart.Parent)
			if player then
				CollectChest(player, descendant)
			end
		end)

	end
end

CreateChestListener()