local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local MainConfig = require(ReplicatedStorage.Configs.MainConfig)
local Utils = require(ReplicatedStorage.Modules.Utils)
local World = require(ReplicatedStorage.Modules.World)
local Axis = require(ReplicatedStorage.Services.Axis)

local PortalService

local PortalPlacement = {}

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()

local portalGunOffset

local canShootAxis = true

function PortalPlacement.Init(portalService)
    PortalService = portalService
    portalGunOffset = script.Parent.PortalGunOffset
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
			portal:PivotTo(CFrame.new(pos) * CFrame.fromEulerAnglesYXZ(math.pi*0.5*normal.Y,math.rad(rootPart.Orientation.Y),math.pi))
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
            if part:HasTag("PortalBumper") then
                partInPortalBumper = true
                break
            end
        end

        if #partsInPart > 0 and not partInPortalBumper then
			if MainConfig.portalPlacementDebug then
				hitbox.Color = Color3.new(0,1,0)
			end
            table.insert(positions, hitbox.Position)
        else
			if MainConfig.portalPlacementDebug then
				hitbox.Color = Color3.new(1,0,0)
			end
            allSuccess = false
        end
    end

    return allSuccess, #positions == 0, Utils.Unit(Utils.AverageVectors(positions) - portalCollisionDetector.WorldPivot.Position) * 0.5
end

local function portalBump(portal, onPart: Part, pos: Vector3 | CFrame, normal)
    local targetPos = typeof(pos) == "Vector3" and CFrame.new(pos, pos + normal) or pos

    local portalCollisionDetector = ReplicatedStorage.Assets.PortalCollisionDetector:Clone()
	if MainConfig.portalPlacementDebug then
		for _, v in portalCollisionDetector:GetChildren() do
			v.Transparency = 0.5
		end
	end
    portalCollisionDetector.Parent = workspace
    portalCollisionDetector:PivotTo(targetPos)
    
    -- PARAMS
	-- get all the joined parts
	local joinedParts = {onPart}
	for _, joinedPart in onPart:GetChildren() do
		if not joinedPart:IsA("ObjectValue") then continue end
		if joinedPart.Name ~= "JoinedPart" then continue end
		if not joinedPart.Value then continue end
		if not joinedPart.Value:IsA("BasePart") then continue end
		table.insert(joinedParts, joinedPart.Value)
	end
	-- get the portal bumpers
	local bumpers = {}
	for _, part in joinedParts do
		for _, bumper in part:GetChildren() do
			if not bumper:IsA("ObjectValue") then continue end
			if bumper.Name ~= "PortalBumper" then continue end
			if not bumper.Value then continue end
			if not bumper.Value:IsA("BasePart") then continue end
			table.insert(bumpers, bumper.Value)
		end
	end
	-- the actual params
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
	params:AddToFilter(joinedParts)
	params:AddToFilter(bumpers)
	params:AddToFilter(workspace:QueryDescendants(".UniversalPortalBumper"))
	if portal.Name == "BluePortal" then
		params:AddToFilter(workspace.RedPortal.PortalBumper)
	else
		params:AddToFilter(workspace.BluePortal.PortalBumper)
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
        if steps > MainConfig.PortalBumpMaxSteps or allFail or addLocation.Magnitude == 0 then
            portalCollisionDetector:Destroy()
            return false, targetPos.Position
        end

		if MainConfig.portalPlacementDebug then
			task.wait(0.2)
		end

        portalCollisionDetector:PivotTo(portalCollisionDetector.WorldPivot + addLocation)
    end
end


-- PORTAL PLACEMENT

local function firePortal(portal, redPortal: boolean)
	local tween = TweenService:Create(portalGunOffset, TweenInfo.new(MainConfig.PortalgunSpinTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Value = portalGunOffset.Value * CFrame.Angles(0, 0, redPortal and -MainConfig.PortalgunSpinAmount or MainConfig.PortalgunSpinAmount)})
	tween:Play()
	
	local raycast = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, World.raycastParams(World.ParamPreset.PortalCollision))
	if raycast then
		if PortalService.CanPlacePortalOnPart(raycast.Instance) then
			local pos = raycast.Position
			local look = raycast.Normal
			local success, newLocation
			if look == Vector3.new(0,1,0) or look == Vector3.new(0,-1,0) then
				local cf = CFrame.new(pos) * CFrame.fromEulerAnglesYXZ(math.pi*0.5*look.Y,math.rad(rootPart.Orientation.Y),math.pi)
				success, newLocation = portalBump(portal, raycast.Instance, cf)
			else
				success, newLocation = portalBump(portal, raycast.Instance, pos, look)
			end
            
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