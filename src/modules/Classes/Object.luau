local module = {}
module.__index = module

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local objects = ReplicatedStorage:WaitForChild("Objects")

local Event = require(script.Parent.Event)
local linkedData = require(script.Parent.Parent.Services.LinkedData)

export type ObjectType = typeof(module) & {
	Instance: Part,
	Fizzled: boolean,
	OnFizzle: typeof(Event)
}

function module.new(objectName: string, cframe: CFrame, ...)
	local newObject = objects[objectName]:Clone()
	newObject.Parent = workspace.Map.Objects
	newObject.CFrame = cframe
	
	return module.giveFunctionality(newObject, ...)
end

function module.giveFunctionality(object: Part, ...)
	local objectModule = script:FindFirstChild(object.Name)
	if objectModule and objectModule:IsA("ModuleScript") then
		local objectTable = require(objectModule).new(object, ...)
		linkedData.Set(object, "ObjectClass", objectTable)
	end

	return setmetatable({Instance = object, Fizzled = false, OnFizzle = Event.new()}, module)
end

function module:Fizzle()
	self.Fizzled = true
	local object = self.Instance

    task.spawn(function()
		if linkedData.Get(object) then
			if linkedData.Get(object, "ObjectClass") and linkedData.Get(object, "ObjectClass").Cleanup then
				linkedData.Get(object, "ObjectClass"):Cleanup()
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
	local object = self.Instance
    object.Anchored = true
	object.CanCollide = false
	shared.PlayerState.HoldingObject = object
end

function module.Drop()
    if shared.PlayerState.HoldingObject then
		shared.PlayerState.HoldingObject.Anchored = false
		shared.PlayerState.HoldingObject.CanCollide = true
		shared.PlayerState.HoldingObject.AssemblyLinearVelocity = Vector3.zero
		shared.PlayerState.HoldingObject.AssemblyAngularVelocity = Vector3.zero
		shared.PlayerState.HoldingObject = nil
	else
		warn("tried to drop object with no object beind held")
	end
end

return module