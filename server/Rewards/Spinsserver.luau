local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerData = require(ServerScriptService.PlayerData.Manager)
local PetsManager = require(ServerScriptService.Pets)
local SpinsConfig = require(ReplicatedStorage.Configs.Spins)

local Remotes = ReplicatedStorage.Remotes

local Spins = {}

function Spins.Spin(player: Player, wasDevProduct: boolean?)
	local profile = PlayerData.Profiles[player]
	if not profile then return end
	
	local rewardNum = math.random(1, 7)
	local reward = SpinsConfig.Rewards[rewardNum]
	
	local isPiReward = string.find(reward, "Pi")
	local isSigmaReward = string.find(reward, "Sigma")
	if isPiReward or isSigmaReward then
		local rewardAmount = SpinsConfig.GetRewardAmount(player, reward, profile.Data)
		if isPiReward then
			PlayerData.AdjustPi(player, rewardAmount)
		else
			PlayerData.AdjustSigma(player, rewardAmount)
		end
	else
		local pet = SpinsConfig.GetRewardPet(reward)
		local instance = PetsManager.CreatePet(pet.Name, pet.Rarity, pet.Upgrade)
		PetsManager.GivePet(player, instance, true)
	end
	
	if wasDevProduct then
		Remotes.BuyWheelSpin:FireClient(player, reward)
	end
	
	return reward
end

local function TryToSpin(player: Player)
	local profile = PlayerData.Profiles[player]
	if not profile then return end
	
	local nextFreeSpin = profile.Data.WheelSpin
	local isFreeSpinAvailable = os.time() > nextFreeSpin
	if not isFreeSpinAvailable then return end
	
	profile.Data.WheelSpin = os.time() + 24 * 60 * 60
	Remotes.UpdateWheelSpin:FireClient(player, profile.Data.WheelSpin)
	
	return Spins.Spin(player)
end

Remotes.SpinWheel.OnServerInvoke = TryToSpin

return Spins
