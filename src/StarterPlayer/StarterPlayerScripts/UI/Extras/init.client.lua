local rs = game:GetService("ReplicatedStorage")
local tps = game:GetService("TeleportService")

local events = rs.Events
local playSong = events.Audio.PlaySong
local teleportPlayer = events.Other.TeleportPlayer

events.GameLoaded.Event:Wait()

local player = game.Players.LocalPlayer
local gui = player.PlayerGui
local extras = gui.Extras.Extras
local extrasMenu = extras.Extras
local musicMenu = extras.Music
local songsMenu = musicMenu.Songs
local olderVersionsMenu = extras.OlderVersions
local joinOtherPlaceMenu = extras.JoinOtherPlace

local joinPlaceData = require(script.JoinPlaceData)
local uiButton = require(script.Parent.Classes.Button)
local screenEffects = require(script.Parent.Parent.Services.ScreenEffects)

local joinOtherPlaceConnection



-- music menu

for _, song in player.PlayerScripts.Music.Songs:GetChildren() do
	local newButton = songsMenu.ReferenceButton:Clone()
	newButton.Name = song.Name
	newButton.Text = song:GetAttribute("DisplayName") or song.Name
	newButton.MouseButton1Down:Connect(function()
		playSong:Fire(song.Name)
	end)
	newButton.Parent = songsMenu
	uiButton.new(newButton)
	newButton.Visible = true
end



-- join other place menu

joinOtherPlaceMenu.Show.Event:Connect(function(showData)
	joinOtherPlaceMenu.Title.Text = showData
	joinOtherPlaceMenu.Back.Show.Value = joinPlaceData[showData].returnTo
	if joinOtherPlaceConnection then
		joinOtherPlaceConnection:Disconnect()
	end
	local enterButton = uiButton.new(joinOtherPlaceMenu.Enter)
	joinOtherPlaceConnection = enterButton.OnClick:Connect(function()
		teleportPlayer:FireServer(joinPlaceData[showData].id)
		screenEffects.FadeScreenColourOverlay(0, 1)
	end)
end)



-- older versions menu

for name, place in joinPlaceData do
	if place.returnTo == olderVersionsMenu then
		local newButton = olderVersionsMenu.Versions.ReferenceButton:Clone()
		newButton.Name = place.order
		newButton.Text = name
		newButton.ShowData.Value = name
		newButton.Parent = olderVersionsMenu.Versions
		uiButton.new(newButton)
		newButton.Visible = true
	end
end