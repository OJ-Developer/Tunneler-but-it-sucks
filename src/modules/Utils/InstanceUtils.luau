local module = {}

function module.getInstancesWithProperty(haystack: {Instance}, instanceType: string, property: string, desiredPropertyValue: any)
	local instances = {}
	for _, part in pairs(haystack) do
		if part:IsA(instanceType) and part[property] == desiredPropertyValue then
			table.insert(instances, part)
		end
	end
	return instances
end

function module.getInstancesWithAttribute(haystack: {Instance}, attribute: string, desiredAttributeValue: any)
	local instances = {}
	for _, part in pairs(haystack) do
		if part:GetAttribute(attribute) == desiredAttributeValue then
			table.insert(instances, part)
		end
	end
	return instances
end

function module.getClosestPart(target: BasePart, haystack: {BasePart})
	local closest = haystack[1]
	for _, part in pairs(haystack) do
		if (part.Position - target.Position).Magnitude < (closest.Position - target.Position).Magnitude then
			closest = part
		end
	end
	return closest
end

function module.getInstancesOfType(haystack: {Instance}, desiredType: string)
	local list = {}
	for _, v in pairs(haystack) do
		if v:IsA(desiredType) then
			table.insert(list, v)
		end
	end
	return list
end

return module
