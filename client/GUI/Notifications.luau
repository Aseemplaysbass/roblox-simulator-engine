local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local Gui = PlayerGui:WaitForChild("Notifications")
local Frame = Gui.Frame

local Template = Frame.Template

local Notifications = {}

function Notifications.Create(text: string, color: "Green" | "Yellow" | "Red"?)
	color = if color then color else "Red"
	
	local backgroundColor3 = 
		if color == "Green" then Color3.fromRGB(85, 255, 127)
		elseif color == "Yellow" then Color3.fromRGB(255, 255, 127)
		else Color3.fromRGB(255, 83, 86)
	
	local clone = Template:Clone()
	clone.Parent = Frame
	clone.Visible = true
	clone.BackgroundColor3 = backgroundColor3
	clone.Title.Text = text
	
	task.delay(5, function()
		clone:Destroy()
	end)
	
	if color == "Red" then
		ReplicatedStorage.Sounds.Error:Play()
	elseif color == "Green" then
		ReplicatedStorage.Sounds.Confirm:Play()
	end
end

return Notifications
