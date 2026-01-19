local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
ReplicatedStorage.Events.GameLoaded.Event:Wait()
task.wait()

local events = ReplicatedStorage.Events
local disableCrosshairEvent = events.UI.DisableCrosshair
local enableCrosshairEvent = events.UI.EnableCrosshair
local updateDevStat = events.Other.UpdateDevStat

local linkedData = require(script.Parent.Parent.Services.LinkedData)

local player = game.Players.LocalPlayer
local char = player.Character
local rootPart = char.HumanoidRootPart
local playerGui = player.PlayerGui


-- JOIN NOTE

local joinNote = playerGui.JoinNote
joinNote.Enabled = true
linkedData.Get(joinNote.Frame.TextButton, "UiButtonClass").OnClick:Connect(function()
	joinNote.Enabled = false
end)


-- PAUSE MENU

local pauseMenu = playerGui.PauseMenu.MainMenu
local resumeButton = linkedData.Get(pauseMenu.Resume, "UiButtonClass")
resumeButton.OnClick:Connect(function()
	rootPart.Anchored = false
end)

local function pause(actionName, inputState)
	if inputState == Enum.UserInputState.Begin and not workspace.Map.LevelSettings.MenuLevel.Value then
		pauseMenu.Parent.Enabled = not pauseMenu.Parent.Enabled
		rootPart.Anchored = pauseMenu.Parent.Enabled
		if pauseMenu.Parent.Enabled then
			disableCrosshairEvent:Fire()
		else
			enableCrosshairEvent:Fire()
		end
	end
end

ContextActionService:BindAction("Pause", pause, true, Enum.KeyCode.Tab)


-- DEVSTATS

local devstats = playerGui.DevStats.Frame

updateDevStat.Event:Connect(function(statName, value)
	local statUi = devstats:FindFirstChild(statName.."Value")
	if statUi and statUi:IsA("TextLabel") then
		statUi.Text = value
	end
end)