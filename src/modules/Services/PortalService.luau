local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Axis = require(script.Parent.Axis)
local Event = require(ReplicatedStorage.Modules.Classes.Event)
local CameraService = require(script.Parent.CameraService)
local LevelService = require(script.Parent.LevelService)
local InstanceUtils = require(ReplicatedStorage.Modules.Utils.InstanceUtils)
local RaycastUtils = require(ReplicatedStorage.Modules.Utils.RaycastUtils)
local TableUtils = require(ReplicatedStorage.Modules.Utils.TableUtils)
local VectorUtils = require(ReplicatedStorage.Modules.Utils.VectorUtils)

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")
local head = char:WaitForChild("Head")
local headHeight = head.Position.Y - rootPart.Position.Y
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()
local portalsUi = player.PlayerGui.Portals

local blueViewport = portalsUi.BluePortalView.Frame
local redViewport = portalsUi.RedPortalView.Frame
local blueViewportCamera: Camera
local redViewportCamera: Camera

local PortalService = {
    PortalPlaced = Event.new()
}

local portalGunOffset: CFrameValue

local bluePortal: Portal
local redPortal: Portal

local portalGun: MeshPart

export type Portal = Model & {
    Fizzleable: BoolValue,
    OnPart: ObjectValue,
    Hitbox: Model,
    VisibilityHitbox: UnionOperation,
    ViewportFrameMask: MeshPart,
    PortalBehingThing: MeshPart,
    BehindPortalHitbox: Part,
    Portal: Part,
    PortalZone: Part,

    PrimaryPart: Part
}

function PortalService.Init()
    bluePortal = ReplicatedStorage.Portals.BluePortal:Clone()
    bluePortal.Parent = workspace
    redPortal = ReplicatedStorage.Portals.RedPortal:Clone()
    redPortal.Parent = workspace

    portalGun = ReplicatedStorage.Other.PortalGun:Clone()
    portalGun.Parent = workspace

    portalGunOffset = Instance.new("CFrameValue", script)
    portalGunOffset.Value = CFrame.new(1.5, -1, -2)
    PortalService.PortalGunOffset = portalGunOffset

    shared.Settings.PortalRendering = true

    blueViewportCamera = Instance.new("Camera", portalsUi)
    redViewportCamera = Instance.new("Camera", portalsUi)
    
    blueViewport.CurrentCamera = redViewportCamera
    redViewport.CurrentCamera = blueViewportCamera
    
    blueViewport.Parent.Adornee = bluePortal.Portal
    redViewport.Parent.Adornee = redPortal.Portal

    local folder = Instance.new("Folder", blueViewport)
    folder.Name = "Static"
    folder = Instance.new("Folder", blueViewport)
    folder.Name = "NonStatic"
    folder = Instance.new("Folder", redViewport)
    folder.Name = "Static"
    folder = Instance.new("Folder", redViewport)
    folder.Name = "NonStatic"

    shared.PlayerState.GunChanged = Event.new()
end

