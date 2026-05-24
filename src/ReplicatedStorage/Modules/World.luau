local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LinkedData = require(ReplicatedStorage.Services.LinkedData)

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

local module = {}

function module.getMapCollideableParts()
	return workspace.Map:QueryDescendants("[CanCollide = true]")
end

function module.getPortalableParts()
	return workspace.Map.Building:QueryDescendants("[$CanHavePortals = true]")
end

function module.getPortalRaycastExcludeParts()
	local exclude = {workspace.BluePortal, workspace.RedPortal, workspace[game.Players.LocalPlayer.Name], workspace.Map.Objects}
	for _, part in pairs(workspace:GetDescendants()) do
		if (part:IsA("BasePart") and (part:HasTag("hitboxVisibility") or part.Name == "MeshFence")) or (part:GetAttribute("ElementType") == "Fizzler" and not LinkedData.Get(part, "ElementClass").Enabled) then
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
			return {workspace.Map.Objects:QueryDescendants(">BasePart#Cube"), game.Players.LocalPlayer.Character}
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
	},

	Portals = {
		FilterDescendantsInstances = function()
			return {workspace.BluePortal.PortalSurface, workspace.RedPortal.PortalSurface}
		end,
		FilterType = Enum.RaycastFilterType.Include
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
