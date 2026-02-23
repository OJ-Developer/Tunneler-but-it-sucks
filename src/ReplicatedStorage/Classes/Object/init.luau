local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local objects = ReplicatedStorage.Assets.Objects

local ScriptSignal = require(ReplicatedStorage.Packages.GoodSignal)
local linkedData = require(script.Parent.Parent.Services.LinkedData)

local player = Players.LocalPlayer
local char = player.Character

shared.PlayerState.HoldingObjectChanged = ScriptSignal.new()

local module = {}
module.__index = module

export type ObjectType = typeof(module) & {
	Model: Part,
	Fizzled: boolean,
	OnFizzle: typeof(ScriptSignal)
}

function module.new(objectName: string, cframe: CFrame, ...)
	local self = objects[objectName]:Clone()
	self.Parent = workspace.Map.Objects
	self.CFrame = cframe
	
	return module.giveFunctionality(self, ...)
end

function module.giveFunctionality(object: Part, ...)
	local self = setmetatable({}, module)

	self.Model = object
	self.Fizzled = false
	self.OnFizzle = ScriptSignal.new()
	self.UniqueId = HttpService:GenerateGUID(false)

	object:SetAttribute("Initialized", true)

	linkedData.Set(object, "ObjectClass", self)

	local objectModule = script.ObjectTypes:FindFirstChild(object.Name)
	if objectModule and objectModule:IsA("ModuleScript") then
		local objectTable = require(objectModule).new(object, ...)
		linkedData.Set(object, "SpecificObjectClass", objectTable)
	end

	return self
end

function module:Fizzle()
	self.Fizzled = true
	self.OnFizzle:Fire()
	local object = self.Model

	if shared.PlayerState.HoldingObject == object then
		self:Drop()
	end

    task.spawn(function()
		if linkedData.Get(object) then
			if linkedData.Get(object, "SpecificObjectClass") and linkedData.Get(object, "SpecificObjectClass").Cleanup then
				linkedData.Get(object, "SpecificObjectClass"):Cleanup()
			end
			
			linkedData.Clear(object)
		end
		object:SetAttribute("Fizzled", true)
		
		local cloneObject = object:Clone()
		object:Destroy()

		cloneObject.Parent = workspace
		cloneObject.Name = "fizzledObject"

		cloneObject.CanCollide = false
		cloneObject.Anchored = true
		if cloneObject:IsA("MeshPart") then
			cloneObject.TextureID = ""
		end
		cloneObject.Material = Enum.Material.CorrodedMetal
		cloneObject.Transparency = 0.5

		local particleEmiter = Instance.new("ParticleEmitter", cloneObject)
		particleEmiter.Size = NumberSequence.new(0.2)
		particleEmiter.Lifetime = NumberRange.new(0.1)
		particleEmiter.Rate = 1000
		particleEmiter.SpreadAngle = Vector2.new(180)

		task.wait(2)

		cloneObject:Destroy()
	end)
end

function module:Pickup()
	local object = self.Model
    --object.Anchored = true
	for _, constraint in char.NoObjectCollision:GetChildren() do
		constraint.Part1 = self.Model
	end
	shared.PlayerState.HoldingObject = object
	shared.PlayerState.HoldingObjectChanged:Fire(self)
end

function module.Drop()
    if shared.PlayerState.HoldingObject then
		shared.PlayerState.HoldingObject.Anchored = false
		shared.PlayerState.HoldingObject.CanCollide = true
		shared.PlayerState.HoldingObject.AssemblyLinearVelocity = Vector3.zero
		shared.PlayerState.HoldingObject.AssemblyAngularVelocity = Vector3.zero
		shared.PlayerState.HoldingObject = nil
		for _, constraint in char.NoObjectCollision:GetChildren() do
			constraint.Part1 = nil
		end
		shared.PlayerState.HoldingObjectChanged:Fire()
	else
		warn("tried to drop object with no object beind held")
	end
end

return module