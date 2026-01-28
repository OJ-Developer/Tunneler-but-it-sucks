local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Crosshair = require(script.Parent.Crosshair)
local LinkedData = require(ReplicatedStorage.Services.LinkedData)

local player = Players.LocalPlayer
local playerGui = player.PlayerGui

local PauseMenu = {}

function PauseMenu.Init()
    local char = player.Character
    local rootPart = char.HumanoidRootPart

    local pauseMenu = playerGui.PauseMenu

    local function togglePauseMenu()
        pauseMenu.Enabled = not pauseMenu.Enabled
        rootPart.Anchored = pauseMenu.Enabled;
        (pauseMenu.Enabled and Crosshair.Disable or Crosshair.Enable)()
    end

    ReplicatedStorage.Inputs.Pause.Pressed:Connect(togglePauseMenu)
    LinkedData.Get(pauseMenu.MainMenu.Resume, "UiButtonClass").OnClick:Connect(togglePauseMenu)
    LinkedData.Get(pauseMenu.MainMenu.Quit, "UiButtonClass").OnClick:Connect(function()
        shared.LevelService.LoadLevel("MainMenu")
    end)
end

return PauseMenu