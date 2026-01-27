local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TweenService = game:GetService("TweenService")

local MiscData = require(ReplicatedStorage.Data.MiscData)

local module = {}
module.__index = module

function module.new(standingButton)
	local stand = standingButton.Stand

	stand.TextureID = MiscData.StandingButtonTextures.Deactivated
	
	return setmetatable({model = standingButton}, module)
end

function module:Press()
	local buttonPart = self.model.Button
	local stand = self.model.Stand

	local activated = self.model.Activated

	local upPos = stand.UpPos
	local downPos = stand.DownPos

	activated.Value = true
	TweenService:Create(buttonPart, TweenInfo.new(0.1), {Position = downPos.WorldPosition}):Play()
	stand.TextureID = MiscData.StandingButtonTextures.Activated

	task.wait(self.model.Configuration.PressTime.Value)

	activated.Value = false
	TweenService:Create(buttonPart, TweenInfo.new(0.1), {Position = upPos.WorldPosition}):Play()
	stand.TextureID = MiscData.StandingButtonTextures.Deactivated
end

return module