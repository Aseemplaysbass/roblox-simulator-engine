local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes.Trade

local PlayerData = require(ServerScriptService.PlayerData.Manager)
local PetsManager = require(ServerScriptService.Pets)
local PetsConfig = require(ReplicatedStorage.Configs.Pets)

type PendingRequests = {
	[number] : {
		[number] : number
	}
}

type ActiveTrades = {
	[number] : {
		SelectedPets: { [number] : string },
		IsReady: boolean,
		TargetId: number
	}
}

local PendingRequests: PendingRequests = {}
local ActiveTrades: ActiveTrades = {}

local function ToggleTradeRequests(player: Player)
	local profile = PlayerData.Profiles[player]
	if not profile then return end
	
	local currentValue = profile.Data.ReceiveTradeRequests
	profile.Data.ReceiveTradeRequests = not currentValue
	Remotes.ToggleRequests:FireClient(player, not currentValue)
end

local function IsPlayerTrading(player: Player)
	return ActiveTrades[player.UserId] ~= nil
end

local function StartTrade(player1: Player, player2: Player)
	print("Starting trade between " .. player1.Name .. " and" .. player2.Name)
	ActiveTrades[player1.UserId] = {
		SelectedPets = {},
		IsReady = false,
		TargetId = player2.UserId
	}
	ActiveTrades[player2.UserId] = {
		SelectedPets = {},
		IsReady = false,
		TargetId = player1.UserId
	}
	
	local targetRequest = table.find(PendingRequests[player1.UserId], player2.UserId)
	if targetRequest then
		table.remove(PendingRequests[player1.UserId], targetRequest)
	end
	
	local playerRequest = table.find(PendingRequests[player2.UserId], player1.UserId)
	if playerRequest then
		table.remove(PendingRequests[player2.UserId], playerRequest)
	end
	
	Remotes.Start:FireClient(player1, player2.UserId)
	Remotes.Start:FireClient(player2, player1.UserId)
end

local function RespondToRequest(player: Player, userId: number, accept: boolean)
	local targetPlayer = Players:GetPlayerByUserId(userId)
	if not targetPlayer then return end
	
	local targetRequests = PendingRequests[userId]
	if not targetRequests then return end
	
	local hasTargetSentRequest = table.find(targetRequests, player.UserId)
	if not hasTargetSentRequest then return end
	
	if not accept then
		table.remove(targetRequests, hasTargetSentRequest)
		Remotes.RespondToRequest:FireClient(targetPlayer, player.UserId, false)
		return
	end
	
	local isTargetTrading = IsPlayerTrading(targetPlayer)
	if isTargetTrading then return end
	
	StartTrade(player, targetPlayer)
end

local function SendRequest(player: Player, userId: number)
	local targetPlayer = Players:GetPlayerByUserId(userId)
	if not targetPlayer then return end
	
	local targetProfile = PlayerData.Profiles[targetPlayer]
	if not targetProfile then return end
	
	local isTargetAcceptingRequests = targetProfile.Data.ReceiveTradeRequests
	if not isTargetAcceptingRequests then return end
	
	local isTargetTrading = IsPlayerTrading(player)
	if isTargetTrading then return end
	
	local pendingRequests = PendingRequests[player.UserId]
	if pendingRequests then
		local alreadySentRequest = table.find(pendingRequests, userId)
		if alreadySentRequest then return end
	end
	
	local targetRequests = PendingRequests[userId]
	if targetRequests then
		local hasTargetSentRequest = table.find(targetRequests, player.UserId)
		if hasTargetSentRequest then 
			StartTrade(player, targetPlayer)
			return 
		end
	end
	
	Remotes.SendRequest:FireClient(player, userId)
	Remotes.ReceiveRequest:FireClient(targetPlayer, player.UserId)
	table.insert(pendingRequests, userId)
	task.delay(15, function()
		local index = table.find(pendingRequests, userId)
		if index then
			table.remove(pendingRequests, userId)
		end
	end)
end

--

local function TransferPets(player1: Player, player2: Player)
	local player1Trade = ActiveTrades[player1.UserId]
	local player2Trade = ActiveTrades[player2.UserId]
	if not player1Trade or not player2Trade then return end
	
	local player1Profile = PlayerData.Profiles[player1]
	local player2Profile = PlayerData.Profiles[player2]
	if not player1Profile or not player2Profile then return end
	
	local player1OpenSlots = PetsConfig.GetOpenSlots(player1, player1Profile.Data)
	local player2OpenSlots = PetsConfig.GetOpenSlots(player2, player2Profile.Data)
	
	local player1HasEnoughSpace = player1OpenSlots >= #player2Trade.SelectedPets
	local player2HasEnoughSpace = player2OpenSlots >= #player1Trade.SelectedPets
	if not player1HasEnoughSpace or not player2HasEnoughSpace then return end

	for _, uuid in player2Trade.SelectedPets do
		local petInstance = player2Profile.Data.Pets[uuid]
		if not petInstance then continue end
		
		PetsManager.GivePet(player1, petInstance)
		PetsManager.ForceDeletePet(player2, uuid)
	end
	for _, uuid in player1Trade.SelectedPets do
		local petInstance = player1Profile.Data.Pets[uuid]
		if not petInstance then continue end

		PetsManager.GivePet(player2, petInstance)
		PetsManager.ForceDeletePet(player1, uuid)
	end
