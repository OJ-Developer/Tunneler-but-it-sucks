local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")
local rs = game:GetService("ReplicatedStorage")

local events = rs.Events
events.GameLoaded.Event:Wait()
local enableCrosshairEvent = events.UI.EnableCrosshair
local disableCrosshairEvent = events.UI.DisableCrosshair

local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local developerConsole = playerGui.DeveloperConsole.Frame
local history = developerConsole.History
local commandInput = developerConsole.CommandInput

local devConsoleCommands = script.Parent.Parent.DevConsoleCommands

local function addToHistory(text: string | {})
	if not text then return end
	
	if type(text) == "table" then
		for _, v in pairs(text) do
			addToHistory(v)
		end
		
		return
	end
	
	local textObject = history.Referance:Clone()
	textObject.Name = "HistoryText"
	textObject.Parent = history
	textObject.Text = text
	local historyTextLabels = {}
	for _, historyText in pairs(history:GetChildren()) do
		if historyText.Name == "HistoryText" then
			table.insert(historyTextLabels, historyText)
		end
	end
	
	textObject.Visible = true
end

local function runCommand(event: Instance, operands: {any}, addInHistory: boolean)
	if addInHistory then
		addToHistory(commandInput.Text)
	end 
	if event:IsA("RemoteEvent") then
		event:FireServer(unpack(operands))
	elseif event:IsA("BindableEvent") then
		event:Fire(unpack(operands))
	elseif event:IsA("ModuleScript") then
		addToHistory(require(event)(unpack(operands)))
	elseif event:IsA("ObjectValue") then
		runCommand(event.Value, operands, false)
	end
end

commandInput.FocusLost:Connect(function(enter)
	if enter then
		local arguments = string.split(commandInput.Text, " ")
		local command = arguments[1]
		local operands = {unpack(arguments, 2)}

		local event = devConsoleCommands:FindFirstChild(command)
		
		if event then
			runCommand(event, operands, true)
		elseif event == nil then
			addToHistory(commandInput.Text.." is not a valid command.")
		end
		commandInput.Text = ""
	end
end)

local function toggleVisibility()
	developerConsole.Visible = not developerConsole.Visible
	developerConsole.UnlockMouse.Visible = developerConsole.Visible
	--developerConsole.UnlockMouse.Modal = developerConsole.Visible
	if developerConsole.Visible then
		disableCrosshairEvent:Fire()
	else
		if workspace.Map.LevelSettings:FindFirstChild("MenuLevel") and workspace.Map.LevelSettings.MenuLevel.Value then return end
		enableCrosshairEvent:Fire()
	end
end

UIS.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.Backquote then
		if gameProcessed then return end
		if developerConsole.Parent.Enabled then
			toggleVisibility()
		end
	end
end)

CAS:BindAction("ToggleDevConsole", toggleVisibility, true)