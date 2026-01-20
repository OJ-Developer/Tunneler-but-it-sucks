local InstanceUtils = require(script.Parent.InstanceUtils)
local VectorUtils = require(script.Parent.VectorUtils)


local module = {}

local bluePortal = workspace:WaitForChild("BluePortal")
local redPortal = workspace:WaitForChild("RedPortal")

function module.getMapCollideableParts()
	return InstanceUtils.getInstancesWithProperty(workspace.Map:GetDescendants(), "BasePart", "CanCollide", true)
end

function module.getPortalableParts()
	return InstanceUtils.getInstancesWithAttribute(workspace.Map.Building:GetDescendants(), "CanHavePortals", true)
end

function module.getPortalRaycastExcludeParts()
	local exclude = {workspace.BluePortal, workspace.RedPortal, workspace[game.Players.LocalPlayer.Name], workspace.Map.Objects}
	for _, part in pairs(workspace:GetDescendants()) do
		if (part:IsA("BasePart") and (part:HasTag("hitboxVisibility") or part.Name == "MeshFence")) or (part.Name == "Fizzler" and not part.Enabled.Value) then
			table.insert(exclude, part)
		end
	end
	
	return exclude
end

module.FdiPresets = {
	Collideable = {getFdiTable = module.getMapCollideableParts},

	Interactable = {getFdiTable = function()
		return {workspace.Map.Objects, workspace.Map.Elements}
	end},

	Player = {getFdiTable = function()
		return {workspace.Map.Objects, workspace.Map.Elements}
	end},

	FloorButtonActivators = {getFdiTable = function()
		return {InstanceUtils.getInstancesWithProperty(workspace.Map.Objects:GetChildren(), "BasePart", "Name", "Cube"), game.Players.LocalPlayer.Character}
	end},

	Objects = {getFdiTable = function()
		return {workspace.Map.Objects}
	end},

	CanHavePortals = {getFdiTable = module.getPortalableParts},

	PortalCollision = {getFdiTable = function()
		return module.getPortalRaycastExcludeParts(), true
	end},

	Building = {getFdiTable = function()
		return {workspace.Map.Building}
	end}
}

local function theRestOfTheParamsStuff(params, fdiPreset)
	local fdi, exclude = fdiPreset.getFdiTables()
	if exclude then
		params.FilterType = Enum.RaycastFilterType.Exclude
	else
		params.FilterType = Enum.RaycastFilterType.Include
	end
	params.FilterDescendantsInstances = fdi
end

function module.raycastParams(fdiPreset)
	local params = RaycastParams.new()
	theRestOfTheParamsStuff(params, fdiPreset)
	return params
end

function module.overlapParams(fdiPreset)
	local params = OverlapParams.new()
	theRestOfTheParamsStuff(params, fdiPreset)
	return params
end

function module.raycastThroughPortalLegacy(origin: Vector3, direction: Vector3, raycastParams: RaycastParams)
	raycastParams.FilterDescendantsInstances = {unpack(raycastParams.FilterDescendantsInstances), bluePortal.Portal, redPortal.Portal}

	local raycast = workspace:Raycast(origin, direction, raycastParams)
	if raycast then
		if (raycast.Instance ~= bluePortal.Portal and raycast.Instance ~= redPortal.Portal) or 
			(bluePortal.OnPart.Value == nil or redPortal.OnPart.Value == nil) 
		then return raycast.Position end

		local entryPortal: Part = raycast.Instance
		local exitPortal: Part = (entryPortal == bluePortal.Portal) and redPortal.Portal or bluePortal.Portal
		
		return VectorUtils.projectThroughPortal(direction + origin, entryPortal.CFrame, exitPortal.CFrame)
		
		--[[local offset = entryPortal.CFrame:PointToObjectSpace(origin + direction)
		return exitPortal.CFrame:PointToWorldSpace(Vector3.new(-offset.X, offset.Y, -offset.Z))]]
	end
	return origin + direction
end

local maxBounce = 5

function module.raycastThroughPortal(origin: Vector3, direction: Vector3, raycastParams: RaycastParams, depth: number?)
	raycastParams.FilterDescendantsInstances = {unpack(raycastParams.FilterDescendantsInstances), bluePortal.Portal, redPortal.Portal}
		
	local raycast = workspace:Raycast(origin, direction, raycastParams)
	if raycast then
		if (raycast.Instance ~= bluePortal.Portal and raycast.Instance ~= redPortal.Portal) or 
			(bluePortal.OnPart.Value == nil or redPortal.OnPart.Value == nil) 
		then return true, {Position = raycast.Position, Instance = raycast.Instance, Distance = raycast.Distance, Normal = raycast.Normal} end
		
		local entryPortal = raycast.Instance
		local exitPortal = (entryPortal == bluePortal.Portal) and redPortal.Portal or bluePortal.Portal
		
		local projectedTarget = VectorUtils.projectThroughPortal(origin+direction, entryPortal.CFrame, exitPortal.CFrame)
		
		if depth and depth >= maxBounce then
			return true, {Position = projectedTarget, Instance = raycast.Instance, Distance = raycast.Distance, Normal = raycast.Normal}
		end
		
		local projectedOrigin = VectorUtils.projectThroughPortal(raycast.Position, entryPortal.CFrame, exitPortal.CFrame)
		local difference = projectedTarget - projectedOrigin
		
		return module.raycastThroughPortal(projectedOrigin, difference, raycastParams, depth and depth+1 or 2)
	end
	return false, {Position = origin + direction}
end

return module
