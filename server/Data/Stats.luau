local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local ServerScriptService = game:GetService("ServerScriptService")
--local Workspace = game:GetService("Workspace")

local PetsConfig = require(ReplicatedStorage.Configs.Pets)
local AchievementsConfig = require(ReplicatedStorage.Configs.Achievements)
local ShopConfig = require(ReplicatedStorage.Configs.Shop)
local BoostsConfig = require(ReplicatedStorage.Configs.Boosts)
local HatchGoalConfig = require(ReplicatedStorage.Configs.HatchGoal)
local IslandsConfig = require(ReplicatedStorage.Configs.Islands)

local Stats = {}

function Stats.PiMultiplier(player: Player, playerData)
	local Ascensions = playerData.Ascensions
	

	local PetMultiplier = PetsConfig.GetEquippedPi(playerData)
	local DefaultMultiplier = 0.2
	local IslandMultiplier = 1
	local AscensionMultiplier = Ascensions / 6.9
	
	local AchievementMultipliers = AchievementsConfig.GetMultipliers("Pi", playerData)
	if AchievementMultipliers == 0 then AchievementMultipliers = 1 end

	local Multiplier = ((PetMultiplier + DefaultMultiplier) * IslandMultiplier + AscensionMultiplier) * ((AchievementMultipliers + 100) / 100)
	
	local ownsGamepass = ShopConfig.DoesPlayerOwnGamepass("2x Pi", playerData)
	if ownsGamepass then 
		Multiplier *= 2
	end
	local hasBoost = BoostsConfig.HasBoost("2x Pi", playerData)
	if hasBoost then
		Multiplier += 2
	end
	local hasHatchBoost = HatchGoalConfig.IsBoostActive("2x Pi")
	if hasHatchBoost > 0 then
		Multiplier *= 2
	end
	local islandMultiplier = IslandsConfig.GetIslandBoost(playerData.CurrentIsland)
	if islandMultiplier > 0 then
		Multiplier *= islandMultiplier
	end

	return Multiplier
end

function Stats.SigmaMultiplier(player: Player, playerData)
	local multiplier =  1
	
	local ownsGamepass = ShopConfig.DoesPlayerOwnGamepass("2x Sigma", playerData)
	if ownsGamepass then 
		multiplier += 1
	end
	local hasBoost = BoostsConfig.HasBoost("2x Sigma", playerData)
	if hasBoost then
		multiplier += 1
	end
	local hasHatchBoost = HatchGoalConfig.IsBoostActive("2x Sigma")
	multiplier += 1

	return multiplier
end

function Stats.DPSMultiplier(player: Player, playerData)
	local Ascensions = playerData.Ascensions

	local PetMultiplier = PetsConfig.GetEquippedDPS(playerData)
	local DefaultMultiplier = 0.5
	local IslandMultiplier = 1
	local AscensionMultiplier = Ascensions

	local Multiplier = (PetMultiplier + DefaultMultiplier) * IslandMultiplier + AscensionMultiplier

	return Multiplier
end

function Stats.LuckMultiplier(playerData)
	local multiplier = 1
	
	local ownsVIPGamepass = ShopConfig.DoesPlayerOwnGamepass("VIP", playerData)
	if ownsVIPGamepass then
		multiplier += 0.50
	end
	
	local ownsLuckyGamepass = ShopConfig.DoesPlayerOwnGamepass("Lucky", playerData)
	if ownsLuckyGamepass then
		multiplier += 0.15
	end
	
	local ownsSuperLuckyGamepass = ShopConfig.DoesPlayerOwnGamepass("Super Lucky", playerData)
	if ownsSuperLuckyGamepass then
		multiplier += 0.30
	end
	
	local hasBoost = BoostsConfig.HasBoost("2x Luck", playerData)
	if hasBoost then
		multiplier += 1
	end
	local hasHatchBoost = HatchGoalConfig.IsBoostActive("2x Luck")
	multiplier += 1
	
	return multiplier
end

return Stats
