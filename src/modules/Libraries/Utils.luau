local Utils = {}

-- INSTANCE UTILS

function Utils.getInstancesWithProperty(haystack: {Instance}, instanceType: string, property: string, desiredPropertyValue: any)
	local instances = {}
	for _, part in pairs(haystack) do
		if part:IsA(instanceType) and part[property] == desiredPropertyValue then
			table.insert(instances, part)
		end
	end
	return instances
end

function Utils.getInstancesWithAttribute(haystack: {Instance}, attribute: string, desiredAttributeValue: any)
	local instances = {}
	for _, part in pairs(haystack) do
		if part:GetAttribute(attribute) == desiredAttributeValue then
			table.insert(instances, part)
		end
	end
	return instances
end

function Utils.getClosestPart(target: BasePart, haystack: {BasePart})
	local closest = haystack[1]
	for _, part in pairs(haystack) do
		if (part.Position - target.Position).Magnitude < (closest.Position - target.Position).Magnitude then
			closest = part
		end
	end
	return closest
end

function Utils.getInstancesOfType(haystack: {Instance}, desiredType: string)
	local list = {}
	for _, v in pairs(haystack) do
		if v:IsA(desiredType) then
			table.insert(list, v)
		end
	end
	return list
end

function Utils.getChildProperties(parentInstance: Instance, propertyName: string): {string}
	local returnVal = {}
	for _, child in parentInstance:GetChildren() do
		table.insert(returnVal, child[propertyName])
	end
	return returnVal
end



-- VECTOR UTILS

function Utils.Unit(vec: Vector3)
	return vec.Magnitude == 0 and Vector3.zero or vec.Unit
end

function Utils.projectOnPlane(vec: Vector3, planeNormal: Vector3)
	return vec - (vec:Dot(planeNormal) / planeNormal:Dot(planeNormal)) * planeNormal
end

function Utils.roundVector(vec: Vector3)
	return Vector3.new(
		math.round(vec.X),
		math.round(vec.Y),
		math.round(vec.Z)
	)
end

function Utils.average(vec: Vector3)
	return (vec.X + vec.Y + vec.Z) / 3
end

function Utils.projectThroughPortal(pos: Vector3, entryCFrame: CFrame, exitCFrame: CFrame): Vector3
	local offset = entryCFrame:PointToObjectSpace(pos)
	local projected = exitCFrame:PointToWorldSpace(Vector3.new(-offset.X, offset.Y, -offset.Z))
	return projected
end

function Utils.projectRotationThroughPortal(rotation: CFrame, entryCFrame: CFrame, exitCFrame: CFrame): CFrame
	local rotOnly = CFrame.fromMatrix(Vector3.zero, rotation.RightVector, rotation.UpVector)
	local localRot = entryCFrame:ToObjectSpace(rotOnly)
	local flipped = CFrame.Angles(0, math.pi, 0) * localRot
	local projected = exitCFrame:ToWorldSpace(flipped)
	return projected
end


function Utils.deg(vec: Vector3 | Vector2)
	if typeof(vec) == "Vector3" then
		return Vector3.new(math.deg(vec.X), math.deg(vec.Y), math.deg(vec.Z))
	else
		return Vector2.new(math.deg(vec.X), math.deg(vec.Y))
	end
end

function Utils.rad(vec: Vector3 | Vector2)
	if typeof(vec) == "Vector3" then
		return Vector3.new(math.rad(vec.X), math.rad(vec.Y), math.rad(vec.Z))
	else
		return Vector2.new(math.rad(vec.X), math.rad(vec.Y))
	end
end

function Utils.rotationToVector(rotation: Vector3)
	return Vector3.new(math.sin(math.rad(rotation.Y))*math.cos(math.rad(rotation.X)), math.sin(math.rad(rotation.X)), math.cos(math.rad(rotation.Y))*math.cos(math.rad(rotation.X)))
end

function Utils.vectorToRotation(vec: Vector3, returnAsVector: boolean)
	local r = CFrame.lookAt(Vector3.zero, vec)
	if returnAsVector then
		return Utils.deg(Vector3.new(r:ToOrientation()))
	else
		return r
	end
end

function Utils.rotateVector(vec: Vector3, rotation: Vector3 | CFrame)
	local rotationCFrame
	if typeof(rotation) == "Vector3" then
		rotationCFrame = CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))
	elseif typeof(rotation) == "CFrame" then
		rotationCFrame = rotation
	end
	
	local rotatedVector = rotationCFrame:VectorToWorldSpace(vec)
	return rotatedVector
end

function Utils.mirrorVector(vec: Vector3, normal: Vector3)
	local dotProduct = vec:Dot(normal)
	local reflection = vec - 2 * dotProduct * normal

	return reflection
end



-- TABLE UTILS

function Utils.merge(...: {any})
	local newTable = {}
	for _, t in {...} do
		for _, v in t do
			table.insert(newTable, v)
		end
	end
	return newTable
end

return Utils