local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local PetsConfig = require(ReplicatedStorage.Configs.Pets)
local ShopConfig = require(ReplicatedStorage.Configs.Shop)
local SettingsConfig = require(ReplicatedStorage.Configs.Settings)
local StatUtils = require(ReplicatedStorage.Utils.Stats)

export type EggConfig = {
	Price: number,
	Currency: string, 
	Pets: {
		[string]: {
			Chance: number, 
			Rarity: string
		}
	}
}

local Config: { [string]: EggConfig } = {
	["Lava"] = {
		Price = 582,
		Currency = "Pi",
		Pets = {
			Rooster = {
				Chance = 36,
				Rarity = "Common"
			},
			Tortoise = {
				Chance = 25,
				Rarity = "Uncommon"
			},
			Petasus = {
				Chance = 16,
				Rarity = "Rare"
			},
			Kithara = {
				Chance = 9,
				Rarity = "Epic"
			},
			Caduceus = {
				Chance = 1,
				Rarity = "Legendary"
			},
			Hermes = {
				Chance = 1/27,
				Rarity = "Mythical"
			},
		}
	},
	["Rocket"] = {
		Price = 0,
		Currency = "Robux",
		Pets = {
			Mercury = {
				Chance = 0,
				Rarity = "Unique"
			},
		}
	},
	["Venus Flytrap"] = {
		Price = 20_736,
		Currency = "Pi",
		Pets = {
			Seashell = {
				Chance = 36,
				Rarity = "Common"
			},
			Anemone = {
				Chance = 25,
				Rarity = "Uncommon"
			},
			Narcissus = {
				Chance = 16,
				Rarity = "Rare"
			},
			Pearl = {
				Chance = 9,
				Rarity = "Epic"
			},
			Rose = {
				Chance = 1,
				Rarity = "Legendary"
			},
			Mirror = {
				Chance = 1/27,
				Rarity = "Mythical"
			},
			Aphrodite = {
				Chance = 1/256,
				Rarity = "Eternal"
			},
		}
	},
	["Love"] = {
		Price = 0,
		Currency = "Robux",
		Pets = {
			Venus = {
				Chance = 90,
				Rarity = "Unique"
			},
			Venera14 = {
				Chance = 10,
				Rarity = "Exalted"
			}
		}
	},
	["Earth"] = {
		Price = 356_250,
		Currency = "Pi",
		Pets = {
			Cow = {
				Chance = 36,
				Rarity = "Common"
			},
			Oak = {
				Chance = 25,
				Rarity = "Uncommon"
			},
			Lily = {
				Chance = 16,
				Rarity = "Rare"
			},
			Apple = {
				Chance = 9,
				Rarity = "Epic"
			},
			Cornucopia = {
				Chance = 1,
				Rarity = "Legendary"
			},
			Python = {
				Chance = 1/27,
				Rarity = "Mythical"
			},
			Deer = {
				Chance = 1/256,
				Rarity = "Eternal"
			},
			Gaia = {
				Chance = 1/3125,
				Rarity = "Ancient"
			},
		}
	},
	--["Nuke"] = {
	--	Price = 299,
	--	Currency = "Robux",
	--	Pets = {
	--	}
	--},
	--["Mars"] = {
	--	Price = 61_412_778,
	--	Currency = "Orbs",
	--	Pets = {
	--	}
	--},
}

local Eggs = {}

Eggs.Eggs = { "Lava", "Venus Flytrap", "Earth" }
Eggs.Config = Config

function Eggs.GetConfig(egg: string): EggConfig
	return Config[egg]
end

function Eggs.GetHatchCooldown(data)
	local hasGamepass = ShopConfig.DoesPlayerOwnGamepass("Skip Hatch Animation", data)
	local shouldSkipAnimation = hasGamepass and SettingsConfig.IsSettingActive("Skip Hatch Animation", data)
	return if shouldSkipAnimation then 0.05 else 5
end

function Eggs.GetEggStandModels()
	local models = {}

	for _, descendant in Workspace:GetDescendants() do 
		if descendant.Name == "EggStand" or descendant.Name == "RobuxEggStand1" then
			local egg = descendant:GetAttribute("Egg")
			if egg then
				models[egg] = descendant
			end			
		end
	end

	return models
end

function Eggs.GetHatchChance(egg: string, pet: string, data)
	local config = Eggs.GetConfig(egg)
	if not config then return end

	local luckStat = StatUtils.LuckMultiplier(data)
	
	local petConfig =  config.Pets[pet]
	
	local chance = petConfig.Chance
	if chance < 10 then 
		chance *= luckStat
	end	
	
	
		
	local enchantments = PetsConfig.GetActiveEnchantments(data)
	local rarity = petConfig.Rarity
	for _, enchantment in enchantments do
		if string.find(enchantment.Enchantment, rarity) then
			chance += enchantment.Level / 2
		end
	end

	return chance
end

function Eggs.GetTotalPetsInEgg(egg: string)
	local amount = 0
	local config = Eggs.GetConfig(egg)
	for pet, petInfo in config.Pets do
		amount += 1
	end

	return amount
end

function Eggs.GetTotalCollectedPetsInEgg(egg: string, data)
	local amount = 0
	local config = Eggs.GetConfig(egg)
	for pet, petInfo in config.Pets do
		if data.PetIndex[pet] then
			amount += 1
		end
	end

	return amount
end

function Eggs.GetEggOfPet(pet: string)
	for egg, info in Config do
		if info.Pets[pet] then
			return egg
		end
	end
end

local function SetupRobuxEggs()
	for egg, info in Eggs.Config do
		local doesCostRobux = info.Currency == "Robux"
		if not doesCostRobux then continue end
		
		local productId
		for _, info in ShopConfig.Products.Eggs do
			if info.Name == egg then
				productId = info.Id
				break
			end
		end
		
		local price = MarketplaceService:GetProductInfo(productId, Enum.InfoType.Product).PriceInRobux
		Eggs.Config[egg].Price = price
		Eggs.Config[egg].ProductId = productId
	end
end

local function GenerateEggModels()
	local models = Eggs.GetEggStandModels()
	for egg, model in models do
		local part = model:WaitForChild("Egg"):Clone()

		local newModel = Instance.new("Model")
		newModel.Name = egg
		newModel.Parent = ReplicatedStorage.Eggs

		part.Parent = newModel
	end
end

if RunService:IsClient() then
	GenerateEggModels()
end

SetupRobuxEggs()

return Eggs