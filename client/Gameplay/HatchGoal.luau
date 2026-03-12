local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BoostsConfig = require(ReplicatedStorage.Configs.Boosts)

local HatchGoal = {}

HatchGoal.Goal = 50

local Reward: BoostsConfig.Boost = "2x Pi"

HatchGoal.Reward = Reward

function HatchGoal.IsBoostActive(boost: BoostsConfig.Boost)
	local hatchGoal = Workspace.HatchGoal
	local currentBoost = hatchGoal:GetAttribute("boost")
	local isActive = hatchGoal:GetAttribute("active")
	
	if currentBoost == boost and isActive then
		return 1
	end
	
	return 0
end

return HatchGoal
