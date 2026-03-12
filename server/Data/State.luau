local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Template = require(ReplicatedStorage:WaitForChild("PlayerData"):WaitForChild("Template"))

local IsDataLoaded = false

local PlayerData: Template.PlayerData

local function LoadData()
	if IsDataLoaded then return end

	while not PlayerData do
		PlayerData = Remotes.GetAllData:InvokeServer()
		task.wait(1)
	end

	IsDataLoaded = true
end

LoadData()

local State = {}

function State:GetData(): Template.PlayerData
	while not IsDataLoaded do
		task.wait(0.5)
	end

	return PlayerData
end

Remotes.UpdatePi.OnClientEvent:Connect(function(amount)
	PlayerData.Pi = amount
end)
Remotes.UpdateDPS.OnClientEvent:Connect(function(amount)
	PlayerData.DPS = amount
end)
Remotes.UpdateSigma.OnClientEvent:Connect(function(amount)
	PlayerData.Sigma = amount
end)
Remotes.UpdateAscensions.OnClientEvent:Connect(function(amount)
	PlayerData.Ascensions = amount
end)

Remotes.UpdateAscensionButton.OnClientEvent:Connect(function(ascension: string, isUnlocked: boolean)
	PlayerData.AscensionButtons[ascension] = isUnlocked
end)

Remotes.UpdateAutoClicker.OnClientEvent:Connect(function(autoClicker: "Regular" | "Fast", mode: boolean)
	PlayerData.Auto[autoClicker].Active = mode
end)

Remotes.UpdateIsland.OnClientEvent:Connect(function(island: string, unlocked: boolean)
	PlayerData.Islands[island] = unlocked
end)

Remotes.UpdateChest.OnClientEvent:Connect(function(island: string, cooldown: number)
	PlayerData.Chests[island] = cooldown
end)

Remotes.Pets.GivePet.OnClientEvent:Connect(function(petInstance)
	PlayerData.Pets[petInstance.UUID] = petInstance
end)

Remotes.Pets.DeletePet.OnClientEvent:Connect(function(uuid)
	PlayerData.Pets[uuid] = nil
end)

Remotes.Pets.EquipPet.OnClientEvent:Connect(function(uuid)
	PlayerData.Pets[uuid].Equipped = true
end)

Remotes.Pets.UnequipPet.OnClientEvent:Connect(function(uuid)
	PlayerData.Pets[uuid].Equipped = false
end)

Remotes.Pets.LockPet.OnClientEvent:Connect(function(uuid)
	PlayerData.Pets[uuid].Locked = true
end)
Remotes.Pets.UnlockPet.OnClientEvent:Connect(function(uuid)
	PlayerData.Pets[uuid].Locked = false
end)
Remotes.Pets.RenamePet.OnClientEvent:Connect(function(uuid: string, name: string)
	PlayerData.Pets[uuid].Name = name
end)
Remotes.Pets.UpdatePetXP.OnClientEvent:Connect(function(uuid: string, xp: number)
	PlayerData.Pets[uuid].Experience = xp
end)
Remotes.Pets.UpdatePetLevel.OnClientEvent:Connect(function(uuid: string, level: number)
	PlayerData.Pets[uuid].Level = level
end)
Remotes.Pets.UpgradePet.OnClientEvent:Connect(function(uuid: string, upgrade: string)
	PlayerData.Pets[uuid][upgrade] = true
end)
Remotes.Pets.RainbowPet.OnClientEvent:Connect(function(pet, time: number)
	PlayerData.PetRainbow[pet.UUID] = pet
end)
Remotes.Pets.ClaimRainbowPet.OnClientEvent:Connect(function(uuid: string)
	PlayerData.PetRainbow[uuid] = nil
end)
Remotes.Pets.EnchantPet.OnClientEvent:Connect(function(uuid: string, enchantment: string, level: number)
	PlayerData.Pets[uuid].Enchantment = {
		Enchantment = enchantment,
		Level = level
	}
end)

Remotes.Eggs.AutoDeletePet.OnClientEvent:Connect(function(egg: string, pet: string, isSelected: boolean)
	PlayerData.AutoDeletePets[egg][pet] = isSelected
end)

Remotes.Pets.IndexPet.OnClientEvent:Connect(function(pet: string)
	PlayerData.PetIndex[pet] = true
end)

Remotes.Pets.DepositPets.OnClientEvent:Connect(function(pets)
	for uuid, petInstance in pets do
		PlayerData.PetBank[uuid] = petInstance
	end
end)
Remotes.Pets.WithdrawPets.OnClientEvent:Connect(function(pets)
	for uuid, petInstance in pets do
		PlayerData.PetBank[uuid] = nil
	end
end)

Remotes.PurchaseAscensionItem.OnClientEvent:Connect(function(mode: string, area: string, item: string)
	if mode == "Button" then 
		PlayerData.AscensionShop[area][item] = true
	else
		PlayerData.AscensionShop[area][item] -= 1
	end
end)

Remotes.UpdateAchievement.OnClientEvent:Connect(function(group: string, id: string, amount: number)
	PlayerData.Achievements[group][id].Progress = amount
end)
Remotes.ClaimAchievement.OnClientEvent:Connect(function(group: string, id: string)
	PlayerData.Achievements[group][id].Claimed = true
end)

Remotes.UpdateGamepass.OnClientEvent:Connect(function(id: number, wasPurchased: boolean)
	PlayerData.Gamepasses[id] = wasPurchased
end)

Remotes.UpdateWheelSpin.OnClientEvent:Connect(function(cooldown: number)
	PlayerData.WheelSpin = cooldown
end)

Remotes.UpdateBoost.OnClientEvent:Connect(function(boost: string, duration: number)
	PlayerData.Boosts[boost] = duration
end)

Remotes.UpdateCode.OnClientEvent:Connect(function(code: string)
	PlayerData.Codes[code] = true
end)

Remotes.UpdateSetting.OnClientEvent:Connect(function(setting: string, newValue: boolean)
	PlayerData.Settings[setting] = newValue
end)

Remotes.UpdateBadge.OnClientEvent:Connect(function(badgeId: number)
	PlayerData.Badges[badgeId] = true
end)

Remotes.UpdateCurrentIsland.OnClientEvent:Connect(function(island: string)
	PlayerData.CurrentIsland = island
end)

Remotes.Trade.ToggleRequests.OnClientEvent:Connect(function(value: boolean)
	PlayerData.ReceiveTradeRequests = value
end)

return State
