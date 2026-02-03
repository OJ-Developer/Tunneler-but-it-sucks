local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ScriptSignal = require(script.Parent.ScriptSignal)
local LinkedData = require(ReplicatedStorage.Services.LinkedData)

local SettingsOption = {}
SettingsOption.__index = SettingsOption

function SettingsOption.new(optionUi)
	local newButton = setmetatable({
		Instance = optionUi,
		Type = optionUi.Type.Value,
		OnChange = ScriptSignal.new()
	}, SettingsOption)
	
	if newButton.Type == "bool" then
		newButton.State = optionUi.Default.Value
		optionUi.Button.Text = newButton.State and "On" or "Off"

		LinkedData.Get(optionUi.Button, "UiButtonClass").OnClick:Connect(function()
			newButton.State = not newButton.State
			optionUi.Button.Text = newButton.State and "On" or "Off"
			newButton.OnChange:Fire(newButton.State)
		end)
	elseif newButton.Type == "slider" then
		newButton.Range = {
			min = optionUi.Min.Value,
			max = optionUi.Max.Value
		}
	end

	LinkedData.Set(optionUi, "SettingsOptionClass", newButton)
	
	return newButton
end

return SettingsOption
