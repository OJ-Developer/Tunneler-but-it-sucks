local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiButton = require(ReplicatedStorage.Classes.UiButton)
local LinkedData = require(ReplicatedStorage.Services.LinkedData)

local player = Players.LocalPlayer
local playerGui = player.PlayerGui.Gui

local MainMenu = {}

function MainMenu.Init()
    local mainMenu = playerGui.MainMenu
    local mainMenuOptions = mainMenu.MainMenu
    local playMenu = mainMenu.PlayMenu

    local levels = ReplicatedStorage.Levels:GetChildren()
    table.sort(levels, function(a,b)
        if a:GetAttribute("DisplayName") and b:GetAttribute("DisplayName") then
            return a:GetAttribute("DisplayName") < b:GetAttribute("DisplayName")
        end
        return false
    end)

    local exampleLevelOption = playMenu.PlayMenu.ExampleLevelOption

    for _, level in pairs(levels) do
        if level:GetAttribute("ShowOnPlayMenu") then
            local newLevelOption = exampleLevelOption:Clone()
            newLevelOption.LevelNameLabel.Text = level:GetAttribute("DisplayName")
            newLevelOption.LevelIcon.Image = level:GetAttribute("MenuIconId")
            newLevelOption.Name = level.Name
            newLevelOption.Parent = playMenu.PlayMenu
            newLevelOption.Visible = true
            
            local loadLevelButton = UiButton.new(newLevelOption.Play)
            loadLevelButton.OnClick:Connect(function()
                shared.LevelService.LoadLevel(level.Name)
                playMenu.Visible = false
                playMenu.Parent.Enabled = false
            end)
        end
    end

    LinkedData.Get(mainMenuOptions.Quit, "UiButtonClass").OnClick:Connect(function()
        player:Kick("That's what the quit button does")
    end)
end

return MainMenu