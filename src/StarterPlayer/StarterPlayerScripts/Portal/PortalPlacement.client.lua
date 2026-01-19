local tweenService = game:GetService("TweenService")
local rs = game:GetService("ReplicatedStorage")

local events = rs.Events
local levelLoadedEvent = events.Levels.LevelLoaded
local portalPlacedEvent = events.Portal.PortalPlaced
local placePortalEvent = events.Portal.PlacePortal

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local char = player.Character or player.CharacterAdded:Wait()
local rootPart: Part = char:WaitForChild("HumanoidRootPart")

local playerScripts = player.PlayerScripts
local raycastUtils = require(playerScripts.Utils.RaycastUtils)
local tableUtils = require(playerScripts.Utils.TableUtils)
local axis = require(script.Parent.Parent.Services.Axis)

local gunSpinAmount = math.rad(120)
local gunSpinTime = 0.3

local hasGun = script.Parent.HasGun
local gunUpgraded = script.Parent.GunUpgraded

local holdingObject = script.Parent.Parent.Interaction.HoldingObject

local offset = script.Parent.ViewModel.Offset

local canShootAxis = true

local function getPartsPortalIsOn(portal: Model)
	return workspace:GetPartsInPart(portal.BehindPortalHitbox, raycastUtils.overlapParams("map"))
end

local function collisionGroupStuff(portal: Model, partsPortalIsOn: {Part}, prevPartsPortalIsOn: {Part}, portalColour: string)
	for _, part: Part in pairs(tableUtils.merge(partsPortalIsOn, prevPartsPortalIsOn)) do
		part:SetAttribute(`Behind{portalColour}Portal`, tableUtils.contains(partsPortalIsOn, part))
		
		local behindBluePortal = part:GetAttribute("BehindBluePortal")
		local behindRedPortal = part:GetAttribute("BehindRedPortal")
		
		local collisionGroup = "Default"
		
		if behindBluePortal and not behindRedPortal then
			collisionGroup = "BehindBluePortal"
		elseif (not behindBluePortal) and behindRedPortal then
			collisionGroup = "BehindRedPortal"
		elseif behindBluePortal and behindRedPortal then
			collisionGroup = "BehindBothPortals"
		end
		
		part.CollisionGroup = collisionGroup
	end
	
	return partsPortalIsOn
end

local function placePortal(portal: Model, redPortal: boolean, onPart: Part, placedByPortalPlacer: boolean, pos: Vector3 | CFrame, normal: Vector3?)
	portal.OnPart.Value = onPart
	portal.Fizzleable.Value = not placedByPortalPlacer
	
	if (not workspace.BluePortal.OnPart.Value) or (not workspace.RedPortal.OnPart.Value) then
		for _, part in char:GetChildren() do
			if part:IsA("BasePart") then
				part.CollisionGroup = "Default"
			end
		end
	end
	
	local prevPartsPortalIsOn = getPartsPortalIsOn(portal)

	if typeof(pos) == "Vector3" then
		portal:PivotTo(CFrame.new(pos, pos + normal))
		if normal == Vector3.new(0,1,0) or normal == Vector3.new(0,-1,0) then
			portal:PivotTo(CFrame.new(portal.PrimaryPart.Position) * CFrame.fromEulerAnglesYXZ(math.pi*0.5*normal.Y,math.rad(rootPart.Orientation.Y),math.pi))
		end
	else
		portal:PivotTo(pos)
	end
	
	portalPlacedEvent:Fire(redPortal and 2 or 1)

	local partsPortalIsOn = getPartsPortalIsOn(portal)
	collisionGroupStuff(portal, partsPortalIsOn, prevPartsPortalIsOn, redPortal and "Red" or "Blue")
end

local function firePortal(portal: Model, redPortal: boolean)
	local tween = tweenService:Create(offset, TweenInfo.new(gunSpinTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Value = offset.Value * CFrame.Angles(0, 0, redPortal and -gunSpinAmount or gunSpinAmount)})
	tween:Play()
	
	local otherPortal: Model = redPortal and workspace.RedPortal or workspace.BluePortal
	
	local raycast = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, raycastUtils.raycastParams("portalCollision"))
	if raycast then
		if raycast.Instance:IsA("BasePart") and raycast.Instance:GetAttribute("CanHavePortals") and not holdingObject.Value then
			placePortal(portal, redPortal, raycast.Instance, false, raycast.Position, raycast.Normal)
		elseif raycast.Instance == workspace.Axis and canShootAxis then
			axis.scare()
			canShootAxis = false
			task.spawn(function()
				task.wait(60)
				canShootAxis = true
			end)
		end
	end
end

mouse.Button1Down:Connect(function()
	if hasGun.Value then	
		firePortal(workspace.BluePortal, false)
	end
end)

mouse.Button2Down:Connect(function()
	if hasGun.Value and gunUpgraded.Value then
		firePortal(workspace.RedPortal, true)
	end
end)

placePortalEvent.Event:Connect(placePortal)

levelLoadedEvent.Event:Connect(function()
	hasGun.Value = workspace.Map.LevelSettings.StartWithGun.Value
	gunUpgraded.Value = workspace.Map.LevelSettings.StartWithGunUpgraded.Value
	
	workspace.BluePortal:PivotTo(CFrame.new(0,-20,0))
	workspace.BluePortal.OnPart.Value = nil
	workspace.RedPortal:PivotTo(CFrame.new(0,-20,0))
	workspace.RedPortal.OnPart.Value = nil
end)