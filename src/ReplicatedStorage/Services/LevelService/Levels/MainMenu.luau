local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sounds = require(ReplicatedStorage.Data.Sounds)
local AudioService = require(ReplicatedStorage.Services.AudioService)

local player = game.Players.LocalPlayer
local char = player.Character
local rootPart = char:WaitForChild("HumanoidRootPart")
local menuUI = player.PlayerGui.Gui.MainMenu

local module = {}

function module.Start()
	
	rootPart.Anchored = true

	menuUI.Enabled = true
	menuUI.MainMenu.Visible = true

	AudioService.PlaySong(Sounds.Music.TunnelerButItSucks)
end

function module.Cleanup()
	menuUI.Enabled = false
end

return module
