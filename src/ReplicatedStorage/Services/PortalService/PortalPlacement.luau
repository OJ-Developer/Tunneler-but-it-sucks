local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Utils = require(ReplicatedStorage.Modules.Utils)
local World = require(ReplicatedStorage.Modules.World)
local Axis = require(ReplicatedStorage.Services.Axis)

local PortalService

local PortalPlacement = {}

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()

local GUN_SPIN_AMOUNT = math.rad(120)
local GUN_SPIN_TIME = 0.3

local portalGunOffset

local canShootAxis = true

function PortalPlacement.Init(portalService)
    PortalService = portalService
    portalGunOffset = script.Parent.PortalGunOffset
end

function PortalPlacement.CanPlacePortalOnPart(part: Part)
    return shared.PlayerState.GunIgnoreMaterials or part:GetAttribute("CanHavePortals") and not shared.PlayerState.HoldingObject
end

local function getPartsPortalIsOn(portal)
	return workspace:GetPartsInPart(portal.BehindPortalHitbox, World.overlapParams(World.ParamPreset.Building))
end

local function collisionGroupStuff(portal: Model, partsPortalIsOn: {Part}, prevPartsPortalIsOn: {Part}, portalColour: string)
	for _, part: Part in pairs(Utils.merge(partsPortalIsOn, prevPartsPortalIsOn)) do
		part:SetAttribute(`Behind{portalColour}Portal`, table.find(partsPortalIsOn, part) ~= nil)
		
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

function PortalPlacement.PlacePortal(portal, redPortal: boolean, onPart: Part?, placedByPortalPlacer: boolean, pos: Vector3 | CFrame, normal)
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
	
	PortalService.PortalPlaced:Fire(redPortal and 2 or 1)

	local partsPortalIsOn = getPartsPortalIsOn(portal)
	collisionGroupStuff(portal, partsPortalIsOn, prevPartsPortalIsOn, redPortal and "Red" or "Blue")
end


-- PORTAL BUMPING

local function portalBumpStep(portalCollisionDetector: Model, params: OverlapParams)
    local positions = {}
    local allSuccess = true
    for _, hitbox in portalCollisionDetector:GetChildren() do
        local partsInPart = workspace:GetPartsInPart(hitbox, params)

        local partInPortalBumper = false
        for _, part in partsInPart do
            print(part:HasTag("PortalBumper"))
            if part:HasTag("PortalBumper") then
                partInPortalBumper = true
                break
            end
        end

        if #partsInPart > 0 and not partInPortalBumper then
            table.insert(positions, hitbox.Position)
        else
            allSuccess = false
        end
    end

    return allSuccess, #positions == 0, Utils.Unit(Utils.AverageVectors(positions) - portalCollisionDetector.WorldPivot.Position) * 0.5
end

local MAX_STEPS = 10

local function portalBump(onPart: Part, pos: Vector3 | CFrame, normal)
    local targetPos = typeof(pos) == "Vector3" and CFrame.new(pos, pos + normal) or pos

    local portalCollisionDetector = ReplicatedStorage.Assets.PortalCollisionDetector:Clone()
    for _, v in portalCollisionDetector:GetChildren() do
        v.BrickColor = BrickColor.new("Really red")
        v.Transparency = 0.5
    end
    portalCollisionDetector.Parent = workspace
    portalCollisionDetector:PivotTo(targetPos)
    
    -- setup params
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = {onPart, Utils.GetTaggedDescendants("PortalBumper", workspace.Map)}
    print(Utils.GetTaggedDescendants("PortalBumper", workspace))
    for _, child in onPart:GetChildren() do
        if child:IsA("ObjectValue") and child.Name == "LinkedPart" and child.Value and child.Value:IsA("BasePart") then
            params:AddToFilter(child.Value)
        end
    end

    -- the thing
    local steps = 0
    while true do
        steps += 1

        local allSuccess, allFail, addLocation = portalBumpStep(portalCollisionDetector, params)

        if allSuccess then
            local p = portalCollisionDetector.WorldPivot.Position
            portalCollisionDetector:Destroy()
            return true, p
        end
        if steps > MAX_STEPS or allFail or addLocation.Magnitude == 0 then
            portalCollisionDetector:Destroy()
            return false, targetPos.Position
        end

        portalCollisionDetector:PivotTo(portalCollisionDetector.WorldPivot + addLocation)
    end
end

local function firePortal(portal, redPortal: boolean)
	local tween = TweenService:Create(portalGunOffset, TweenInfo.new(GUN_SPIN_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Value = portalGunOffset.Value * CFrame.Angles(0, 0, redPortal and -GUN_SPIN_AMOUNT or GUN_SPIN_AMOUNT)})
	tween:Play()
	
	local raycast = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, World.raycastParams(World.ParamPreset.PortalCollision))
	if raycast then
		if PortalService.CanPlacePortalOnPart(raycast.Instance) then

            local success, newLocation = portalBump(raycast.Instance, raycast.Position, raycast.Normal)
            
            if success then
                PortalService.PlacePortal(portal, redPortal, raycast.Instance, false, newLocation, raycast.Normal)
            end
		elseif raycast.Instance == workspace.Axis and canShootAxis then
			Axis.scare()
			canShootAxis = false
			task.spawn(function()
				task.wait(60)
				canShootAxis = true
			end)
		end
	end
end


-- INPUTS

ReplicatedStorage.Inputs.FireBlue.Pressed:Connect(function()
	if shared.PlayerState.HasGun then	
		firePortal(workspace.BluePortal, false)
	end
end)

ReplicatedStorage.Inputs.FireRed.Pressed:Connect(function()
	if shared.PlayerState.HasGun and shared.PlayerState.GunUpgraded then
		firePortal(workspace.RedPortal, true)
	end
end)

return PortalPlacement