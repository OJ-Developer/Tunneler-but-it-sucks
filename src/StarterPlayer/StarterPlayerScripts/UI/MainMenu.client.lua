local rs = game:GetService("ReplicatedStorage")

local events = rs.Events
local loadLevelEvent = events.Levels.LoadLevel

events.GameLoaded.Event:Wait()

local uiButton = require(script.Parent.Classes.Button)
local cameraModule = require(script.Parent.Parent.CameraScript.CameraModule)

local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local mainMenu = playerGui.MainMenu.MainMenu
local playMenu = playerGui.MainMenu.PlayMenu
local settingsMenu = playerGui.Settings


-- main stuff
local playButton = uiButton.new(mainMenu.Play)
local settingsButton = uiButton.new(mainMenu.Settings)
local quitButton = uiButton.new(mainMenu.Quit)
local extrasButton = uiButton.new(mainMenu.Extras)

playButton.OnClick:Connect(function()
	if playMenu.Visible or settingsMenu.Enabled or playerGui.Extras.Enabled then return end
	playMenu.Visible = true
end)
settingsButton.OnClick:Connect(function()
	if playMenu.Visible or settingsMenu.Enabled or playerGui.Extras.Enabled then return end
	settingsMenu.Enabled = true
end)
quitButton.OnClick:Connect(function()
	if playMenu.Visible or settingsMenu.Enabled or playerGui.Extras.Enabled then return end
	game.Players.LocalPlayer:Kick("That's what the quit button does")
end)
extrasButton.OnClick:Connect(function()
	if playMenu.Visible or settingsMenu.Enabled or playerGui.Extras.Enabled then return end
	playerGui.Extras.Enabled = true
end)


-- level options
local levels = rs:WaitForChild("Levels"):GetChildren()
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
		
		local loadLevelButton = uiButton.new(newLevelOption.Play)
		loadLevelButton.OnClick:Connect(function()
			loadLevelEvent:Fire(level.Name)
			cameraModule.Stop()
			playMenu.Visible = false
			playMenu.Parent.Enabled = false
		end)
	end
end

local closePlayMenuButton = uiButton.new(playMenu.Close)
closePlayMenuButton.OnClick:Connect(function()
	playMenu.Visible = false
end)