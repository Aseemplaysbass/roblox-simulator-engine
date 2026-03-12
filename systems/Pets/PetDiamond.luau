local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetsConfig = require(ReplicatedStorage.Configs.Pets)

export type PetDiamondConfig = {
	Price: {
		Pet: string,
		Rarity: string,
		Upgrade: PetsConfig.PetUpgrade?,
		Amount: number
	},
	Reward: {
		Pet: string,
		Rarity: string,
		Upgrade: PetsConfig.PetUpgrade?,
	}
}

local Config = {
	Moon = {
		{
			Price = {
				Pet = "Cornucopia",
				Rarity = "Legendary",
				Amount = 5

			},
			Reward = {
				Pet = "Terraucopia",
				Rarity = "Legendary"
			},
		},
		{
			Price = {
				Pet = "Cornucopia",
				Rarity = "Legendary",
				Upgrade = "Shiny",
				Amount = 5

			},
			Reward = {
				Pet = "Terraucopia",
				Rarity = "Legendary",
				Upgrade = "Shiny"
			},
		},
		{
			Price = {
				Pet = "Cornucopia",
				Rarity = "Legendary",
				Upgrade = "Golden",
				Amount = 5

			},
			Reward = {
				Pet = "Terraucopia",
				Rarity = "Legendary",
				Upgrade = "Golden"
			},
		},
		{
			Price = {
				Pet = "Python",
				Rarity = "Mythical",
				Amount = 4

			},
			Reward = {
				Pet = "Shenron",
				Rarity = "Mythical"
			},
		},
		{
			Price = {
				Pet = "Python",
				Rarity = "Mythical",
				Upgrade = "Shiny",
				Amount = 4

			},
			Reward = {
				Pet = "Shenron",
				Rarity = "Mythical",
				Upgrade = "Shiny"
			},
		},
		{
			Price = {
				Pet = "Python",
				Rarity = "Mythical",
				Upgrade = "Golden",
				Amount = 4

			},
			Reward = {
				Pet = "Shenron",
				Rarity = "Mythical",
				Upgrade = "Golden"
			},
		},
		{
			Price = {
				Pet = "Deer",
				Rarity = "Eternal",
				Amount = 3

			},
			Reward = {
				Pet = "Wendigo",
				Rarity = "Eternal"
			},
		},
		{
			Price = {
				Pet = "Deer",
				Rarity = "Eternal",
				Upgrade = "Shiny",
				Amount = 3

			},
			Reward = {
				Pet = "Wendigo",
				Rarity = "Eternal",
				Upgrade = "Shiny"
			},
		},
		{
			Price = {
				Pet = "Deer",
				Rarity = "Eternal",
				Upgrade = "Golden",
				Amount = 3

			},
			Reward = {
				Pet = "Wendigo",
				Rarity = "Eternal",
				Upgrade = "Golden"
			},
		},
		{
			Price = {
				Pet = "Gaia",
				Rarity = "Ancient",
				Amount = 2

			},
			Reward = {
				Pet = "Reaper",
				Rarity = "Ancient"
			},
		},
		{
			Price = {
				Pet = "Gaia",
				Rarity = "Ancient",
				Upgrade = "Shiny",
				Amount = 2

			},
			Reward = {
				Pet = "Reaper",
				Rarity = "Ancient",
				Upgrade = "Shiny"
			},
		},
		{
			Price = {
				Pet = "Gaia",
				Rarity = "Ancient",
				Upgrade = "Golden",
				Amount = 2

			},
			Reward = {
				Pet = "Reaper",
				Rarity = "Ancient",
				Upgrade = "Golden"
			},
		},
	}
}

local Pets = {}

Pets.Config = Config

function Pets.GetDiamondConfig(area: string, index: number): PetDiamondConfig | nil
	local areaConfig = Pets.Config[area]
	if not areaConfig then return end

	local diamondConfig = areaConfig[index]
	return diamondConfig
end

function Pets.GetPetInstance(area: string, index: number, mode: "Price" | "Reward")
	local diamondConfig = Pets.GetDiamondConfig(area, index)

	local petInstance = {
		UUID= "",
		Model = diamondConfig[mode].Pet,
		Rarity = diamondConfig[mode].Rarity,
		Golden = diamondConfig[mode].Upgrade == "Golden",
		Shiny = diamondConfig[mode].Upgrade == "Shiny",
	}

	return petInstance
end

function Pets.CanDiamond(area: string, index: number, data)
	local diamondConfig = Pets.GetDiamondConfig(area, index)

	local petInstance = Pets.GetPetInstance(area, index, "Price")
	local duplicatePets = PetsConfig.GetDuplicatePets(petInstance, data)

	local canDiamond = #duplicatePets >= diamondConfig.Price.Amount
	return canDiamond
end

return Pets
