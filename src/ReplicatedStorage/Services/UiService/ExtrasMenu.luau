local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ScreenEffects = require(script.Parent.ScreenEffects)
local UiButton = require(ReplicatedStorage.Classes.UiButton)
local ExtrasPlaceData = require(ReplicatedStorage.Data.ExtrasPlaceData)
local Sounds = require(ReplicatedStorage.Data.Sounds)
local AudioService = require(ReplicatedStorage.Services.AudioService)
local LinkedData = require(ReplicatedStorage.Services.LinkedData)

local events = ReplicatedStorage.Events
local teleportPlayer = events.TeleportPlayer

local player = game.Players.LocalPlayer
local gui = player.PlayerGui.Gui
local extras = gui.Extras.Extras
local musicMenu = extras.Music
local songsMenu = musicMenu.Songs
local olderVersionsMenu = extras.OlderVersions
local joinOtherPlaceMenu = extras.JoinOtherPlace

local joinOtherPlaceConnection

local ExtrasMenu = {}

local function openJoinOtherPlaceMenu(placeData)
    joinOtherPlaceMenu.Title.Text = placeData.Name
    joinOtherPlaceMenu.Back.Show.Value = placeData.ReturnTo
    if joinOtherPlaceConnection then
        joinOtherPlaceConnection:Disconnect()
    end
    local enterButton = UiButton.new(joinOtherPlaceMenu.Enter)
    joinOtherPlaceConnection = enterButton.OnClick:Connect(function()
        teleportPlayer:FireServer(placeData.Id)
        ScreenEffects.FadeScreenColourOverlay(1, {Transparency = 1})
    end)
    joinOtherPlaceMenu.Visible = true
end

function ExtrasMenu.Init()
    -- music menu
    for name, songData in Sounds.Music do
        local newButton = songsMenu.ReferenceButton:Clone()
        newButton.Name = name
        newButton.Text = songData.DisplayName or name
        newButton.Parent = songsMenu
        local buttonClass = UiButton.new(newButton)
        buttonClass.OnClick:Connect(function()
            AudioService.PlaySong(songData)
        end)
        newButton.Visible = true
    end

    -- tech demo button
    LinkedData.Get(extras.Extras.TechDemo, "UiButtonClass").OnClick:Connect(function()
        openJoinOtherPlaceMenu(ExtrasPlaceData.Other.TechDemo)
    end)

    -- older versions menu
    for _, placeData in ExtrasPlaceData.OlderVersions do
        local newButton = olderVersionsMenu.Versions.ReferenceButton:Clone()
        newButton.Text = placeData.Name
        newButton.Parent = olderVersionsMenu.Versions
        local buttonClass = UiButton.new(newButton)
        buttonClass.OnClick:Connect(function()
            openJoinOtherPlaceMenu(placeData)
        end)
        newButton.Visible = true
    end
end

return ExtrasMenu