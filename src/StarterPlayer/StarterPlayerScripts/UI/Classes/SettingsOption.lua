local event = require(script.Parent.Parent.Parent.Classes.Event)
local instanceUtils = require(script.Parent.Parent.Parent.Utils.InstanceUtils)
local LinkedData = require(script.Parent.Parent.Parent.Services.LinkedData)

local button = {}



function button.new(buttonUI: GuiButton)
	local newButton = {
		instance = buttonUI,
	}
	
	LinkedData.Set(buttonUI, "UiButtonClass", newButton)
	
	return newButton
end



return button
