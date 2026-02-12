local Players = game:GetService("Players")

local Utils = require(script.Parent.Utils)

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

local module = {}

function module.getMapCollideableParts()
	return Utils.getInstancesWithProperty(workspace.Map:GetDescendants(), "BasePart", "CanCollide", true)
end

function module.getPortalableParts()
	return Utils.getInstancesWithAttribute(workspace.Map.Building:GetDescendants(), "CanHavePortals", true)
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

module.ParamPreset = {
	Collideable = {
		RespectCanCollide = true
	},

	Interactable = {
		FilterDescendantsInstances = function()
			return {workspace.Map.Objects, workspace.Map.Elements}
		end,
		FilterType = Enum.RaycastFilterType.Include
	},

	Player = {
		FilterDescendantsInstances = function()
			return {char}
		end,
		FilterType = Enum.RaycastFilterType.Include
	},

	FloorButtonActivators = {
		FilterDescendantsInstances = function()
			return {Utils.getInstancesWithProperty(workspace.Map.Objects:GetChildren(), "BasePart", "Name", "Cube"), game.Players.LocalPlayer.Character}
		end,
		FilterType = Enum.RaycastFilterType.Include
	},

	Objects = {
		FilterDescendantsInstances = function()
			return {workspace.Map.Objects}
		end,
		FilterType = Enum.RaycastFilterType.Include
	},

	CanHavePortals = {
		FilterDescendantsInstances = module.getPortalableParts,
		FilterType = Enum.RaycastFilterType.Include
	},

	PortalCollision = {
		FilterDescendantsInstances = function()
			return module.getPortalRaycastExcludeParts()
		end,
		FilterType = Enum.RaycastFilterType.Exclude
	},

	Building = {
		FilterDescendantsInstances = function()
			return {workspace.Map.Building}
		end,
		FilterType = Enum.RaycastFilterType.Include
	},

	NonStatic = {
		FilterDescendantsInstances = function()
			return {workspace.Map.Elements, workspace.Map.Objects, workspace.Axis, workspace.Kilometers}
		end,
		FilterType = Enum.RaycastFilterType.Include
	},

	ObjectCollideable = {
		RespectCanCollide = true,
		FilterDescendantsInstances = function()
			return {workspace.Map.Objects, char}
		end,
		FilterType = Enum.RaycastFilterType.Exclude
	}
}

local function theRestOfTheParamsStuff(params, paramData)
	local fdiFunc = paramData.FilterDescendantsInstances
	local fdi = {}
	if fdiFunc then
		fdi = fdiFunc()
	end
	params.FilterDescendantsInstances = fdi
	for name, value in paramData do
		if name == "FilterDescendantsInstances" then continue end
		params[name] = value
	end
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
