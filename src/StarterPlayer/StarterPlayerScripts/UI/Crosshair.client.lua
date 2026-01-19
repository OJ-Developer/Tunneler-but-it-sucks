local rs = game:GetService("ReplicatedStorage")

local events = rs.Events
events.GameLoaded.Event:Wait()
local levelLoadedEvent = events.Levels.LevelLoaded
local enableCrosshairEvent = events.UI.EnableCrosshair
local disableCrosshairEvent = events.UI.DisableCrosshair

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local hasGun = player.PlayerScripts.Portal.HasGun
local gunUpgraded = player.PlayerScripts.Portal.GunUpgraded

local playerScripts = player.PlayerScripts
local raycastUtils = require(script.Parent.Parent.Utils.RaycastUtils) 

local holdingObject = playerScripts.Interaction.HoldingObject
local maxGrabDist = playerScripts.Interaction.Configuration.MaxGrabDist

local crosshair = player.PlayerGui.Crosshair
local left = crosshair.Left
local right = crosshair.Right
local dot = crosshair.Dot

local function updateCrosshairVisibility(visible)
	left.Visible = visible
	right.Visible = visible
	dot.Visible = visible
end
enableCrosshairEvent.Event:Connect(function()
	updateCrosshairVisibility(true)
end)
disableCrosshairEvent.Event:Connect(function()
	updateCrosshairVisibility(false)
end)
holdingObject.Changed:Connect(function(val)
	if val then
		updateCrosshairVisibility(false)
	else
		updateCrosshairVisibility(true)
	end
end)

while task.wait() do
	if hasGun.Value then
		
		local objectRaycast = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * maxGrabDist.Value, raycastUtils.raycastParams("interactable"))
		if objectRaycast then
			if (objectRaycast.Instance.Parent == workspace.Map.Objects) or (objectRaycast.Instance.Parent.Parent == workspace.Map.Elements and objectRaycast.Instance.Parent.Name == "StandingButton" and objectRaycast.Instance.Name == "Button") then
				left.ImageColor3 = Color3.new(1, 1, 0)
				right.ImageColor3 = Color3.new(1, 1, 0)
				left.ImageTransparency = 0
				right.ImageTransparency = 0
				continue
			end
		end
		
		left.ImageColor3 = Color3.new(0, 0, 1)
		right.ImageColor3 = gunUpgraded.Value and Color3.new(1, 0.5, 0) or Color3.new(0, 0, 1)
		
		local raycast = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, raycastUtils.raycastParams("portalCollision"))
		if raycast then
			if raycast.Instance:IsA("BasePart") then
				if raycast.Instance:GetAttribute("CanHavePortals") then
					left.ImageTransparency = 0
					right.ImageTransparency = 0
				else
					left.ImageTransparency = 1
					right.ImageTransparency = 1
				end
			end
		else
			left.ImageTransparency = 1
			right.ImageTransparency = 1
		end
	else
		left.ImageTransparency = 1
		right.ImageTransparency = 1
	end
end