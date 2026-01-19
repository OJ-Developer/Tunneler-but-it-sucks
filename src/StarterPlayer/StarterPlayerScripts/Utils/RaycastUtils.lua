local module = {}

local rs = game:GetService("ReplicatedStorage")

local playerScripts = game.Players.LocalPlayer.PlayerScripts
local instanceUtils = require(playerScripts.Utils.InstanceUtils)
local tableUtils = require(playerScripts.Utils.TableUtils)
local vectorUtils = require(playerScripts.Utils.VectorUtils)

local bluePortal = workspace:WaitForChild("BluePortal")
local redPortal = workspace:WaitForChild("RedPortal")

function module.getMapCollideableParts()
	return instanceUtils.getInstancesWithProperty(workspace.Map:GetDescendants(), "BasePart", "CanCollide", true)
end

function module.getPortalableParts()
	return instanceUtils.getInstancesWithAttribute(workspace.Map.Building:GetDescendants(), "CanHavePortals", true)
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

local function theRestOfTheParamsStuff(params: RaycastParams | OverlapParams, fdiType: string)
	params.FilterType = Enum.RaycastFilterType.Include
	if fdiType == "collideable" then
		params.FilterDescendantsInstances = module.getMapCollideableParts()
	elseif fdiType == "interactable" then
		params.FilterDescendantsInstances = {workspace.Map.Objects, workspace.Map.Elements}
	elseif fdiType == "player" then
		params.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
	elseif fdiType == "buttonActivators" then
		params.FilterDescendantsInstances = {instanceUtils.getInstancesWithProperty(workspace.Map.Objects:GetChildren(), "BasePart", "Name", "Cube"), game.Players.LocalPlayer.Character}
	elseif fdiType == "objects" then
		params.FilterDescendantsInstances = {workspace.Map.Objects}
	elseif fdiType == "canHavePortals" then
		params.FilterDescendantsInstances = module.getPortalableParts()
	elseif fdiType == "portalCollision" then
		params.FilterDescendantsInstances = module.getPortalRaycastExcludeParts()
		params.FilterType = Enum.RaycastFilterType.Exclude
	elseif fdiType == "map" then
		params.FilterDescendantsInstances = {workspace.Map.Building}
	end
end

function module.raycastParams(fdiType: string)
	local params = RaycastParams.new()
	theRestOfTheParamsStuff(params, fdiType)
	return params
end

function module.overlapParams(fdiType: string)
	local params = OverlapParams.new()
	theRestOfTheParamsStuff(params, fdiType)
	return params
end

function module.raycastThroughPortalLegacy(origin: Vector3, direction: Vector3, raycastParams: RaycastParams)
	raycastParams.FilterDescendantsInstances = {raycastParams.FilterDescendantsInstances, bluePortal.Portal, redPortal.Portal}

	local raycast = workspace:Raycast(origin, direction, raycastParams)
	if raycast then
		if (raycast.Instance ~= bluePortal.Portal and raycast.Instance ~= redPortal.Portal) or 
			(bluePortal.OnPart.Value == nil or redPortal.OnPart.Value == nil) 
		then return raycast.Position end

		local entryPortal: Part = raycast.Instance
		local exitPortal: Part = (entryPortal == bluePortal.Portal) and redPortal.Portal or bluePortal.Portal
		
		return vectorUtils.projectThroughPortal(direction + origin, entryPortal.CFrame, exitPortal.CFrame)
		
		--[[local offset = entryPortal.CFrame:PointToObjectSpace(origin + direction)
		return exitPortal.CFrame:PointToWorldSpace(Vector3.new(-offset.X, offset.Y, -offset.Z))]]
	end
	return origin + direction
end

local maxBounce = 5

function module.raycastThroughPortal(origin: Vector3, direction: Vector3, raycastParams: RaycastParams, depth: number | nil)
	raycastParams.FilterDescendantsInstances = {raycastParams.FilterDescendantsInstances, bluePortal.Portal, redPortal.Portal}
		
	local raycast = workspace:Raycast(origin, direction, raycastParams)
	if raycast then
		if 
			(raycast.Instance ~= bluePortal.Portal and raycast.Instance ~= redPortal.Portal) or 
			(bluePortal.OnPart.Value == nil or redPortal.OnPart.Value == nil) 
		then return true, {Position = raycast.Position, Instance = raycast.Instance, Distance = raycast.Distance, Normal = raycast.Normal} end
		
		local entryPortal = raycast.Instance
		local exitPortal = (entryPortal == bluePortal.Portal) and redPortal.Portal or bluePortal.Portal
		
		local projectedTarget = vectorUtils.projectThroughPortal(origin+direction, entryPortal.CFrame, exitPortal.CFrame, true)
		
		if depth and depth >= maxBounce then
			return true, {Position = projectedTarget, Instance = raycast.Instance, Distance = raycast.Distance, Normal = raycast.Normal}
		end
		
		local projectedOrigin = vectorUtils.projectThroughPortal(raycast.Position, entryPortal.CFrame, exitPortal.CFrame, true)
		local difference = projectedTarget - projectedOrigin
		
		return module.raycastThroughPortal(projectedOrigin, difference, raycastParams, depth and depth+1 or 2)
	end
	return false, {Position = origin + direction}
end

return module
