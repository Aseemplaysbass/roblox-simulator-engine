local AscensionsConfig = {}

AscensionsConfig.BasePrice = 800
AscensionsConfig.IncreasePerAscension = 175

local FreeButtons = {
	["1"] = {
		Price = 0
	},
	["5"] = {
		Price = 0
	},
	["10"] = {
		Price = 0
	},
}

AscensionsConfig.Shop = {
	["Mercury"] = {
		Pets = {
			Caduceus = {
				Rarity = "Legendary",
				Shiny = true,
				Golden = true,
				Price = 400
			}
		},
		Buttons = {
			["50"] = {
				Price = 500
			}
		}
	},
	["Venus"] = {
		Pets = {
			Rose = {
				Rarity = "Legendary",
				Shiny = true,
				Golden = true,
				Price = 401
			}
		},
		Buttons = {
			["100"] = {
				Price = 501
			}
		}
	},
	["Earth"] = {
		Pets = {
			Cornucopia = {
				Rarity = "Legendary",
				Shiny = true,
				Golden = true,
				Price = 402
			}
		},
		Buttons = {
			["200"] = {
				Price = 502
			}
		}
	},
}

function AscensionsConfig.GetMaxAscensions(currentAscension: number, pi: number)
	local ascensions = 0
	local i = 1
	
	while true do
		local cost = AscensionsConfig.CalculatePrice(currentAscension, i)
		local canAfford = pi > cost
		if not canAfford then
			break
		end
		
		ascensions = i
		i += 1
	end
	
	return ascensions
end

function AscensionsConfig.CalculatePrice(currentAscension: number, amountOfAscensions: number?)
	amountOfAscensions = amountOfAscensions or 1
	local price = AscensionsConfig.BasePrice + ((currentAscension + amountOfAscensions - 1) * AscensionsConfig.IncreasePerAscension)
	
	if amountOfAscensions > 1 then
		local ascensions = amountOfAscensions - 1
		price = ((2 * AscensionsConfig.BasePrice) + (ascensions * AscensionsConfig.IncreasePerAscension)) * (amountOfAscensions / 2)
		price = price + (currentAscension * ((amountOfAscensions * AscensionsConfig.IncreasePerAscension) - AscensionsConfig.IncreasePerAscension))
	end

	return price
end

function AscensionsConfig.HasButtonUnlocked(playerData, ascensionButton: number)
	local buttonConfig = AscensionsConfig.GetButtons()[ascensionButton]
	if not buttonConfig then return false end

	return playerData.AscensionButtons[ascensionButton]
end

function AscensionsConfig.GetButtons()
	local ascensions = FreeButtons
	for area, info in AscensionsConfig.Shop do
		for button, buttonInfo in info.Buttons do
			ascensions[button] = {
				Price = buttonInfo.Price
			}
		end
	end

	return ascensions
end

return AscensionsConfig
