local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LinkedData = require(ReplicatedStorage.Services.LinkedData)

local player = Players.LocalPlayer
local playerGui = player.PlayerGui.Gui

local SettingsMenu = {}

function SettingsMenu.Init()
    local settingsMenu = playerGui.Settings
    local settingsMenus = settingsMenu.Settings.SettingsMenus
    LinkedData.Get(settingsMenus.Back, "UiButtonClass").OnClick:Connect(function()
        if workspace.Map.LevelSettings.MenuLevel.Value then
            playerGui.MainMenu.MainMenu.Visible = true
        else
            playerGui.PauseMenu.Enabled = true
        end
    end)
end

return SettingsMenu