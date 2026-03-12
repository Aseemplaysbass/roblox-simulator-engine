--DPS = CLICKS AND AUTO = PI REMEMBER
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
--local Player = game.Players.LocalPlayer

local AchievementsConfig = require(ReplicatedStorage.Configs.Achievements)
local ShopConfig = require(ReplicatedStorage.Configs.Shop)

export type PetUpgrade = "Shiny" | "Golden" | "Rainbow" | "Aurora"

export type PetInstance = {
	UUID: string,
	Name: string,
	Model: string, 
	Rarity: string,

	Level: number,
	Experience: number,

	Equipped: boolean,
	Locked: boolean, 

	Shiny: boolean,
	Golden: boolean,
	Rainbow: boolean,
	Aurora: boolean,

	RainbowTime: number?,

	Enchantment: {
		Enchantment: string,
		Level: number
	}
}

type PetConfig = {
	DPS: number, 
	Pi: number,

	MaxLevel: number,
	DPSPerLevel: number,
	PiPerLevel: number
}

local Config: { [string]: PetConfig } = {
	Rooster = {
		DPS = 6/3,
		Pi = 6/10,
		MaxLevel = 5,
		DPSPerLevel = ((6/3)*2)/5,
		PiPerLevel = (6/10)/5,
		Rarity = "Common",
	},
	Tortoise = {
		DPS = 13/3,
		Pi = 13/20,
		MaxLevel = 10,
		DPSPerLevel = ((13/3)*2)/10,
		PiPerLevel = (13/20)/10,
		Rarity = "Uncommon",
	},
	Petasus = {
		DPS = 66/3,
		Pi = 66/30,
		MaxLevel = 15,
		DPSPerLevel = ((66/3)*2)/15,
		PiPerLevel = (66/30)/15,
		Rarity = "Rare",
	},
	Kithara = {
		DPS = 665/3,
		Pi = 665/40,
		MaxLevel = 20,
		DPSPerLevel = ((665/3)*2)/20,
		PiPerLevel = (665/40)/20,
		Rarity = "Epic",
	},
	Caduceus = {
		DPS = 1330/3,
		Pi = 1330/50,
		MaxLevel = 25,
		DPSPerLevel = ((1330/3)*2)/25,
		PiPerLevel = (1330/50)/25,
		Rarity = "Legendary",
	},
	Hermes = {
		DPS = 6654/3,
		Pi = 6654/60,
		MaxLevel = 30,
		DPSPerLevel = ((6654/3)*2)/30,
		PiPerLevel = (6654/60)/30,
		Rarity = "Mythical",
	},
	Mercury = {
		DPS = 13308/3,
		Pi = 13308/70,
		MaxLevel = 35,
		DPSPerLevel = ((13308/3)*2)/35,
		PiPerLevel = (13308/70)/35,
		Rarity = "Unique",
	},
	Venera14 = {
		DPS = 66542/3,
		Pi = 66542/80,
		MaxLevel = 40,
		DPSPerLevel = ((66542/3)*2)/40,
		PiPerLevel = (66542/80)/40,
		Rarity = "Exalted",
	},

	Seashell = {
		DPS = 149/3,
		Pi = 149/10,
		MaxLevel = 5,
		DPSPerLevel = ((149/3)*2)/5,
		PiPerLevel = (149/10)/5,
		Rarity = "Common",
	},
	Anemone = {
		DPS = 298/3,
		Pi = 298/20,
		MaxLevel = 10,
		DPSPerLevel = ((298/3)*2)/10,
		PiPerLevel = (298/20)/10,
		Rarity = "Uncommon",
	},
	Narcissus = {
		DPS = 1492/3,
		Pi = 1492/30,
		MaxLevel = 15,
		DPSPerLevel = ((1492/3)*2)/15,
		PiPerLevel = (1492/30)/15,
		Rarity = "Rare",
	},
	Pearl = {
		DPS = 2985/3,
		Pi = 2985/40,
		MaxLevel = 20,
		DPSPerLevel = ((2985/3)*2)/20,
		PiPerLevel = (2985/40)/20,
		Rarity = "Epic",
	},
	Rose = {
		DPS = 14926/3,
		Pi = 14926/50,
		MaxLevel = 25,
		DPSPerLevel = ((14926/3)*2)/25,
		PiPerLevel = (14926/50)/25,
		Rarity = "Legendary",
	},
	Mirror = {
		DPS = 28859/3,
		Pi = 28859/60,
		MaxLevel = 30,
		DPSPerLevel = ((28859/3)*2)/30,
		PiPerLevel = (28859/60)/30,
		Rarity = "Mythical",
	},
	Venus = {
		DPS = 298598/3,
		Pi = 298598/70,
		MaxLevel = 35,
		DPSPerLevel = (298598/3*2)/35,
		PiPerLevel = (298598/70)/35,
		Rarity = "Unique",
	},
	Aphrodite = {
		DPS = 1492992/3,
		Pi = 1492992/80,
		MaxLevel = 40,
		DPSPerLevel = (1492992/3*2)/40,
		PiPerLevel = (1492992/80)/40,
		Rarity = "Eternal",
	},

	Cow = {
		DPS = 1484/3,
		Pi = 1484/10,
		MaxLevel = 5,
		DPSPerLevel = ((1484/3)*2)/5,
		PiPerLevel = (1484/10)/5,
		Rarity = "Common",
	},
	Oak = {
		DPS = 2968/3,
		Pi = 2968/20,
		MaxLevel = 10,
		DPSPerLevel = ((2968/3)*2)/10,
		PiPerLevel = (2968/20)/10,
		Rarity = "Uncommon",
	},
	Apple = {
		DPS = 14843/3,
		Pi = 14843/30,
		MaxLevel = 15,
		DPSPerLevel = ((14843/3)*2)/15,
		PiPerLevel = (14843/30)/15,
		Rarity = "Rare",
	},
	Lily = {
		DPS = 29687/3,
		Pi = 29687/40,
		MaxLevel = 20,
		DPSPerLevel = ((29687/3)*2)/20,
		PiPerLevel = (29687/40)/20,
		Rarity = "Epic",
	},
	Cornucopia = {
		DPS = 148437/3,
		Pi = 148437/50,
		MaxLevel = 25,
		DPSPerLevel = ((148437/3)*2)/25,
		PiPerLevel = (148437/50)/25,
		Rarity = "Legendary",
	},
	Terraucopia = {
		DPS = 492830/3,
		Pi = 492830/50,
		MaxLevel = 25,
		DPSPerLevel = ((492830/3)*2)/25,
		PiPerLevel = (492830/50)/25,
		Rarity = "Legendary",
	},
	Python = {
		DPS = 296875/3,
		Pi = 296875/60,
		MaxLevel = 30,
		DPSPerLevel = ((296875/3)*2)/30,
		PiPerLevel = (296875/60)/30,
		Rarity = "Mythical",
	},
	Shenron = {
		DPS = 985661/3,
		Pi = 985661/60,
		MaxLevel = 30,
		DPSPerLevel = ((985661/3)*2)/30,
		PiPerLevel = (985661/60)/30,
		Rarity = "Mythical",
	},
	Moon = {
		DPS = 593750/3,
		Pi = 593750/70,
		MaxLevel = 35,
		DPSPerLevel = ((593750/3)*2)/35,
		PiPerLevel = (593750/70)/35,
		Rarity = "Unique [ROBUX]",
	},
	Deer = {
		DPS = 1484375/3,
		Pi = 1484375/80,
		MaxLevel = 40,
		DPSPerLevel = ((1484375/3)*2)/40,
		PiPerLevel = (1484375/80)/40,
		Rarity = "Eternal",
	},
	Wendigo = {
		DPS = 4928307/3,
		Pi = 4928307/80,
		MaxLevel = 40,
		DPSPerLevel = ((4928307/3)*2)/40,
		PiPerLevel = (4928307/80)/40,
		Rarity = "Eternal",
	},
	Earth = {
		DPS = 1979166/3,
		Pi = 1979166/90,
		MaxLevel = 45,
		DPSPerLevel = ((1979166/3)*2)/45,
		PiPerLevel = (1979166/90)/45,
		Rarity = "Exalted [ROBUX]",
	},
	Gaia = {
		DPS = 2968750/3,
		Pi = 2968750/100,
		MaxLevel = 50,
		DPSPerLevel = ((2968750/3)*2)/50,
		PiPerLevel = (2968750/100)/50,
		Rarity = "Ancient",
	},
	Reaper = {
		DPS = 9856614/3,
		Pi = 9856614/100,
		MaxLevel = 50,
		DPSPerLevel = ((9856614/3)*2)/50,
		PiPerLevel = (9856614/100)/50,
		Rarity = "Ancient",
	},

	["Galactic Drone"] = {
		DPS = 985661/3,
		Pi = 985661/60,
		MaxLevel = 30,
		DPSPerLevel = ((985661/3)*2)/30,
		PiPerLevel = (985661/60)/30,
		Rarity = "Exclusive",
	},
	["Nebula Dragonling"] = {
		DPS = 4928307/3,
		Pi = 4928307/80,
		MaxLevel = 40,
		DPSPerLevel = ((4928307/3)*2)/40,
		PiPerLevel = (4928307/80)/40,
		Rarity = "Exclusive+",
	},
}

