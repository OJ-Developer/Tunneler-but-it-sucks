local TweenService = game:GetService("TweenService")

local activatedTexture = "rbxassetid://18169578588"
local deactivatedTexture = "rbxassetid://18871132115"

local module = {}
module.__index = module

function module.new(standingButton)
	local stand = standingButton.Stand

	stand.TextureID = deactivatedTexture
	
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
	stand.TextureID = activatedTexture

	task.wait(self.model.Configuration.PressTime.Value)

	activated.Value = false
	TweenService:Create(buttonPart, TweenInfo.new(0.1), {Position = upPos.WorldPosition}):Play()
	stand.TextureID = deactivatedTexture
end

return module