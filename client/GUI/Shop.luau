local MarketplaceService = game:GetService("MarketplaceService")

local Shop = {}

Shop.Products = {
	Pi = {
		{
			Id = 1772427631,
			Amount = 9_312
		},
		{
			Id = 1772428072,
			Amount = 331_776
		},
	},

	Pets = {
		{
			Id = 1772534508,
			Name = "Galactic Drone",
			Shiny = true,
			Golden = true,
			Rainbow = false,
			Rarity = "Exclusive",
		},
		{
			Id = 1772534507,
			Name = "Nebula Dragonling",
			Shiny = true,
			Golden = true,
			Rainbow = true,
			Rarity = "Exclusive+",
		}
	},
	
	Spins = {
		{
			Id = 1773098958
		}
	},

	Gamepasses = {
		{
			Id = 738456224 --VIP
		},
		{
			Id = 739137221 --2x Sigma
		},
		{
			Id = 739101203 --Auto Pet Merge
		},
		{
			Id = 739645221 --Magic Eggs
		},
		{
			Id = 739580209 --Unlimited Ascensions Button
		},
		{
			Id = 739284279 --Auto Ascension
		},
		{
			Id = 739107240 --Permanent Auto
		},
		{
			Id = 739105219 --Lucky
		},
		{
			Id = 739466261 --Super Lucky
		},
		{
			Id = 739854247 --3x Hatch
		},
		{
			Id = 738574350 --6x Hatch
		},
		{
			Id = 739334209 --Skip Hatch Animation
		},
		{
			Id = 738571204 --Auto Max Level
		},
		{
			Id = 739111208 --Better Shiny
		},
		{
			Id = 739263265 --+100 Pets Storage
		},
		{
			Id = 739489187 --+500 Pets Storage
		},
		{
			Id = 738388267 --+1 Pet Equip
		},
		{
			Id = 739863262 --+2 Pet Equip
		},
		{
			Id = 738167231 --More Rainbow Slots
		},
		{
			Id = 739437168 --2x DPS
		},	
		{
			Id = 739117180 --2x Pi
		},	
		{
			Id = 739502182 --+25 Pet Bank Storage
		},
		{
			Id = 744975700 --Double Offline Pi
		},
		{
			Id = 761557595 --Teleporter
		}
	},
	
	Eggs = {
		{
			Id = 1788359709, --Rocket Egg
			Name = "Rocket"
		},
		{
			Id = 1794515578, --Love Egg
			Name = "Love"
		}
	}
}

Shop.PetsExpire = 17332931190

local function GenerateGamepassNames()
	for index, gamepassInfo in Shop.Products.Gamepasses do
		local productInfo = MarketplaceService:GetProductInfo(gamepassInfo.Id, Enum.InfoType.GamePass)
		if productInfo then
			Shop.Products.Gamepasses[index].Name = productInfo.Name
		end
	end
end 

GenerateGamepassNames()

function Shop.CalculatePiProduct(index: number, data)
	local productConfig = Shop.Products.Pi[index]
	local amount = productConfig.Amount

	return amount
end

function Shop.GetProductTypeFromId(productId: number)
	for productType, packages in Shop.Products do
		for index, package in packages do
			if package.Id == productId then
				return productType
			end
		end
	end
end

function Shop.GetProductIndexFromId(productId: number)
	local productType = Shop.GetProductTypeFromId(productId)

	for index, package in Shop.Products[productType] do
		if package.Id == productId then
			return index
		end
	end
end

function Shop.GetGamepassIDFromName(name: string)
	for _, gamepassInfo in Shop.Products.Gamepasses do
		if gamepassInfo.Name == name then
			return gamepassInfo.Id
		end
	end
end

function Shop.DoesPlayerOwnGamepass(id: number | string, data)
	id = if tonumber(id) then id else Shop.GetGamepassIDFromName(id)

	return data.Gamepasses[tostring(id)]
end

return Shop
