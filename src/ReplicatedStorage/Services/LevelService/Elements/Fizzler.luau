local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Garbage = require(ReplicatedStorage.Classes.Garbage)
local World = require(ReplicatedStorage.Modules.World)
local LinkedData = require(ReplicatedStorage.Services.LinkedData)
local PortalService = require(ReplicatedStorage.Services.PortalService)

local Fizzler = {}
Fizzler.__index = Fizzler

function Fizzler.new(fizzler)
	local self = setmetatable({}, Fizzler)

	self.Instance = fizzler

	self.StartEnabled = fizzler.Configuration.StartEnabled.Value
	self.Enabled = self.StartEnabled

	self.Garbage = Garbage.new()
	
	return self
end

function Fizzler:Init()
	local fizzler = self.Instance

	if self.Enabled then
		fizzler.Transparency = 0.5
		fizzler.ParticleEmitter.Enabled = true
	else
		fizzler.Transparency = 1
		fizzler.ParticleEmitter.Enabled = false
	end

	local activatorObject = fizzler.Configuration.Activator
	local activator
	if activatorObject.Value then
		activator = LinkedData.Get(activatorObject.Value, "ElementClass")
	end

	if activator then
		self.Garbage:Add(activator.OnActivated:Connect(function(activated)
			self:SetActivated(activated)
		end))
	end

	self.Garbage:Add(task.spawn(function()
		while task.wait() do
			if self.Enabled then
				local objectsInFizzler = workspace:GetPartsInPart(fizzler, World.overlapParams(World.ParamPreset.Objects))

				for _, object in objectsInFizzler do
					LinkedData.Get(object, "ObjectClass"):Fizzle()
				end

				local playerInFizzler = workspace:GetPartsInPart(fizzler, World.overlapParams(World.ParamPreset.Player))

				if #playerInFizzler > 0 then
					if workspace.BluePortal.Fizzleable.Value then
						PortalService.PlacePortal(workspace.BluePortal, false, nil, true, CFrame.new(Vector3.new(0,-20,20)))
					end
					if workspace.RedPortal.Fizzleable.Value then
						PortalService.PlacePortal(workspace.RedPortal, true, nil, true, CFrame.new(Vector3.new(0,-20,20)))
					end
				end
			end
		end
	end))
end

function Fizzler:SetActivated(activated)
	self.Enabled = activated ~= self.StartEnabled
	if self.Enabled then
		self.Instance.Transparency = 0.5
		self.Instance.ParticleEmitter.Enabled = true
	else
		self.Instance.Transparency = 1
		self.Instance.ParticleEmitter.Enabled = false
	end
end

function Fizzler:Cleanup()
	self.Garbage:Cleanup()
end

return Fizzler
