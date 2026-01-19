local tweenService = game:GetService("TweenService")
local rs = game:GetService("ReplicatedStorage")

local events = rs.Events
local clickEvent = events.Game.StandingButtonClick

local module = {}
module.__index = module

function module.new(standingButton)
	local buttonPart = standingButton.Button
	local stand = standingButton.Stand

	local activated = standingButton.Activated

	local upPos = stand.UpPos
	local downPos = stand.DownPos

	stand.TextureID = script.DeactivatedTexture.Value

	local c = clickEvent.Event:Connect(function(clickedButton)
		if clickedButton == buttonPart then
			activated.Value = true
			tweenService:Create(buttonPart, TweenInfo.new(0.1), {Position = downPos.WorldPosition}):Play()
			stand.TextureID = script.ActivatedTexture.Value

			wait(standingButton.Configuration.PressTime.Value)

			activated.Value = false
			tweenService:Create(buttonPart, TweenInfo.new(0.1), {Position = upPos.WorldPosition}):Play()
			stand.TextureID = script.DeactivatedTexture.Value
		end
	end)
	
	return setmetatable({c=c}, module)
end

function module:Cleanup()
	self.c:Disconnect()
end

return module