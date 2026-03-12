local Workspace = game:GetService("Workspace")

local Islands = {}

Islands.IslandOrder = {
	"Mercury",
	"Venus",
	"Earth",
	"Moon",
}

Islands.Config = {
	Mercury = {
		Boost = 1,
	},
	Venus = {
		Price = 28_518,
		Requirement = nil,
		Boost = 2
	},
	Earth = {
		Price = 746_496,
		Requirement = "Venus",
		Boost = 3
	},
	Moon = {
		Price = 8_906_250,
		Requirement = "Earth",
		Boost = 4
	},
	--Mars = {
	--	Price = 36962304,
	--	Requirement = "Moon"
	--},
}

function Islands.IsIslandUnlocked(data, island: string)
	if data.Islands[island] ~= false then
		return data.Islands[island]
	else
		return island == "Mercury"
	end
end

function Islands.GetIslandBoost(island: string)
	if Islands.Config[island] then
		return Islands.Config[island].Boost
	else
		return 0
	end
end


function Islands.DoesPlayerOwnRequirement(data, island: string)
	local requiredIsland = Islands.Config[island].Requirement
	if requiredIsland then
		return Islands.IsIslandUnlocked(data, requiredIsland)
	else
		return true
	end
end


function Islands.GetIslandSpawnPart(island: string)
	local islandPart = Workspace.Islands[island]:FindFirstChild("Spawn")
	return islandPart
end

return Islands
