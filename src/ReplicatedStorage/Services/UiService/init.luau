local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiButton = require(ReplicatedStorage.Classes.UiButton)
local Utils = require(ReplicatedStorage.Modules.Utils)
local Crosshair = require(script.Crosshair)
local ExtrasMenu = require(script.ExtrasMenu)
local LoadingScreen = require(script.LoadingScreen)
local MainMenu = require(script.MainMenu)
local PauseMenu = require(script.PauseMenu)
local ScreenEffects = require(script.ScreenEffects)
local SettingsMenu = require(script.SettingsMenu)

local UiService = {
    MainMenu = MainMenu,
    PauseMenu = PauseMenu,
    SettingsMenu = SettingsMenu,
    Crosshair = Crosshair,
    LoadingScreen = LoadingScreen,
    ScreenEffects = ScreenEffects,
    ExtrasMenu = ExtrasMenu
}

local player = Players.LocalPlayer
local playerGui = player.PlayerGui.Gui

function UiService.Init()
    for _, button in CollectionService:GetTagged("uiButton") do
        if button:IsDescendantOf(playerGui) then
            UiButton.new(button)
        end
    end

    for _, module in UiService do
        if typeof(module) == "table" then
           if module.Init then
                module.Init()
            end 
        end
    end
end

function UiService.Start()
    for _, module in UiService do
        if typeof(module) == "table" then
            if module.Start then
                module.Start()
            end
        end
    end
end

local devstats = playerGui.DevStats.Frame

function UiService.UpdateDevstats(fps: number, inBluePortal: boolean, inRedPortal: boolean, velocity: Vector3)
    devstats.FpsValue.Text = fps
    devstats.BluePortalZoneValue.Text = inBluePortal and "true" or "false"
    devstats.RedPortalZoneValue.Text = inRedPortal and "true" or "false"
    devstats.PlayerVelocityValue.Text = `{Utils.roundVector(velocity)} | {math.round(velocity.Magnitude)}`
end

return UiService