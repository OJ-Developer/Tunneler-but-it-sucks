local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sounds = require(ReplicatedStorage.Data.Sounds)
local AudioService = require(ReplicatedStorage.Services.AudioService)

local player = game.Players.LocalPlayer
local char = player.Character
local rootPart = char:WaitForChild("HumanoidRootPart")
local menuUI = player.PlayerGui.MainMenu

local module = {}

function module.Start()
	
	rootPart.Anchored = true

	menuUI.Enabled = true
	menuUI.MainMenu.Visible = true

	local camera = workspace.CurrentCamera
	camera.CFrame = workspace.Map.Other.Camera.CFrame

	AudioService.PlaySong(Sounds.Music.TunnelerButItSucks)
end

function module.Cleanup()
	menuUI.Enabled = false
end

return module
