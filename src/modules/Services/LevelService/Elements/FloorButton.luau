local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")

local RaycastUtils = require(ReplicatedStorage.Modules.Utils.RaycastUtils)

local module = {}
module.__index = module

function module.new(floorButton)
	local buttonPart = floorButton.Button
	local buttonBase = floorButton.Base
	local hitbox = floorButton.HitBox

	local activated = floorButton.Activated

	local upPos = buttonBase.UpPos
	local downPos =  buttonBase.DownPos

	local t = task.spawn(function()
		while task.wait() do
			local partsInHitbox = workspace:GetPartsInPart(hitbox, RaycastUtils.overlapParams(RaycastUtils.FdiPresets.FloorButtonActivators))
			local newActivated = false
			if #partsInHitbox > 0 then
				newActivated = true
			end

			if floorButton:GetAttribute("Activated") ~= newActivated then
				floorButton:SetAttribute("Activated", newActivated)

				activated.Value = newActivated
				local tween = tweenService:Create(buttonPart, TweenInfo.new(0.2), {Position = newActivated and downPos.WorldPosition or upPos.WorldPosition})
				tween:Play()
				tween.Completed:Wait()
			end
		end
	end)
	
	return setmetatable({t=t}, module)
end

function module:Cleanup()
	task.cancel(self.t)
end

return module
