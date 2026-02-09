local TweenService = game:GetService("TweenService")
local speed = 3

local colours = {
	blue = ColorSequence.new(Color3.new(0, 0.533333, 1),Color3.new(0.219608, 0.176471, 0.439216)),
	red = ColorSequence.new(Color3.new(0, 0.533333, 1),Color3.new(0.666667, 0, 0)),
	yellow = ColorSequence.new(Color3.new(0, 0.533333, 1),Color3.new(0.792157, 0.490196, 0))
}

local LunarisScreen = {}
LunarisScreen.__index = LunarisScreen

function LunarisScreen.new(ui)
	local self = setmetatable({}, LunarisScreen)
	self.UiObject = ui
	return self
end

function LunarisScreen:Init()
	local ui = self.UiObject

	local img1 = ui.ImageLabel1
	local img2 = ui.ImageLabel2

	ui.Frame.UIGradient.Color = colours.blue

	self.t = task.spawn(function()
		while true do
			img1.Position = UDim2.fromScale(0, 0)
			img2.Position = UDim2.fromScale(0,-1)
			TweenService:Create(img1, TweenInfo.new(speed,Enum.EasingStyle.Linear), {Position = UDim2.fromScale(0,1)}):Play()
			TweenService:Create(img2, TweenInfo.new(speed,Enum.EasingStyle.Linear), {Position = UDim2.fromScale(0,0)}):Play()
			task.wait(speed)
		end
	end)
end

function LunarisScreen:Cleanup()
	task.cancel(self.t)
end

return LunarisScreen
