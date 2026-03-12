local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local UserService = game:GetService("UserService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)
local FormatTime = require(ReplicatedStorage.Libs.FormatTime)

local LAST_LEADERBOARD_END_TIMESTAMP = 1711791644
local LEADERBOARD_END_TIMESTAMP = 1711903410

local DataStores = {
	Pi = DataStoreService:GetOrderedDataStore(`Leaderboard_Pi_{LEADERBOARD_END_TIMESTAMP}`), 
	Sigma = DataStoreService:GetOrderedDataStore(`Leaderboard_Sigma_{LEADERBOARD_END_TIMESTAMP}`), 
	Ascensions = DataStoreService:GetOrderedDataStore(`Leaderboard_Ascensions_{LEADERBOARD_END_TIMESTAMP}`)
}

local WinnersDataStore = DataStoreService:GetDataStore("LeaderboardWinners")

local LeaderboardGui = ServerStorage.LeaderboardGui
local LeaderboardInfoGui = ServerStorage.LeaderboardInfoGui
local WinnerGui = ServerStorage.WinnerGui

export type LeaderboardType = "Pi" | "Sigma" | "Ascensions"

local LeaderboardParts: { [number]: { Model: Model, Type: LeaderboardType } } = {}
local LeaderboardInfoParts: { [number]: Model } = {}

type StateInfo = {
	UserId: number, 
	Amount: number
}

local LeaderboardState: { [LeaderboardType] : { [number] : StateInfo } } = {
	Pi = {},
	Sigma = {},
	Ascensions = {}
}

type Earnings = {
	[number]: {
		Pi: number,
		Sigma: number,
		Ascensions: number
	}
}

local DefaultEarnings = {
	Pi = 0,
	Sigma = 0,
	Ascensions = 0
}

local Earnings: Earnings = {}

type Winners = {
	[string]: { --Previous leaderboard and Timestamp
		[number]: WinnerInfo
	}
}

export type WinnerInfo = {
	UserId: number,
	Amount: number
}

local LastStateUpdateTime

local GET_STATE_TIME_IN_SECONDS = 300
local SAVE_EARNINGS_TIME_IN_SECONDS = 60

local Winners: Winners = WinnersDataStore:GetAsync("Winners") or {}

local WinnersSaved = false

local Leaderboards = {}

Leaderboards.Winners = Winners

Leaderboards.Earnings = Earnings

Leaderboards.Reward = Instance.new("BindableEvent")

local function DisplayPastWinners()
	local winners = Leaderboards.Winners[tostring(LAST_LEADERBOARD_END_TIMESTAMP)]
	if not winners then return end
	
	local firstWinner = winners[1]
	if not firstWinner then return end
	
	local model = Players:CreateHumanoidModelFromUserId(firstWinner.UserId)
	if not model then return end
	
	model.Parent = Workspace
	model:PivotTo(Workspace.LeaderboardWinner.CFrame)
	model.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then 
			descendant.Anchored = true
		end
	end
	
	local success, playerInfo = pcall(function()
		return UserService:GetUserInfosByUserIdsAsync({tonumber(firstWinner.UserId)})
	end)
	
	local name = if success then playerInfo[1].DisplayName else firstWinner.UserId
	
	local gui = WinnerGui:Clone()
	gui.Parent = model.Head
	gui.Frame.PlayerName.Text = name
	gui.Frame.Pi.Text = `{FormatNumber.FormatCompact(firstWinner.Amount)} Pi`
	gui.Frame.Place.Text = "1st Place"
end

--

local function SaveWinners()
	local isSavedAlready = Leaderboards.Winners[tostring(LEADERBOARD_END_TIMESTAMP)]
	if isSavedAlready then return end
	
	local winners = {}
	for position, info in LeaderboardState.Pi do
		if position > 50 then break end
		
		local winnerInfo: WinnerInfo = {
			UserId = info.UserId,
			Amount = info.Amount
		}
		winners[position] = winnerInfo
		
		local player = Players:GetPlayerByUserId(info.UserId)
		if player then
			Leaderboards.Reward:Fire(player, LEADERBOARD_END_TIMESTAMP)
		end
	end
	
	Leaderboards.Winners[tostring(LEADERBOARD_END_TIMESTAMP)] = winners
	WinnersDataStore:SetAsync("Winners", Leaderboards.Winners)
	WinnersSaved = true
end

local function UpdateResetDisplay()
	local timeUntilReset = LEADERBOARD_END_TIMESTAMP - os.time()
	
	for _, part in LeaderboardInfoParts do
		local gui = part.PrimaryPart.LeaderboardInfoGui
		if timeUntilReset <= 0 then
			gui.Frame.Reset.Text = "Resetting soon..."
		else
			gui.Frame.Reset.Text = `Resets in: {FormatTime.convertToHMS(timeUntilReset)}`
		end
	end
end

local function SetupLeaderboardInfo()
	for _, descendent in Workspace:GetDescendants() do
		if descendent.Name == "LeaderboardInfo" and descendent:IsA("Model") then
			table.insert(LeaderboardInfoParts, descendent)
			local gui = LeaderboardInfoGui:Clone()
			gui.Parent = descendent.PrimaryPart
		end
	end
end

--

function Leaderboards.AdjustLeaderboard(player: Player, amount: number, leaderboardType: LeaderboardType)
	if player.UserId == game.CreatorId then return end
	if amount > 0 then
		if Leaderboards.Earnings[player.UserId] then
			Leaderboards.Earnings[player.UserId][leaderboardType] += amount
		end
	end
end

local function SetLeaderboardParts()
	for _, descendent in Workspace:GetDescendants() do
		if descendent.Name:find("Leaderboard") and descendent:IsA("Model") then
			local type = descendent:GetAttribute("type")
			if type then
				table.insert(LeaderboardParts, {
					Model = descendent,
					Type = type
				})
			end
		end
	end
end

local function GetAllLeaderBoardPartsOf(leaderboardType: LeaderboardType)
	local leaderboards = {}
	for _, leaderboardInfo in LeaderboardParts do
		if leaderboardInfo.Type == leaderboardType then
			table.insert(leaderboards, leaderboardInfo)
		end
	end
	
	return leaderboards
end

local function CreateLeaderboardGuis()
	for _, leaderboardInfo in LeaderboardParts do
		local gui = LeaderboardGui:Clone()
		gui.Parent = leaderboardInfo.Model.PrimaryPart
		gui.Frame.Title.Text = `{leaderboardInfo.Type} Ranks`
		gui.Frame.Title.TextColor3 = Color3.fromRGB()
	end
end

local function UpdateRefreshDisplay()
	local timeUntilRefresh = GET_STATE_TIME_IN_SECONDS - (os.time() - LastStateUpdateTime)
	
	for _, leaderboardPart in LeaderboardParts do
		local gui = leaderboardPart.Model.PrimaryPart.LeaderboardGui
		gui.Frame.Refresh.Text = `Leaderboard refreshes in: {FormatTime.convertToHMS(timeUntilRefresh)}`
		gui.Frame.Refresh.TextColor3 = Color3.fromRGB(255, 74, 77)
	end
end

local function CleanContainer()
	for _, leaderboardPart in LeaderboardParts do
		local gui = leaderboardPart.Model.PrimaryPart.LeaderboardGui
		local container = gui.Frame.Container
		for _, child in container:GetChildren() do
			if child.Name ~= "Template" and child:IsA("Frame") then
				child:Destroy()
			end
		end
	end
end

local function AddPlayerToLeaderboards(userId: number, leaderboardType: LeaderboardType, amount: number, place: number)
	local success, playerInfo = pcall(function()
		return UserService:GetUserInfosByUserIdsAsync({tonumber(userId)})
	end)
	
	local name = if playerInfo[1] then playerInfo[1].DisplayName else userId
	
	local leaderboards = GetAllLeaderBoardPartsOf(leaderboardType)
	for _, info in leaderboards do
		local model = info.Model
		local gui = model.PrimaryPart.LeaderboardGui
		
		local container = gui.Frame.Container
		local clone = container.Template:Clone()
		clone.Parent = container
		clone.Visible = true
		clone.Name = userId
		
		clone.Player.Text = name
		clone.Amount.Text = FormatNumber.FormatCompact(amount)
		clone.Place.Text = place
		
		if clone.Place.Text == "1" then
			clone.Player.TextColor3 = Color3.fromRGB(255, 255, 127)
			clone.Amount.TextColor3 = Color3.fromRGB(255, 255, 127)
			clone.Place.TextColor3 = Color3.fromRGB(255, 255, 127)
		elseif clone.Place.Text == "2" then
			clone.Player.TextColor3 = Color3.fromRGB(245, 225, 255)
			clone.Amount.TextColor3 = Color3.fromRGB(245, 225, 255)
			clone.Place.TextColor3 = Color3.fromRGB(245, 225, 255)
		elseif clone.Place.Text == "3" then
			clone.Player.TextColor3 = Color3.fromRGB(255, 171, 132)
			clone.Amount.TextColor3 = Color3.fromRGB(255, 171, 132)
			clone.Place.TextColor3 = Color3.fromRGB(255, 171, 132)
		elseif clone.Place.Text == "4" then
			clone.Player.TextColor3 = Color3.fromRGB(85, 170, 255)
			clone.Amount.TextColor3 = Color3.fromRGB(85, 170, 255)
			clone.Place.TextColor3 = Color3.fromRGB(85, 170, 255)
		else
			clone.Player.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.Amount.TextColor3 = Color3.fromRGB(255, 255, 255)
			clone.Place.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
		
		clone.LayoutOrder = place
	end
end

local function FetchLeaderboardStates()
	LeaderboardState = {
		Pi = {},
		Sigma = {},
		Ascensions = {},
	}
	
	CleanContainer()
	
	for leaderboardType, dataStore in DataStores do
		local pages = dataStore:GetSortedAsync(false, 100)
		local items = pages:GetCurrentPage()
		for index, item in items do
			local userId = item.key
			if userId == game.CreatorId then continue end
			local amount = item.value
			table.insert(LeaderboardState[leaderboardType], {
				UserId = userId,
				Amount = amount
			})
			AddPlayerToLeaderboards(userId, leaderboardType, amount, index)
		end
	end
	
	LastStateUpdateTime = os.time()
end

local function SavePlayerData(player: Player)
	local earnings = Leaderboards.Earnings[player.UserId]
	if not earnings then return end
	
	for currency, amount in earnings do
		local hasEarned = amount > 0
		if hasEarned then
			DataStores[currency]:IncrementAsync(tostring(player.UserId), amount)
			Leaderboards.Earnings[player.UserId][currency] = 0
		end
	end
end

local function CreateSaveLoop(player: Player)
	while player do
		SavePlayerData(player)
		task.wait(SAVE_EARNINGS_TIME_IN_SECONDS)
	end
end

SetLeaderboardParts()
CreateLeaderboardGuis()
FetchLeaderboardStates()

SetupLeaderboardInfo()

DisplayPastWinners()

task.spawn(function()
	while true do
		pcall(function()
			local shouldRefresh = os.time() - LastStateUpdateTime >= GET_STATE_TIME_IN_SECONDS
			if shouldRefresh then
				FetchLeaderboardStates()
			end
			
			UpdateRefreshDisplay()
			UpdateResetDisplay()
			
			local shouldSaveWinners = os.time() >= LEADERBOARD_END_TIMESTAMP and WinnersSaved == false
			if shouldSaveWinners then
				SaveWinners()
			end
		end)
		task.wait(1)
	end
end)

for _, player in Players:GetPlayers() do
	Leaderboards.Earnings[player.UserId] = DefaultEarnings
	task.spawn(function()
		CreateSaveLoop(player)
	end)
end

Players.PlayerAdded:Connect(function(player)
	Leaderboards.Earnings[player.UserId] = DefaultEarnings
	CreateSaveLoop(player)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	SavePlayerData(player)
	Leaderboards.Earnings[player.UserId] = nil
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		SavePlayerData(player)
	end
end)

return Leaderboards
