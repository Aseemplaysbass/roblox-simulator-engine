local Boosts = {}

export type Boost = "2x Pi" | "2x Sigma" | "2x Luck"

Boosts.Boosts = {
	"2x Pi",
	"2x Sigma",
	"2x Luck"
}

Boosts.Config = {
	["2x Pi"] = {
		Description = "Recieve 2x Pi from all sources!",
		Prices = {
			{
				Id = 1773251308,
				Duration = 5
			},
			{
				Id = 1773251901,
				Duration = 15
			},
			{
				Id = 1773252035,
				Duration = 30
			},
		}
	},
	["2x Sigma"] = {
		Description = "Recieve 2x Sigma from all sources!",
		Prices = {
			{
				Id = 1773252920,
				Duration = 10
			},
			{
				Id = 1773252919,
				Duration = 25
			},
			{
				Id = 1773252917,
				Duration = 45
			},
		}
	},
	["2x Luck"] = {
		Description = "Recieve 2x Luck from all eggs!",
		Prices = {
			{
				Id = 1773253267,
				Duration = 5
			},
			{
				Id = 1773253625,
				Duration = 20
			},
			{
				Id = 1773253626,
				Duration = 40
			},
		}
	},
}

function Boosts.GetActiveDuration(boost: Boost, data)
	return data.Boosts[boost]
end

function Boosts.HasBoost(boost: Boost, data)
	return Boosts.GetActiveDuration(boost, data) > 0
end

function Boosts.GetBoostFromProductId(productId: number)
	for boost, boostInfo in Boosts.Config do
		for _, priceInfo in boostInfo.Prices do
			if priceInfo.Id == productId then
				return boost
			end
		end
	end
end

function Boosts.GetDurationFromProductId(boost: Boost, productId: number)
	for _, priceInfo in Boosts.Config[boost].Prices do
		if priceInfo.Id == productId then
			return priceInfo.Duration
		end
	end
end

return Boosts
