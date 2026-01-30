local tweenService = game:GetService("TweenService")

local player = game.Players.LocalPlayer
local effects = player.PlayerGui.Gui.Effects
local fade = effects.Fade
local debugObjects = effects.DebugObjects

local module = {}

local propertyAliases = {
	Transparency = "BackgroundTransparency",
	Colour = "BackgroundColor3"
}

function module.FadeScreenColourOverlay(time: number, propertyTable: {})
	local newPropertyTable = {}

	for property, value in propertyTable do
		if fade[property] then
			newPropertyTable[property] = value
		elseif propertyAliases[property] then
			newPropertyTable[propertyAliases[property]] = value
		else
			warn(`"{property}" is not a value property of Frame`)
		end
	end
	
	tweenService:Create(fade, TweenInfo.new(time, Enum.EasingStyle.Linear), newPropertyTable):Play()
end

function module.setScreenColourOverlay(propertyTable: {})
	for property, value in propertyTable do
		if fade[property] then
			fade[property] = value
		elseif propertyAliases[property] then
			fade[propertyAliases[property]] = value
		else
			warn(`"{property}" is not a value property of Frame`)
		end
	end
end

function module.createDebugObject(cframe: CFrame, size: Vector3, shape: Enum.PartType, colour: Color3, showTime: number)
	task.spawn(function()
		local part = Instance.new("Part", debugObjects)
		part.Anchored = true
		part.Transparency = 0.5
		part.CFrame = cframe
		part.Size = size
		part.Shape = shape
		part.Color = colour
		task.wait(showTime)
		part:Destroy()
	end)
end

return module