local DEFAULT_MAX_STORED_PETS = 69
local DEFAULT_MAX_EQUIPPED_PETS = 2

local AMOUNT_TO_SHINY = 4
local AMOUNT_TO_GOLDEN = 3

local DEFAULT_MAX_RAINBOWING_PETS = 5

local Pets = {}

Pets.Enchantments = {
	"DPS Boost",
	"Pi Boost",
	"Legendary Luck",
	"Mythical Luck",
	"Eternal Luck",
	"Ancient Luck"
}

Pets.EnchantmentChances = {
	["DPS Boost"] = 27,
	["Pi Boost"] = 23,
	["Legendary Luck"] = 19,
	["Mythical Luck"] = 15,
	["Eternal Luck"] = 11,
	["Ancient Luck"] = 5
}

Pets.EnchantmentColor = {
	["DPS Boost"] = Color3.fromRGB(0, 85, 255),
	["Pi Boost"] = Color3.fromRGB(85, 0, 255),
	["Legendary Luck"] = Color3.fromRGB(255, 255, 127),
	["Mythical Luck"] = Color3.fromRGB(255, 73, 73),
	["Eternal Luck"] = Color3.fromRGB(255, 255, 255),
	["Ancient Luck"] = Color3.fromRGB(0, 0, 0)
}

