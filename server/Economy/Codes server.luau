local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CodesConfig = require(ReplicatedStorage.Configs.Codes)
local PlayerData = require(ServerScriptService.PlayerData.Manager)

local Remotes = ReplicatedStorage.Remotes

local function RedeemCode(player: Player, testCode: string)
	local code = CodesConfig.GetValidCode(testCode)
	if not code then return "Invalid" end
	
	local isExpired = CodesConfig.IsCodeExpired(code)
	if isExpired then return "Expired" end
	
	local profile = PlayerData.Profiles[player]
	if not profile then return end
	
	local isRedeemed = CodesConfig.IsCodeAlreadyRedeemed(code, profile.Data)
	if isRedeemed then return "Already Redeemed!" end
	
	local reward = CodesConfig.Config[code].Reward
	local rewardType = reward.Type
	local rewardAmount = reward.Amount
	
	if rewardType == "Pi" then
		PlayerData.AdjustPi(player, rewardAmount)
	elseif rewardType == "Sigma" then
		PlayerData.AdjustSigma(player, rewardAmount)
	end
	
	profile.Data.Codes[code] = true
	Remotes.UpdateCode:FireClient(player, code)
	return "Success"
end

Remotes.RedeemCode.OnServerInvoke = RedeemCode