local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage.Remotes.Eggs
local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)
local EggsConfig = require(ReplicatedStorage.Configs.Eggs)
local PetsConfig = require(ReplicatedStorage.Configs.Pets)
local AchievementsConfig = require(ReplicatedStorage.Configs.Achievements)
local ShopConfig = require(ReplicatedStorage.Configs.Shop)

local AchievementsManager = require(ServerScriptService.Achievements)
local PlayerData = require(ServerScriptService.PlayerData.Manager)
local HatchGoal = require(ServerScriptService.HatchGoal)
local PetsManager = require(ServerScriptService.Pets)

local ORBS_CURRENCY_ICON = "rbxassetid://16553016252"
local ROBUX_CURRENCY_ICON = "rbxassetid://12570837359"

local hatchCooldown = {}

local Shared = {}


local function AutoDeletePet(player: Player, egg: string, pet: string)
	local profile = PlayerData.Profiles[player]
	if not profile then return end 

	local eggState = profile.Data.AutoDeletePets[egg]
	if not eggState then return end

	local petState = eggState[pet]
	if petState == nil then return end

	profile.Data.AutoDeletePets[egg][pet] = not petState
	Remotes.AutoDeletePet:FireClient(player, egg, pet, not petState)
end

local function ChoosePet(egg: string, playerData)
	local eggConfig = EggsConfig.GetConfig(egg)
	local TotalWeight = 0
	for pet, props in eggConfig.Pets do
		TotalWeight += props.Chance
	end	

	local normalizedChances = {}
	local count = 0
	for pet, props in eggConfig.Pets do
		local hatchChance = EggsConfig.GetHatchChance(egg, pet, playerData)
		normalizedChances[pet] = hatchChance / TotalWeight
		count += normalizedChances[pet]
	end

	local chance = math.random()
	count = 0
	for pet, normalizedChance in pairs(normalizedChances) do
		count += normalizedChance
		if chance <= count then
			return pet
		end
	end	
end

function Shared.Hatch(player: Player, egg: string, amount: number, force: boolean?)
	local profile = PlayerData.Profiles[player]
	if not profile then return end

	local onCooldown = hatchCooldown[player]
	if onCooldown then return end

	local eggConfig = EggsConfig.GetConfig(egg)
	if not eggConfig then return end

	local amountOfHatches = 1

	local ownsThreeHatchGamepass = ShopConfig.DoesPlayerOwnGamepass("3x Hatch", profile.Data)
	local ownsSixHatchGamepass = ShopConfig.DoesPlayerOwnGamepass("6x Hatch", profile.Data)

	if ownsThreeHatchGamepass and amount == 3 then
		amountOfHatches = 3
	end
	if ownsSixHatchGamepass and amount == 6 then
		amountOfHatches = 6
	end

	local price = eggConfig.Price * amountOfHatches
	local currency = eggConfig.Currency

	if currency ~= "Robux" then 
		local money = profile.Data[currency]
		local canAfford = money > price
		if not canAfford then return end
	end
	
	if not force then
		local storedPets = PetsConfig.GetTotalStoredPets(profile.Data)
		local maxStoredPets = PetsConfig.GetMaxStoredPets(profile.Data)
		local hasStorage = storedPets + amountOfHatches <= maxStoredPets
		if not hasStorage then return end
	end

	local hatchDuration = EggsConfig.GetHatchCooldown(profile.Data)

	hatchCooldown[player] = true
	task.delay(hatchDuration, function()
		hatchCooldown[player] = nil
	end)

	local achievementId = AchievementsConfig.GetFirstAvailableAchievementId("Eggs", profile.Data)
	if achievementId then
		local config = AchievementsConfig.GetAchievementConfig("Eggs", achievementId)
		if config and config.Egg == egg then
			AchievementsManager.AddPoint(player, "Eggs", achievementId, amountOfHatches)
		end
	end

	PlayerData.GiveBadge(player, "1 Egg Hatched")
	HatchGoal.Hatch(amountOfHatches)

	local pets = {}
	while amountOfHatches > 0 do
		amountOfHatches -= 1
		
		if not force then
			local storedPets = PetsConfig.GetTotalStoredPets(profile.Data)
			local maxStoredPets = PetsConfig.GetMaxStoredPets(profile.Data)
			local hasStorage = storedPets + amountOfHatches <= maxStoredPets
			if not hasStorage then return pets end
		end

		if currency == "Pi" then 
			PlayerData.AdjustPi(player, -eggConfig.Price)
		elseif currency == "Sigma" then
			PlayerData.AdjustSigma(player, -eggConfig.Price)
		end

		local pet = ChoosePet(egg, profile.Data)
		local autoDelete = profile.Data.AutoDeletePets[egg][pet]
		if not autoDelete then 
			local rarity = eggConfig.Pets[pet].Rarity
			local petInstance = PetsManager.CreatePet(pet, rarity)
			PetsManager.GivePet(player, petInstance)
		end
		table.insert(pets, pet)
		local hatchChance = EggsConfig.GetHatchChance(egg, pet, profile.Data)
		if hatchChance < 6.9 then
			Remotes.HatchedChat:FireAllClients(player.DisplayName, pet, hatchChance)
		end
	end
	return pets
end

local function UpdateEggModels()
	local eggModels = EggsConfig.GetEggStandModels()
	for egg, model: Model in eggModels do
		local config  = EggsConfig.GetConfig(egg)
		local currency = config.Currency
		local price = config.Price
		model.Price.Price.SurfaceGui.Price.Text = FormatNumber.FormatCompact(price)
		model.Price.Price.SurfaceGui.Icon.Image = if currency == "Robux" then ROBUX_CURRENCY_ICON else ORBS_CURRENCY_ICON
	end
end

UpdateEggModels()

Remotes.AutoDeletePet.OnServerEvent:Connect(AutoDeletePet)
Remotes.Hatch.OnServerInvoke = function(player, egg, amount)
	return Shared.Hatch(player, egg, amount, false)
end

return Shared