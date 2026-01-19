local tweenService = game:GetService("TweenService")

local player = game.Players.LocalPlayer
local effects = player.PlayerGui.Effects
local fade = effects.Fade
local debugObjects = effects.DebugObjects

local module = {}

function module.FadeScreenColourOverlay(newTransparency: number, Time: number, colour: Color3?)
	if colour then
		fade.BackgroundColor3 = colour
	else
		fade.BackgroundColor3 = Color3.new(0,0,0)
	end
	
	tweenService:Create(fade, TweenInfo.new(Time, Enum.EasingStyle.Linear), {BackgroundTransparency = newTransparency}):Play()
end

function module.setScreenColourOverlay(newTransparency: number, colour: Color3?)
	if colour then
		fade.BackgroundColor3 = colour
	else
		fade.BackgroundColor3 = Color3.new(0,0,0)
	end

	fade.BackgroundTransparency = newTransparency
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