function PortalService.Start()
    local inBluePortal = {}
    local inRedPortal = {}

    local objectsInBluePortal = {}
    local objectsInRedPortal = {}

    local prevInBluePortal = {}
    local prevInRedPortal = {}

    local playerInBluePortal = false
    local playerInRedPortal = false
    local playerInPortal = false
    local prevPlayerInPortal = false

    local playerVel
    local playerSpeed

    local function updateStats(playerVelocity: Vector3, dtime: number)
        --[[updateStatEvent:Fire("Fps", math.round(1/dtime))
        updateStatEvent:Fire("BluePortalZone", playerInBluePortal and "true" or "false")
        updateStatEvent:Fire("RedPortalZone", playerInRedPortal and "true" or "false")
        updateStatEvent:Fire("PlayerVelocity", tostring(VectorUtils.roundVector(playerVelocity)).." | "..math.round(playerVelocity.Magnitude))]]
    end

    local teleportationThread
    local teleportationConnection: RBXScriptConnection

    local function thing()
        local renderBluePortal = true

        teleportationConnection = RunService.PreRender:Connect(function(dtime)
            
            -- PORTAL RENDERING

            if shared.Settings.PortalRendering then
                local mainPortal = renderBluePortal and bluePortal.Portal or redPortal.Portal
                local otherPortal = renderBluePortal and redPortal.Portal or bluePortal.Portal
                local mainViewport = renderBluePortal and blueViewport or redViewport
                local mainCamera = renderBluePortal and blueViewportCamera or redViewportCamera

                mainViewport.NonStatic:ClearAllChildren()

                local vpfMask = otherPortal.Parent.ViewportFrameMask:Clone()
                vpfMask.Parent = mainViewport.NonStatic
                vpfMask.Transparency = 0

                if bluePortal.OnPart.Value and redPortal.OnPart.Value then
                    mainCamera.CFrame = mainPortal.CFrame

                    local partsInVisibilityHitbox = workspace:GetPartsInPart(mainPortal.Parent.VisibilityHitbox, RaycastUtils.overlapParams(RaycastUtils.FdiPresets.NonStatic))
                    for _, part in partsInVisibilityHitbox do
                        part:Clone().Parent = mainViewport.NonStatic
                    end
                else
                    mainViewport.BackgroundColor3 = renderBluePortal and Color3.new(0, 0, 1) or Color3.fromRGB(1, 0.333333, 0)
                end
            end



            -- VIEWMODEL

            if shared.PlayerState.HasGun then
                portalGun.Transparency = 0
                portalGun.CFrame = camera.CFrame * portalGunOffset.Value
            else
                portalGun.Transparency = 1
            end



            -- TELEPORTATION LOGIC

            playerVel = char.HumanoidRootPart.AssemblyLinearVelocity
            playerSpeed = char.HumanoidRootPart.AssemblyLinearVelocity.Magnitude
            
            if bluePortal.OnPart.Value and redPortal.OnPart.Value then
                prevInBluePortal = table.clone(objectsInBluePortal)
                prevInRedPortal = table.clone(objectsInRedPortal)
                
                
                -- update portalzone size according to player speed
                bluePortal.PortalZone.Size = Vector3.new(bluePortal.PortalZone.Size.X, bluePortal.PortalZone.Size.Y, playerSpeed*dtime*10)
                redPortal.PortalZone.Size = Vector3.new(redPortal.PortalZone.Size.X, redPortal.PortalZone.Size.Y, playerSpeed*dtime*10)
                
                
                -- get parts in portal zones
                local params = RaycastUtils.overlapParams(RaycastUtils.FdiPresets.Objects)
                params.FilterDescendantsInstances = {params.FilterDescendantsInstances, char}
                
                inBluePortal = workspace:GetPartsInPart(bluePortal.PortalZone, params)
                inRedPortal = workspace:GetPartsInPart(redPortal.PortalZone, params)
                
                
                -- is player in portal zone
                prevPlayerInPortal = playerInBluePortal or playerInRedPortal
                
                playerInBluePortal = TableUtils.contains(inBluePortal, InstanceUtils.getInstancesOfType(char:GetChildren(), "BasePart"))
                playerInRedPortal = TableUtils.contains(inRedPortal, InstanceUtils.getInstancesOfType(char:GetChildren(), "BasePart"))
                
                objectsInBluePortal = {}
                for _, part in pairs(inBluePortal) do
                    if part.Parent ~= char then
                        table.insert(objectsInBluePortal, part)
                    end
                end
                objectsInRedPortal = {}
                for _, part in pairs(inRedPortal) do
                    if part.Parent ~= char then
                        table.insert(objectsInRedPortal, part)
                    end
                end
                
                
                -- update player collision group if playerInPortal changed
                playerInPortal = playerInBluePortal or playerInRedPortal
                
                if playerInPortal ~= prevPlayerInPortal then
                    for _, part in pairs(char:GetChildren()) do
                        if part:IsA("BasePart") then
                            local collisionGroup = "Default"
                            if playerInBluePortal and not playerInRedPortal then
                                collisionGroup = "InBluePortal"
                            elseif (not playerInBluePortal) and playerInRedPortal then
                                collisionGroup = "InRedPortal"
                            elseif playerInBluePortal and playerInRedPortal then
                                collisionGroup = "InBothPortals"
                            end
                            part.CollisionGroup = collisionGroup
                        end
                    end
                end
                
                
                -- update collision groups of objects in portals
                
                local function updateObjectsCollisionGroupsForPortal(inPortal: {Part}, prevInPortal: {Part}, portalColour: string)
                    for _, part in pairs(TableUtils.merge(inPortal, prevInPortal)) do
                        part:SetAttribute(`In{portalColour}Portal`, TableUtils.contains(inPortal, part))
                        
                        local isInBluePortal = part:GetAttribute("InBluePortal")
                        local isInRedPortal = part:GetAttribute("InRedPortal")

                        local collisionGroup = "Default"

                        if isInBluePortal and not isInRedPortal then
                            collisionGroup = "InBluePortal"
                        elseif (not isInBluePortal) and isInRedPortal then
                            collisionGroup = "InRedPortal"
                        elseif isInBluePortal and isInRedPortal then
                            collisionGroup = "InBothPortals"
                        end
                        
                        part.CollisionGroup = collisionGroup
                    end
                end
                
                updateObjectsCollisionGroupsForPortal(objectsInBluePortal, prevInBluePortal, "Blue")
                updateObjectsCollisionGroupsForPortal(objectsInRedPortal, prevInRedPortal, "Red")
                
                
                -- teleport object if they are behind the portal
                
                local function teleportObjectIfBehindPortal(object, entrancePortal: Part, exitPortal: Part, isPlayer: boolean, enteringRed: boolean)
                    local camera = workspace.CurrentCamera
                    
                    --local pos = isPlayer and camera.CFrame.Position or object.Position
                    local pos = object.Position
                    
                    local vel
                    if isPlayer then
                        vel = rootPart.AssemblyLinearVelocity
                    else
                        vel = object.AssemblyLinearVelocity
                    end
                    
                    local entranceCframe = entrancePortal.CFrame
                    local exitCframe = exitPortal.CFrame
                    
                    local behindPortal = entranceCframe.LookVector:Dot(pos-entrancePortal.Position) < 0
                    
                    if behindPortal then
                        local projectedPos = VectorUtils.projectThroughPortal(pos, entranceCframe, exitCframe)
                        local projectedVel = VectorUtils.projectThroughPortal(vel + pos, entranceCframe, exitCframe) - projectedPos
                        if isPlayer then
                            rootPart.CFrame = CFrame.new(projectedPos - Vector3.new(0, headHeight, 0))
                            rootPart.AssemblyLinearVelocity = projectedVel
                        else
                            object.Position = projectedPos
                            object.AssemblyLinearVelocity = projectedVel
                        end
                        
                        local newCollisionGroup = `In{enteringRed and "Blue" or "Red"}Portal`
                        object.CollisionGroup = newCollisionGroup

                        if isPlayer then
                            local projectedCam = VectorUtils.projectRotationThroughPortal(camera.CFrame.Rotation, entranceCframe, exitCframe).Rotation
                            CameraService.setCameraRotation(projectedCam)
                            
                            for _, part in pairs(object.Parent:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.CollisionGroup = newCollisionGroup
                                end
                            end
                        end
                    end
                end
                
                for _, object in pairs(objectsInBluePortal) do
                    teleportObjectIfBehindPortal(object, bluePortal.Portal, redPortal.Portal, false, false)
                end
                
                for _, object in pairs(objectsInRedPortal) do
                    teleportObjectIfBehindPortal(object, redPortal.Portal, bluePortal.Portal, false, true)
                end
                
                if playerInBluePortal then
                    teleportObjectIfBehindPortal(head, bluePortal.Portal, redPortal.Portal, true, false)
                elseif playerInRedPortal then
                    teleportObjectIfBehindPortal(head, redPortal.Portal, bluePortal.Portal, true, true)
                end
                
            end
            
            updateStats(playerVel, dtime)
        end)
    end

    LevelService.LevelLoaded:Connect(function()
        shared.PlayerState.HasGun = workspace.Map.LevelSettings.StartWithGun.Value
        shared.PlayerState.GunUpgraded = workspace.Map.LevelSettings.StartWithGunUpgraded.Value
        
        bluePortal:PivotTo(CFrame.new(0,-20,0))
        bluePortal.OnPart.Value = nil
        redPortal:PivotTo(CFrame.new(0,-20,0))
        redPortal.OnPart.Value = nil
        
        -- restart main loop
        if teleportationThread then
            task.cancel(teleportationThread)
        end
        if teleportationConnection then
            teleportationConnection:Disconnect()
        end

        teleportationThread = task.spawn(thing)
        
        -- update map for portal rendering
        if shared.Settings.PortalRendering then
            blueViewport.Static:ClearAllChildren()
            redViewport.Static:ClearAllChildren()
            for _, part in TableUtils.merge(workspace.Map.Building:GetDescendants(), Workspace.Map.AxisPaths:GetDescendants(), Workspace.Map.Other:GetDescendants()) do
                if part:IsA("BasePart") and not part:IsA("Terrain") then
                    part:Clone().Parent = redViewport.Static
                end
            end
        end
    end)
end



-- PORTAL PLACEMENT STUFF

local gunSpinAmount = math.rad(120)
local gunSpinTime = 0.3

local canShootAxis = true

local function getPartsPortalIsOn(portal: Portal)
	return workspace:GetPartsInPart(portal.BehindPortalHitbox, RaycastUtils.overlapParams(RaycastUtils.FdiPresets.Building))
end

local function collisionGroupStuff(portal: Model, partsPortalIsOn: {Part}, prevPartsPortalIsOn: {Part}, portalColour: string)
	for _, part: Part in pairs(TableUtils.merge(partsPortalIsOn, prevPartsPortalIsOn)) do
		part:SetAttribute(`Behind{portalColour}Portal`, TableUtils.contains(partsPortalIsOn, part))
		
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

function PortalService.PlacePortal(portal: Portal, redPortal: boolean, onPart: Part?, placedByPortalPlacer: boolean, pos: Vector3 | CFrame, normal)
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

local function firePortal(portal: Portal, redPortal: boolean)
	local tween = TweenService:Create(portalGunOffset, TweenInfo.new(gunSpinTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Value = portalGunOffset.Value * CFrame.Angles(0, 0, redPortal and -gunSpinAmount or gunSpinAmount)})
	tween:Play()
	
	local raycast = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, RaycastUtils.raycastParams(RaycastUtils.FdiPresets.PortalCollision))
	if raycast then
		if raycast.Instance:IsA("BasePart") and raycast.Instance:GetAttribute("CanHavePortals") and not shared.PlayerState.HoldingObject then
			PortalService.PlacePortal(portal, redPortal, raycast.Instance, false, raycast.Position, raycast.Normal)
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



-- OTHER FUNCTIONS

function PortalService.RaycastThroughPortalLegacy(origin: Vector3, direction: Vector3, raycastParams: RaycastParams)
    raycastParams:AddToFilter(bluePortal.Portal)
    raycastParams:AddToFilter(redPortal.Portal)

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

function PortalService.RaycastThroughPortal(origin: Vector3, direction: Vector3, raycastParams: RaycastParams, depth: number?)
	raycastParams:AddToFilter(bluePortal.Portal)
    raycastParams:AddToFilter(redPortal.Portal)
		
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
		
		return PortalService.RaycastThroughPortal(projectedOrigin, difference, raycastParams, depth and depth+1 or 2)
	end
	return false, {Position = origin + direction}
end

return PortalService