Pets.MaxEnchantmentLevel = 6
--"Unique"
--"Exalted"
--"Exotic"
--"Transcendant"
--"Heirloom"
--"Artifact"

Pets.MaxEnchantmentLevelChances = {
	[6] = 1,
	[5] = 3,
	[4] = 11,
	[3] = 17,
	[2] = 28,
	[1] = 40
}

Pets.MaxEnchantmentColor = {
	[6] = Color3.fromRGB(255, 85, 255),
	[5] = Color3.fromRGB(0, 255, 255),
	[4] = Color3.fromRGB(255, 0, 0),
	[3] = Color3.fromRGB(85, 85, 255),
	[2] = Color3.fromRGB(255, 85, 127),
	[1] = Color3.fromRGB(255, 255, 127)
}

Pets.XPPerLevel = 100
Pets.XPPerClick = 1

Pets.Config = Config

function Pets.GetConfig(pet: PetInstance): PetConfig
	return Pets.Config[pet.Model]
end

function Pets.GetModel(pet: PetInstance): Model
	local model = ReplicatedStorage.Pets:FindFirstChild(pet.Model):Clone()
	if not model then return "No such Pet exists!" end

	local currentUpgrade = Pets.GetCurrentUpgrade(pet)
	if not currentUpgrade then 
		return model
	end

	for _, descendants in model:GetDescendants() do
		if descendants:IsA("BasePart") then
			if currentUpgrade == "Aurora" then
				Pets.AuroraTween(descendants, 0.5)
				descendants.Material = Enum.Material.Neon
			elseif currentUpgrade == "Rainbow" then
				Pets.RainbowTween(descendants, 1)
			--elseif currentUpgrade == "Golden" then
			--	descendants.Color = Color3.fromRGB(255, 255, 0)
			--	descendants.Material = Enum.Material.Neon
			--elseif currentUpgrade == "Shiny" then
			--	descendants.Color = Color3.fromRGB(255, 85, 0)
			--	descendants.Material = Enum.Material.Neon
			end
		end
	end 

	return model
