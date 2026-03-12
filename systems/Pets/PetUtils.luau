local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local MouseOver = require(ReplicatedStorage.Libs.MouseOver)
local ViewportModel = require(ReplicatedStorage.Libs.ViewportModel)
local FormatNumber = require(ReplicatedStorage.Libs.FormatNumber.Simple)
local PetsConfig = require(ReplicatedStorage.Configs.Pets)
local StateManager = require(ReplicatedStorage.Client.State)

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local PetEnchantmentGui = PlayerGui:WaitForChild("PetEnchantment")
local Frame = PetEnchantmentGui.Frame

local HoveredButton: TextButton? = nil

RunService.Stepped:Connect(function()
	if HoveredButton then
		local mouse = Player:GetMouse()
		Frame.Position = UDim2.fromOffset(mouse.X, mouse.Y)
	end
end)

local PetUtils = {}

function PetUtils.GetHiddenPetModel(pet: string)
	local model = ReplicatedStorage.Pets[pet]:clone()
	for _, desc in model:GetDescendants() do
		if desc:IsA("BasePart") then
			desc.Color = Color3.fromRGB(0, 0, 0)
		elseif desc:IsA("Decal") then
			desc:Destroy()
		end
	end

	return model
end

function PetUtils.UpdateLayout(container: ScrollingFrame)
	local pets = {}
	for _, child in container:GetChildren() do
		if child:IsA("TextButton") and child.Visible then
			local uuid = child.Name
			local petInstance: PetsConfig.PetInstance = StateManager.GetData().Pets[uuid] or StateManager.GetData().PetBank[uuid]
			if not petInstance then continue end

			local DPS = PetsConfig.GetPetDPS(petInstance)
			table.insert(pets, {
				uuid = uuid,
				equipped = petInstance.Equipped,
				DPS = DPS
			})
		end
	end

	table.sort(pets, function(a, b)
		if a.equipped and not b.equipped then
			return true
		elseif not a.equipped and b.equipped then
			return false
		else
			return a.DPS > b.DPS
		end
	end)

	for i, petData in pets do
		local button = container:FindFirstChild(petData.uuid)
		button.LayoutOrder = i
	end
end

function PetUtils.GetUpgradeColor(pet: PetsConfig.PetInstance)
	local currentUpgrade = PetsConfig.GetCurrentUpgrade(pet)
	return if currentUpgrade == "Golden" then Color3.fromRGB(255, 255, 0)
		elseif currentUpgrade == "Shiny" then Color3.fromRGB(255, 85, 0)
		else Color3.fromRGB(127, 206, 255)
end

local function DisplayEnchantment(display: boolean, uuid: string?)
	local pet = StateManager.GetData().Pets[uuid]
	if pet and pet.Enchantment.Enchantment then
		Frame.Title.Text = `{pet.Enchantment.Level} [{pet.Enchantment.Enchantment}]`
		if Frame.Title.Text == `1 [{pet.Enchantment.Enchantment}]` then
			Frame.Title.Text = `Unique [{pet.Enchantment.Enchantment}]`
		elseif Frame.Title.Text == `2 [{pet.Enchantment.Enchantment}]` then
			Frame.Title.Text = `Exalted [{pet.Enchantment.Enchantment}]`
		elseif Frame.Title.Text == `3 [{pet.Enchantment.Enchantment}]` then
			Frame.Title.Text = `Exotic [{pet.Enchantment.Enchantment}]`
		elseif Frame.Title.Text == `4 [{pet.Enchantment.Enchantment}]` then
			Frame.Title.Text = `Transcendant [{pet.Enchantment.Enchantment}]`
		elseif Frame.Title.Text == `5 [{pet.Enchantment.Enchantment}]` then
			Frame.Title.Text = `Heirloom [{pet.Enchantment.Enchantment}]`
		elseif Frame.Title.Text == `6 [{pet.Enchantment.Enchantment}]` then
			Frame.Title.Text = `Artifact [{pet.Enchantment.Enchantment}]`
		end
	end

	PetEnchantmentGui.Enabled = display and pet and pet.Enchantment.Enchantment
end

function PetUtils.GeneratePet(template: TextButton, container: ScrollingFrame, pet: PetsConfig.PetInstance)
	local clone = template:Clone()
	clone.Parent = container
	clone.Visible = true
	clone.Name = pet.UUID

	clone.PetName.Text = pet.Name
	clone.Equipped.Visible = pet.Equipped
	clone.Dps.Text = FormatNumber.FormatCompact(PetsConfig.GetPetDPS(pet))
	clone.BackgroundColor3 = PetUtils.GetUpgradeColor(pet)

	local model = PetsConfig.GetModel(pet)
	ViewportModel.GenerateViewport(clone.ViewportFrame, model, CFrame.Angles(0, math.rad(-165), 0))

	PetUtils.UpdateLayout(container)

	if pet.Aurora then
		PetsConfig.AuroraTween(clone, 1)
	elseif pet.Rainbow then
		PetsConfig.RainbowTween(clone, 2)
	end

	local enter, leave = MouseOver.MouseEnterLeaveEvent(clone)
	enter:Connect(function()
		HoveredButton = clone
		local gui = clone:FindFirstAncestorOfClass("ScreenGui")
		if gui.Enabled and container.Visible then
			DisplayEnchantment(true, pet.UUID)
		end
	end)
	leave:Connect(function()
		HoveredButton = nil
		DisplayEnchantment(false)
	end)

	return clone
end

function PetUtils.UpdateSearchedPets(searchBar: TextBox, petTable: {}, container: ScrollingFrame)
	local input = string.upper(searchBar.Text)

	local uuids = {}
	for uuid, pet: PetsConfig.PetInstance in petTable do
		if string.find(string.upper(pet.Model), input) then
			table.insert(uuids, pet.UUID)
		end
	end

	for _, child in container:GetChildren() do
		if not child:IsA("GuiButton") or child.Name == "Template" then continue end
		child.Visible = table.find(uuids, child.Name) or input == ""
	end
end

return PetUtils