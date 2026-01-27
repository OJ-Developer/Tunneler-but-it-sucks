local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiButton = require(ReplicatedStorage.Classes.UiButton)
local Crosshair = require(script.Crosshair)
local LoadingScreen = require(script.LoadingScreen)
local MainMenu = require(script.MainMenu)
local PauseMenu = require(script.PauseMenu)
local SettingsMenu = require(script.SettingsMenu)

local UiService = {
    MainMenu = MainMenu,
    PauseMenu = PauseMenu,
    SettingsMenu = SettingsMenu,
    Crosshair = Crosshair,
    LoadingScreen = LoadingScreen
}

local player = Players.LocalPlayer
local playerGui = player.PlayerGui

local subServices = {}

function UiService.Init()
    for _, button in CollectionService:GetTagged("uiButton") do
        if button:IsDescendantOf(playerGui) then
            UiButton.new(button)
        end
    end

    for _, v in script:GetChildren() do
        local module = require(v)
        table.insert(subServices, module)
        if module.Init then
            module.Init()
        end
    end
end

function UiService.Start()
    for _, module in subServices do
        if module.Start then
            module.Start()
        end
    end
end

return UiService