end

function Pets.CreateInstance(petInfo)
	local pet: PetInstance = {
		UUID = petInfo.UUID or "",
		Name = petInfo.Name or "Error",
		Model = petInfo.Model or petInfo.Name,
		Rarity = petInfo.Rarity or "Error",

		Level = petInfo.Level or 0,
		Experience = petInfo.Experience or 0,

		Equipped = petInfo.Equipped or false,
		Locked = petInfo.Locked or false,

		Shiny = petInfo.Shiny or false,
		Golden = petInfo.Golden or false,
		Rainbow = petInfo.Rainbow or false,
		Aurora = petInfo.Aurora or false,

		Enchantment = petInfo.Enchantment or {},
	}

	return pet
end

function Pets.GetEquippedDPS(data)
	local equippedPets = Pets.GetEquippedPets(data)
	local dps = 0
	for _, pet in equippedPets do
		dps += Pets.GetPetDPS(pet)
	end

	return dps
end

function Pets.GetEquippedPi(data)
	local equippedPets = Pets.GetEquippedPets(data)
	local Pi = 0
	for _, pet in equippedPets do
		Pi += Pets.GetPetPi(pet)
	end

	return Pi
end

function Pets.GetPetDPS(pet: PetInstance)
	local config = Pets.GetConfig(pet)
	local dpsPerLevel = config.DPSPerLevel or 1

	local dps = (dpsPerLevel * pet.Level) + config.DPS

	local currentUpgrade = Pets.GetCurrentUpgrade(pet)
	if currentUpgrade == "Shiny" then
		dps += dps * 0.27
	elseif currentUpgrade == "Golden" then
		dps += dps * 2.56
	elseif currentUpgrade == "Rainbow" then
		dps += dps * 31.25
	elseif currentUpgrade == "Aurora" then
		dps += dps * 466.56
	end

	local enchantment = pet.Enchantment.Enchantment
	if enchantment and enchantment == "DPS Boost" then
		dps += dps * tonumber(`0.{pet.Enchantment.Level}`)
	end

	return dps
end

function Pets.GetPetPi(pet: PetInstance)
	local config = Pets.GetConfig(pet)
	if not config.Pi then return 0 end

	local dpsPerLevel = config.DPSPerLevel or 1

	local Pi = (dpsPerLevel * pet.Level) + config.Pi

	local currentUpgrade = Pets.GetCurrentUpgrade(pet)
	if currentUpgrade == "Shiny" then
		Pi += Pi * 0.25
	elseif currentUpgrade == "Golden" then
		Pi += Pi * 1.25
	elseif currentUpgrade == "Rainbow" then
		Pi += Pi * 6.25
	elseif currentUpgrade == "Aurora" then
		Pi += Pi * 31.25
	end

	local enchantment = pet.Enchantment.Enchantment
	if enchantment and enchantment == "Pi Boost" then
		Pi += Pi * tonumber(`0.{pet.Enchantment.Level}`)
	end

	return Pi
end

function Pets.GetEquippedPets(data):{PetInstance}
	local equipped = {}
	for uuid, petInstance:PetInstance in data.Pets do
		if petInstance.Equipped then
			table.insert(equipped, petInstance)
		end
	end

	return equipped
end

function Pets.GetPetsXPRequirement(pet: PetInstance)
	local config = Pets.GetConfig(pet)
	if not config then return 0 end

	local maxLevel = config.MaxLevel
	local level = pet.Level
	if level == maxLevel then return 0 end

	return if level == 0 then Pets.XPPerLevel else level * Pets.XPPerLevel
end

function Pets.GetTotalStoredPets(data)
	local amount = 0
	for uuid, petInstance:PetInstance in data.Pets do
		amount += 1
	end

	return amount
end

function Pets.GetOpenSlots(player: Player, data)
	local usedSlots = Pets.GetTotalStoredPets(data)
	local maxSlots = Pets.GetMaxStoredPets(data)

	return maxSlots - usedSlots
