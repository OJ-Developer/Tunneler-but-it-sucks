local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ScriptSignal = require(script.Parent.ScriptSignal)
local Utils = require(ReplicatedStorage.Modules.Utils)
local LinkedData = require(ReplicatedStorage.Services.LinkedData)

local button = {}

function button.new(buttonUI: GuiButton)
	local newButton = {
		instance = buttonUI,
	}
	
	LinkedData.Set(buttonUI, "UiButtonClass", newButton)
	
	return newButton
end

return button
