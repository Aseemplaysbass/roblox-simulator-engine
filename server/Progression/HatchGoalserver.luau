local MemoryStoreService = game:GetService("MemoryStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local HatchGoalConfig = require(ReplicatedStorage.Configs.HatchGoal)

local Remotes = ReplicatedStorage.Remotes

local PlayerData = require(ServerScriptService.PlayerData.Manager)

local HatchGoalMap = MemoryStoreService:GetSortedMap("HatchGoal2")

local hatchedSinceSave = 0
local hatchProgress = 0

local function UpdateGoal()
	local success, newHatches = pcall(function()
		return HatchGoalMap:UpdateAsync("Goal", function(oldValue)
			oldValue = oldValue or 0
			return oldValue + hatchedSinceSave
		end, 3_888_000)
	end)
	
	if success then
		hatchedSinceSave = 0
		hatchProgress = newHatches
		Remotes.UpdateHatchGoal:FireAllClients(hatchProgress)
	end
end

local function GetInitialGoal()
	local success, value = pcall(function()
		return HatchGoalMap:GetAsync("Goal") or 0
	end)
	
	if success then
		hatchProgress = value
		Remotes.UpdateHatchGoal:FireAllClients(hatchProgress)
	end
end

GetInitialGoal()

task.spawn(function()
	while true do
		local hasHatchedSinceSave = hatchedSinceSave > 0
		local hasMetGoal = hatchProgress >= HatchGoalConfig.Goal
		
		if hasHatchedSinceSave and not hasMetGoal then
			UpdateGoal()
		elseif hasMetGoal then
			local boost = HatchGoalConfig.Reward
			local hatchGoal = Workspace.HatchGoal
			
			hatchGoal:SetAttribute("boost", boost)
			hatchGoal:SetAttribute("active", true)
			break
		else
			task.wait(1)
			continue
		end
		
		task.wait(60)
	end
end)

game:BindToClose(function()
	local hasHatchedSinceSave = hatchedSinceSave > 0
	if hasHatchedSinceSave then
		UpdateGoal()
	end
end)

PlayerData.ProfileLoaded.Event:Connect(function(player: Player)
	Remotes.UpdateHatchGoal:FireClient(player, hatchProgress)
end)

local HatchGoal = {}

function HatchGoal.Hatch(amount: number)
	local hasMetGoal = hatchProgress >= HatchGoalConfig.Goal
	if hasMetGoal then return end
	
	hatchedSinceSave += amount
	hatchProgress += amount
	Remotes.UpdateHatchGoal:FireAllClients(hatchProgress)
end

return HatchGoal