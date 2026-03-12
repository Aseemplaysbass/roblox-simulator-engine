local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerData = require(ReplicatedStorage.PlayerData.Template)
local ShopConfig = require(ReplicatedStorage.Configs.Shop)

local DEFAULT_MAX_SLOTS = 50 

local PetBank = {}

function PetBank.GetAmountOfStoredPets(data: PlayerData.PlayerData)
	local amount = 0

	for uuid, petInstance in data.PetBank do
		amount += 1
	end

	return amount
end

function PetBank.GetMaxSlots(player: Player, data: PlayerData.PlayerData)
	local amount = DEFAULT_MAX_SLOTS

	local hasGamepass = ShopConfig.DoesPlayerOwnGamepass("+25 Pet Bank Storage", data)
	if hasGamepass then
		amount += 25
	end
	
	return amount
end

function PetBank.GetOpenSlots(player: Player, data: PlayerData.PlayerData)
	local usedSlots = PetBank.GetAmountOfStoredPets(data)
	local maxSlots = PetBank.GetMaxSlots(player, data)

	return maxSlots - usedSlots
end

return PetBank