end

local function CancelTrade(player: Player)
	local trade = ActiveTrades[player.UserId]
	if not trade then return end
	
	local targetPlayer = Players:GetPlayerByUserId(trade.TargetId)
	if not targetPlayer then return end
	
	Remotes.Cancel:FireClient(player)
	Remotes.Cancel:FireClient(targetPlayer)
	
	ActiveTrades[player.UserId] = nil
	ActiveTrades[targetPlayer.UserId] = nil
end

local function Unready(player: Player)
	local trade = ActiveTrades[player.UserId]
	if not trade then return end

	local targetPlayer = Players:GetPlayerByUserId(trade.TargetId)
	if not targetPlayer then return end
	
	local isReady = trade.IsReady
	if not isReady then return end
	
	trade.IsReady = false
	Remotes.Unready:FireClient(player)
	Remotes.TargetUnready:FireClient(targetPlayer)
end

local function ReadyUp(player: Player)
	local trade = ActiveTrades[player.UserId]
	if not trade then return end

	local targetPlayer = Players:GetPlayerByUserId(trade.TargetId)
	if not targetPlayer then return end

	local isReady = trade.IsReady
	if isReady then
		Unready(player)
		return
	end
	
	trade.IsReady = true
	Remotes.Ready:FireClient(player)
	Remotes.TargetReady:FireClient(targetPlayer)
	
	local targetTrade = ActiveTrades[targetPlayer.UserId]
	local areBothReady = trade.IsReady and targetTrade.IsReady
	if areBothReady then
		TransferPets(player, targetPlayer)
		Remotes.Complete:FireClient(player)
		Remotes.Complete:FireClient(targetPlayer)
		ActiveTrades[player.UserId] = nil
		ActiveTrades[targetPlayer.UserId] = nil
	end
end

local function DeselectPet(player: Player, uuid: string)
	local trade = ActiveTrades[player.UserId]
	if not trade then return end

	local targetPlayer = Players:GetPlayerByUserId(trade.TargetId)
	if not targetPlayer then return end
	
	local index = table.find(trade.SelectedPets, uuid)
	if index then
		table.remove(trade.SelectedPets, index)
	end
	
	Remotes.SelectPet:FireClient(player, uuid, false)
	Remotes.TargetRemovePet:FireClient(targetPlayer, uuid)
	Unready(player)
	Unready(targetPlayer)
end

local function SelectPet(player: Player, uuid: string)
	local trade = ActiveTrades[player.UserId]
	if not trade then return end

	local targetPlayer = Players:GetPlayerByUserId(trade.TargetId)
	if not targetPlayer then return end
	
	local isAlreadySelected = table.find(trade.SelectedPets, uuid)
	if isAlreadySelected then 
		DeselectPet(player, uuid)
		return
	end
	
	local profile = PlayerData.Profiles[player]
	if not profile then return end
	
	local pets = profile.Data.Pets
	local petInstance = pets[uuid]
	if not petInstance then return end
	
	if petInstance.Locked or petInstance.Equipped then return end
	
	table.insert(trade.SelectedPets, uuid)
	Remotes.SelectPet:FireClient(player, uuid, true)
	Remotes.TargetAddPet:FireClient(targetPlayer, petInstance)
	Unready(player)
	Unready(targetPlayer)
end

Remotes.SendRequest.OnServerEvent:Connect(SendRequest)
Remotes.RespondToRequest.OnServerEvent:Connect(RespondToRequest)
Remotes.ToggleRequests.OnServerEvent:Connect(ToggleTradeRequests)

Remotes.SelectPet.OnServerEvent:Connect(SelectPet)
Remotes.Cancel.OnServerEvent:Connect(CancelTrade)
Remotes.Unready.OnServerEvent:Connect(Unready)
Remotes.Ready.OnServerEvent:Connect(ReadyUp)

for _, player in Players:GetPlayers() do
	PendingRequests[player.UserId] = {}
end

Players.PlayerAdded:Connect(function(player: Player)
	PendingRequests[player.UserId] = {}
end)
Players.PlayerRemoving:Connect(function(player: Player)
	PendingRequests[player.UserId] = nil
	CancelTrade(player)
end)