end

function Pets.GetMaxStoredPets(data)
	local amount = DEFAULT_MAX_STORED_PETS
	
	local hasHunderedGamepass = ShopConfig.DoesPlayerOwnGamepass("+100 Pets Storage", data)
	if hasHunderedGamepass then
		amount += 100
	end
	
	local hasFiveHunderedGamepass = ShopConfig.DoesPlayerOwnGamepass("+500 Pets Storage", data)
	if hasFiveHunderedGamepass then
		amount += 500
	end

	local totalCollectedPets = Pets.GetTotalCollectedPets(data)

	if totalCollectedPets >= 20 then
		amount += 25
	end
	
	local achievementsMultiplier = AchievementsConfig.GetMultipliers("Pet Storage", data)
	amount += achievementsMultiplier

	--if Player and Player.leaderstats and Player.leaderstats.Hatches.Value >= 100 then
	--	Amount = Amount + 10
	--end

	--Gamepass
	return amount
end

function Pets.GetMaxEquippedPets(data)
	local amount = DEFAULT_MAX_EQUIPPED_PETS

	local totalCollectedPets = Pets.GetTotalCollectedPets(data)
	if totalCollectedPets >= 10 then
		amount += 1
	end
	
	local ownsOneGamepass = ShopConfig.DoesPlayerOwnGamepass("+1 Pet Equip", data)
	if ownsOneGamepass then
		amount += 1
	end
	
	local ownsTwoGamepass = ShopConfig.DoesPlayerOwnGamepass("+2 Pet Equip", data)
	if ownsOneGamepass then
		amount += 2
	end

	return amount
end

function Pets.GetTotalCollectedPets(data)
	local amount = 0
	for pet, owned in data.PetIndex do
		if owned then
			amount += 1
		end
	end

	return amount
end

function Pets.GetTotalPets(data)
	local amount = 0
	for pet, info in Config do
		amount += 1
	end

	return amount
end

function Pets.GetDuplicatePets(pet: PetInstance, data)
	local duplicatePets = {}
	for uuid, petInstance: PetInstance in data.Pets do
		if petInstance.Model ~= pet.Model or petInstance.Rarity ~= pet.Rarity then continue end
		if petInstance.Locked then continue end
		if (petInstance.Shiny and not pet.Shiny) or (petInstance.Golden and not pet.Golden) then continue end
		if (not petInstance.Shiny and pet.Shiny) or (not petInstance.Golden and pet.Golden) then continue end

		table.insert(duplicatePets, petInstance)
	end

	return duplicatePets
end

function Pets.GetCurrentUpgrade(pet: PetInstance): PetUpgrade?
	if pet.Aurora then
		return "Aurora"
	elseif pet.Rainbow then
		return "Rainbow"
	elseif pet.Golden then
		return "Golden"
	elseif pet.Shiny then
		return "Shiny"
	end

	return nil
end

function Pets.GetNextUpgrade(pet: PetInstance): "Max Upgraded" | "Shiny" | "Golden"
	local currentUpgrade = Pets.GetCurrentUpgrade(pet)
	if pet.Golden then
		return "Max Upgraded"
	elseif pet.Shiny then
		return "Golden"
	else 
		return "Shiny"
	end
end

function Pets.GetNextUpgradeCost(pet: PetInstance, data): number
	local nextUpgrade = Pets.GetNextUpgrade(pet)
	if nextUpgrade == "Golden" then
		return AMOUNT_TO_GOLDEN
	elseif nextUpgrade == "Shiny" then
		local amountToUpgrade = AMOUNT_TO_SHINY
		
		local hasGamepass = ShopConfig.DoesPlayerOwnGamepass("Better Shiny", data)
		if hasGamepass then
			amountToUpgrade -= 1
		end
		
		return amountToUpgrade
	else
		return 0
	end
end

function Pets.CanUpgradePet(pet: PetInstance, data)
	local nextUpgrade = Pets.GetNextUpgrade(pet)
	if nextUpgrade == "Max Upgraded" then return false end

	local duplicatedPets = Pets.GetDuplicatePets(pet, data)
	local nextUpgradeCost = Pets.GetNextUpgradeCost(pet, data)

	if nextUpgrade == "Shiny" and #duplicatedPets >= nextUpgradeCost then
		return true
	elseif nextUpgrade == "Golden" and #duplicatedPets >= nextUpgradeCost then
		return true
	end

	return false
