local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Remotes = ReplicatedStorage.Remotes

local ShopConfig = require(ReplicatedStorage.Configs.Shop)
local PetsConfig = require(ReplicatedStorage.Configs.Pets)
local BoostsConfig = require(ReplicatedStorage.Configs.Boosts)
local PlayerData = require(ServerScriptService.PlayerData.Manager)
local PetsManager = require(ServerScriptService.Pets)
local EggsManager = require(ServerScriptService.Eggs)
local SpinsManager = require(ServerScriptService.Spins)

local function BoostsLoop()
	while true do
		for _, player in Players:GetPlayers() do
			local profile = PlayerData.Profiles[player]
			if not profile then continue end
			
			local boosts = profile.Data.Boosts
			for boost, time in boosts do
				if time > 0 then
					profile.Data.Boosts[boost] -= 1
					Remotes.UpdateBoost:FireClient(player, boost, profile.Data.Boosts[boost])
				end
			end
		end
		
		task.wait(1)
	end
end

local function RewardBoosts(profile, productId, number)
	local boost = BoostsConfig.GetBoostFromProductId(productId)
	if not boost then return end
	
	local duration = BoostsConfig.GetDurationFromProductId(boost, productId) * 60
	local activeDuration = BoostsConfig.GetActiveDuration(boost, profile.Data)
	local newDuration = duration + activeDuration
	
	profile.Data.Boosts[boost] = newDuration
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

local function RewardPi(player: Player, profile, productId: number)
	local index = ShopConfig.GetProductIndexFromId(productId)
	local piRewards = ShopConfig.CalculatePiProduct(index, profile.Data)
	PlayerData.AdjustPi(player, piRewards)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

local function RewardPet(player: Player, productId: number)
	local index = ShopConfig.GetProductIndexFromId(productId)
	local productInfo = ShopConfig.Products.Pets[index]

	local pet = productInfo.Name
	local rarity = productInfo.Rarity
	local upgrade = PetsConfig.GetCurrentUpgrade(productInfo)

	local instance = PetsManager.CreatePet(pet, rarity, upgrade)
	local petGiven = PetsManager.GivePet(player, instance)

	return if petGiven == "Pet Given!" then Enum.ProductPurchaseDecision.PurchaseGranted else Enum.ProductPurchaseDecision.NotProcessedYet
end

local function RewardEgg(player: Player, productId: number)
	local index = ShopConfig.GetProductIndexFromId(productId)
	local productInfo = ShopConfig.Products.Eggs[index]
	
	local egg = productInfo.Name
	local pets = EggsManager.Hatch(player, egg, 1, true)
	Remotes.Eggs.ForceHatch:FireClient(player, egg, pets[1])
	return if pets then Enum.ProductPurchaseDecision.PurchaseGranted else Enum.ProductPurchaseDecision.NotProcessedYet
end

local function PurchaseProduct(reciptInfo)
	local userId = reciptInfo.PlayerId
	local productId = reciptInfo.ProductId

	local player = Players:GetPlayerByUserId(userId)
	if not player then return end

	local profile = PlayerData.Profiles[player]
	if not profile then return end

	local productType = ShopConfig.GetProductTypeFromId(productId)

	if productType == "Pi" then
		return RewardPi(player, profile, productId)
	elseif productType == "Pets" then
		return RewardPet(player, productId)
	elseif productType == "Eggs" then
		return RewardEgg(player, productId)
	elseif productType == "Spins" then
		local reward = SpinsManager.Spin(player, true)
		return if reward then Enum.ProductPurchaseDecision.PurchaseGranted else Enum.ProductPurchaseDecision.NotProcessedYet
	else
		return RewardBoosts(profile, productId)
	end
end

local function PurchaseGamepass(player: Player, id: number, wasPurchased: boolean)
	if not wasPurchased then return end

	local profile  = PlayerData.Profiles[player]
	if not profile then return end

	profile.Data.Gamepasses[id] = true
	Remotes.UpdateGamepass:FireClient(player, id, true)
end

local function CheckGamepassPurchasedFromWebsite(player: Player, data)
	local profile = PlayerData.Profiles[player]
	for gamepassId, isOwned in profile.Data.Gamepasses do
		if not isOwned then
			local hasPurchased = MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassId)
			if hasPurchased then
				PurchaseGamepass(player, gamepassId, true)
			end
		end
	end
end

MarketplaceService.ProcessReceipt = PurchaseProduct
MarketplaceService.PromptGamePassPurchaseFinished:Connect(PurchaseGamepass)

PlayerData.ProfileLoaded.Event:Connect(CheckGamepassPurchasedFromWebsite)

task.spawn(BoostsLoop)