local InstanceUtils = require(script.Parent.InstanceUtils)

local module = {}

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
	end},

	NonStatic = {getFdiTable = function()
		return {workspace.Map.Elements, workspace.Map.Objects, workspace.Axis, workspace.Kilometers}
	end}
}

local function theRestOfTheParamsStuff(params, fdiPreset)
	local fdi, exclude = fdiPreset.getFdiTable()
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

return module
