local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ScriptSignal = require(script.Parent.ScriptSignal)
local LinkedData = require(ReplicatedStorage.Services.LinkedData)

local SettingsOption = {}
SettingsOption.__index = SettingsOption

function SettingsOption.new(optionUi)
	local self = setmetatable({}, SettingsOption)

	self.Instance = optionUi
	self.Type = optionUi.Type.Value
	self.OnChange = ScriptSignal.new()
	
	if self.Type == "bool" then
		self.State = optionUi.Default.Value
		optionUi.Button.Text = self.State and "On" or "Off"

		LinkedData.Get(optionUi.Button, "UiButtonClass").OnClick:Connect(function()
			self.State = not self.State
			optionUi.Button.Text = self.State and "On" or "Off"
			self.OnChange:Fire(self.State)
		end)
	elseif self.Type == "slider" then
		self.Range = {
			min = optionUi.Min.Value,
			max = optionUi.Max.Value
		}
	end

	LinkedData.Set(optionUi, "SettingsOptionClass", self)
	
	return self
end

return SettingsOption
