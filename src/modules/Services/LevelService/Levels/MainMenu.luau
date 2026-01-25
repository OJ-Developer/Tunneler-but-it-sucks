local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sounds = require(ReplicatedStorage.Modules.Data.Sounds)
local AudioService = require(ReplicatedStorage.Modules.Services.AudioService)

local module = {}

function module.Start()
	local player = game.Players.LocalPlayer
	local char = player.Character
	local rootPart = char:WaitForChild("HumanoidRootPart")
	rootPart.Anchored = true

	local menuUI = player.PlayerGui.MainMenu
	menuUI.Enabled = true
	menuUI.MainMenu.Visible = true

	local camera = workspace.CurrentCamera
	camera.CFrame = workspace.Map.Other.Camera.CFrame

	AudioService.PlaySong(Sounds.Music.TunnelerButItSucks)
end

function module.Cleanup()
	
end

return module
