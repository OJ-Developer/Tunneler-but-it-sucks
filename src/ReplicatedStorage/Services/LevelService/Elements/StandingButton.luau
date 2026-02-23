local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TweenService = game:GetService("TweenService")

local ScriptSignal = require(ReplicatedStorage.Packages.GoodSignal)
local MiscData = require(ReplicatedStorage.Data.MiscData)

local StandingButton = {}
StandingButton.__index = StandingButton

function StandingButton.new(standingButton)
	local self = setmetatable({}, StandingButton)

	self.Model = standingButton
	self.OnActivated = ScriptSignal.new()

	local stand = standingButton.Stand

	stand.TextureID = MiscData.StandingButtonTextures.Deactivated
	
	return self
end

function StandingButton:Press()
	local buttonPart = self.Model.Button
	local stand = self.Model.Stand

	local upPos = stand.UpPos
	local downPos = stand.DownPos

	self.OnActivated:Fire(true)
	TweenService:Create(buttonPart, TweenInfo.new(0.1), {Position = downPos.WorldPosition}):Play()
	stand.TextureID = MiscData.StandingButtonTextures.Activated

	task.wait(self.Model.Configuration.PressTime.Value)

	self.OnActivated:Fire(false)
	TweenService:Create(buttonPart, TweenInfo.new(0.1), {Position = upPos.WorldPosition}):Play()
	stand.TextureID = MiscData.StandingButtonTextures.Deactivated
end

return StandingButton