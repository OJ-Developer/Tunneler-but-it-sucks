local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ScriptSignal = require(ReplicatedStorage.Classes.ScriptSignal)
local World = require(ReplicatedStorage.Modules.World)

local TouchTrigger = {}
TouchTrigger.__index = TouchTrigger

function TouchTrigger.new(hitboxPart)
	local self = setmetatable({}, TouchTrigger)

	self.OnActivated = ScriptSignal.new()
	self.WasActivated = false
	self.Model = hitboxPart
	
	return self
end

function TouchTrigger:Init()
	local hitboxPart = self.Model

	local singleUse = hitboxPart.Configuration.SingleUse
	
	self.t = task.spawn(function()
		while task.wait() do
			local partsInHitbox = workspace:GetPartsInPart(hitboxPart, World.overlapParams(World.FdiPresets.Player))

			local newActivated = #partsInHitbox > 0

			if self.WasActivated ~= newActivated then
				self.WasActivated = newActivated
				self.OnActivated:Fire(newActivated)
			end

			if newActivated and singleUse.Value then
				break
			end
		end
	end)
end

function TouchTrigger:Cleanup()
	if self.t then
		task.cancel(self.t)
	end	
end

return TouchTrigger