end

function Pets.GetUpgradeTime(selectedAmount: number)
	local amount
	if selectedAmount == 1 then
		amount = 172_800
	elseif selectedAmount == 2 then
		amount = 86_400
	elseif selectedAmount == 3 then
		amount = 46_200
	elseif selectedAmount == 4 then
		amount = 23_100
	elseif selectedAmount == 5 then
		amount = 3_600
	end

	return amount
end

function Pets.GetUpgradeTimeString(selectedAmount: number)
	local amount
	if selectedAmount == 1 then
		amount = "2 Days"
	elseif selectedAmount == 2 then
		amount = "1 Day"
	elseif selectedAmount == 3 then
		amount = "12 Hours"
	elseif selectedAmount == 4 then
		amount = "6 Hours"
	elseif selectedAmount == 5 then
		amount = "1 Hour"
	end

	return amount
end

function Pets.GetCurrentAmountOfRainbowingPets(data)
	local amount= 0
	for uuid, pet in data.PetRainbow do
		amount += 1
	end

	return amount
end

function Pets.GetMaxRainbowingPets(data)
	local amount = DEFAULT_MAX_RAINBOWING_PETS
	
	local ownsGamepass = ShopConfig.DoesPlayerOwnGamepass("More Rainbow Slots", data)
	if ownsGamepass then
		amount += 2
	end	
	
	return amount
end

local RAINBOW_COLORS = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(0, 255, 0),
	Color3.fromRGB(0, 0, 255)
}

local AURORA_COLORS = {
	Color3.fromRGB(255, 255, 255),     -- White
	Color3.fromRGB(192, 192, 192),     -- Light Gray
	Color3.fromRGB(128, 128, 128),     -- Medium Gray
	Color3.fromRGB(64, 64, 64),        -- Dark Gray
	Color3.fromRGB(0, 0, 0),           -- Black
	Color3.fromRGB(64, 64, 64),        -- Dark Gray
	Color3.fromRGB(128, 128, 128),     -- Medium Gray
	Color3.fromRGB(192, 192, 192),     -- Light Gray
}

function Pets.RainbowTween(instance: Instance, index: number)
	if not instance.Parent then return end
	local nextIndex = index + 1
	if nextIndex > #RAINBOW_COLORS then
		nextIndex = 1
	end

	local property = if instance:IsA("BasePart") then "Color" else "BackgroundColor3"
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(instance, tweenInfo, { [property] = RAINBOW_COLORS[nextIndex] })
	tween.Completed:Connect(function()
		index = nextIndex
		Pets.RainbowTween(instance, index)
	end)
	tween:Play()
end

function Pets.AuroraTween(instance: Instance, index: number)
	if not instance.Parent then return end
	local nextIndex = index + 1
	if nextIndex > #AURORA_COLORS then
		nextIndex = 1
	end

	local property = if instance:IsA("BasePart") then "Color" else "BackgroundColor3"
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(instance, tweenInfo, { [property] = AURORA_COLORS[nextIndex] })
	tween.Completed:Connect(function()
		index = nextIndex
		Pets.AuroraTween(instance, index)
	end)
	tween:Play()
end

function Pets.GetEnchantingCost(pet: PetInstance, data)
	local price = 1_000

	local currentUpgrade = Pets.GetCurrentUpgrade(pet)
	if currentUpgrade == "Aurora" then
		price += 5_000_000
	elseif currentUpgrade == "Rainbow" then
		price += 1_000_000
	elseif currentUpgrade == "Golden" then
		price += 500_000
	elseif currentUpgrade == "Shiny" then
		price += 100_000
	end

	return 0
end

function Pets.GetActiveEnchantments(data)
	local equippedPets = Pets.GetEquippedPets(data)
	local enchantments = {}
	for uuid, pet in equippedPets do
		if pet.Enchantment.Enchantment then
			table.insert(enchantments, pet.Enchantment)
		end
	end

	return enchantments
end

return Pets