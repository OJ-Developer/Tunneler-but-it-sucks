local module = {}
module.__index = module

local rs = game:GetService("ReplicatedStorage")
local objects = rs:WaitForChild("Objects")

local linkedData = require(script.Parent.Parent.Services.LinkedData)

local holdingObject = game.Players.LocalPlayer.PlayerScripts.Interaction.HoldingObject

function module.giveFunctionality(object: Part, ...)
	local objectModule = script:FindFirstChild(object.Name)
	if objectModule and objectModule:IsA("ModuleScript") then
		local objectTable = require(objectModule).new(object, ...)
		linkedData.Set(object, "ObjectClass", objectTable)
	end

	return setmetatable({Instance = object, Fizzled = false}, module)
end

function module.new(objectName: string, cframe: CFrame, ...)
	local newObject = objects[objectName]:Clone()
	newObject.Parent = workspace.Map.Objects
	newObject.CFrame = cframe
	
	return module.giveFunctionality(newObject, ...)
end

function module.spawn(objectName: string, cframe: CFrame, ...)
	return module.new(objectName, cframe, ...).Instance
end

function module.fizzle(object: Part)
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

function module:Fizzle()
	local object = self.Instance
	self.Fizzled = true
	module.fizzle(self.Instance)
end

function module.pickup(object: Part)
	object.Anchored = true
	object.CanCollide = false
	holdingObject.Value = object
end

function module:Pickup()
	module.pickup(self.Instance)
end

function module.drop()
	if holdingObject.Value then
		holdingObject.Value.Anchored = false
		holdingObject.Value.CanCollide = true
		holdingObject.Value.AssemblyLinearVelocity = Vector3.zero
		holdingObject.Value.AssemblyAngularVelocity = Vector3.zero
		holdingObject.Value = nil
	else
		warn("tried to drop object with no object beind held")
	end
end

function module:Drop()
	module.drop()
end

return module
