local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LinkedData = require(ReplicatedStorage.Services.LinkedData)
local LevelService = shared.LevelService

local player = Players.LocalPlayer
local playerGui = player.PlayerGui

local PauseMenu = {}

function PauseMenu.Init()
    local char = player.Character
    local rootPart = char.HumanoidRootPart

    local pauseMenu = playerGui.PauseMenu

    local function togglePauseMenu()
        pauseMenu.Enabled = not pauseMenu.Enabled
        rootPart.Anchored = pauseMenu.Enabled
        --(pauseMenu.Enabled and disasbleCrosshair or enableCrosshair)()
    end

    ReplicatedStorage.Inputs.Pause.Pressed:Connect(togglePauseMenu)
    LinkedData.Get(pauseMenu.MainMenu.Resume, "UiButtonClass").OnClick:Connect(togglePauseMenu)
    LinkedData.Get(pauseMenu.MainMenu.Quit, "UiButtonClass").OnClick:Connect(function()
        LevelService.LoadLevel("MainMenu")
    end)
end

return PauseMenu