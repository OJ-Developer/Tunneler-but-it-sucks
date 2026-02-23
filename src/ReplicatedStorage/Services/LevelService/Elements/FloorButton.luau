local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")

local Garbage = require(ReplicatedStorage.Classes.Garbage)
local ScriptSignal = require(ReplicatedStorage.Packages.GoodSignal)
local World = require(ReplicatedStorage.Modules.World)

local FloorButton = {}
FloorButton.__index = FloorButton

function FloorButton.new(floorButton)
	local self = setmetatable({}, FloorButton)

	self.Model = floorButton
	self.OnActivated = ScriptSignal.new()
	self.Garbage = Garbage.new()
	
	return self
end

function FloorButton:Init()
	local floorButton = self.Model

	local buttonPart = floorButton.Button
	local buttonBase = floorButton.Base
	local hitbox = floorButton.HitBox

	local activated = false

	local upPos = buttonBase.UpPos
	local downPos =  buttonBase.DownPos

	self.Garbage:Add(task.spawn(function()
		while task.wait() do
			local partsInHitbox = workspace:GetPartsInPart(hitbox, World.overlapParams(World.ParamPreset.FloorButtonActivators))
			local newActivated = false
			if #partsInHitbox > 0 then
				newActivated = true
			end

			if activated ~= newActivated then
				activated = newActivated
				self.OnActivated:Fire(activated)
				local tween = tweenService:Create(buttonPart, TweenInfo.new(0.2), {Position = activated and downPos.WorldPosition or upPos.WorldPosition})
				tween:Play()
				tween.Completed:Wait()
			end
		end
	end))
end

function FloorButton:Cleanup()
	self.Garbage:Cleanup()
end

return FloorButton
