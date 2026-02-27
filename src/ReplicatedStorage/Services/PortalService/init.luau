local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ScriptSignal = require(ReplicatedStorage.Packages.GoodSignal)
local MiscData = require(ReplicatedStorage.Data.MiscData)
local Utils = require(ReplicatedStorage.Modules.Utils)
local World = require(ReplicatedStorage.Modules.World)
local Axis = require(script.Parent.Axis)
local LevelService = require(script.Parent.LevelService)
local PortalRendering = require(script.PortalRendering)
local PortalTeleportationLogic = require(script.PortalTeleportationLogic)

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")
local head = char:WaitForChild("Head")
local headHeight = head.Position.Y - rootPart.Position.Y
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()
local playerGui = player.PlayerGui

local portalsUi: Folder
local blueViewport: ViewportFrame
local redViewport: ViewportFrame
local blueViewportCamera: Camera
local redViewportCamera: Camera

local PortalService = {
    PortalPlaced = ScriptSignal.new()
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
    Portal: Part & {
		Decal: Decal
	},
    PortalZone: Part,
	PortalSurface: Part,

    PrimaryPart: Part
}

function PortalService.Init()
	-- setup portals
    bluePortal = ReplicatedStorage.Assets.Portal:Clone()
	bluePortal.Name = "BluePortal"
	bluePortal.Portal.Decal.ColorMap = MiscData.PortalTextures.Blue
	for _, hitbox in bluePortal.Hitbox:GetChildren() do
		hitbox.CollisionGroup = "InBluePortal"
	end
    bluePortal.Parent = workspace

    redPortal = ReplicatedStorage.Assets.Portal:Clone()
	redPortal.Name = "RedPortal"
	redPortal.Portal.Decal.ColorMap = MiscData.PortalTextures.Red
	for _, hitbox in redPortal.Hitbox:GetChildren() do
		hitbox.CollisionGroup = "InRedPortal"
	end
    redPortal.Parent = workspace

	-- portalgun viewmodel
    portalGun = ReplicatedStorage.Assets.PortalGun:Clone()
    portalGun.Parent = workspace

    portalGunOffset = Instance.new("CFrameValue", script)
    portalGunOffset.Value = CFrame.new(1.5, -1, -2)
    PortalService.PortalGunOffset = portalGunOffset

	shared.PlayerState.GunChanged = ScriptSignal.new()

	-- setup portal rendering ui
    shared.Settings.PortalRendering = true

	portalsUi = Instance.new("Folder")
	portalsUi.Name = "Portals"

	local blueSurface = Instance.new("SurfaceGui", portalsUi)
	blueSurface.LightInfluence = 1
	blueSurface.Name = "Blue"
	blueSurface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	blueSurface.ZOffset = 1
	blueSurface.Adornee = bluePortal.PortalSurface
	blueViewport = Instance.new("ViewportFrame", blueSurface)
	blueViewport.Size = UDim2.fromScale(1,1)
	blueViewport.BorderSizePixel = 0

	local redSurface = Instance.new("SurfaceGui", portalsUi)
	redSurface.LightInfluence = 1
	redSurface.Name = "Red"
	redSurface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	redSurface.ZOffset = 1
	redSurface.Adornee = redPortal.PortalSurface
	redViewport = Instance.new("ViewportFrame", redSurface)
	redViewport.Size = UDim2.fromScale(1,1)
	redViewport.BorderSizePixel = 0

	blueViewportCamera = Instance.new("Camera", portalsUi)
    redViewportCamera = Instance.new("Camera", portalsUi)

	blueViewport.CurrentCamera = redViewportCamera
	redViewport.CurrentCamera = blueViewportCamera
	
	portalsUi.Parent = playerGui
end

function PortalService.Start()
    local teleportationThread
    local teleportationConnection: RBXScriptConnection

    local function thing()
        teleportationConnection = RunService.PreRender:Connect(function(dtime)
            PortalRendering(bluePortal, redPortal, char, blueViewport, redViewport, blueViewportCamera, redViewportCamera)

            if shared.PlayerState.HasGun then
                portalGun.Transparency = 0
                portalGun.CFrame = camera.CFrame * portalGunOffset.Value
            else
                portalGun.Transparency = 1
            end

            PortalTeleportationLogic(redPortal, bluePortal, char, dtime, headHeight)
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
    end)
end



-- PORTAL PLACEMENT STUFF

local gunSpinAmount = math.rad(120)
local gunSpinTime = 0.3

local canShootAxis = true

function PortalService.CanPlacePortalOnPart(part: Part)
    return shared.PlayerState.GunIgnoreMaterials or part:GetAttribute("CanHavePortals") and not shared.PlayerState.HoldingObject
end

local function getPartsPortalIsOn(portal: Portal)
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
	
	local raycast = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, World.raycastParams(World.ParamPreset.PortalCollision))
	if raycast then
		if PortalService.CanPlacePortalOnPart(raycast.Instance) then
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

function PortalService.RaycastThroughPortal(origin: Vector3, direction: Vector3, raycastParams: RaycastParams, debug: boolean?, second: boolean?)
	local raycastParamsCopy = Utils.CopyParams(raycastParams)
	local paramsInclude = raycastParams.FilterType == Enum.RaycastFilterType.Include
	if paramsInclude and not second then
		raycastParams:AddToFilter(bluePortal.PortalSurface)
		raycastParams:AddToFilter(redPortal.PortalSurface)
	end

	local raycast = workspace:Raycast(origin, direction, raycastParams)
	if raycast then
		if debug then
			print(raycast.Instance)
		end
		local resultNotOnPortal = raycast.Instance ~= bluePortal.PortalSurface and raycast.Instance ~= redPortal.PortalSurface
		local portalsNotActive = bluePortal.OnPart.Value == nil or redPortal.OnPart.Value == nil

		local entryPortal

		if resultNotOnPortal and not paramsInclude then
			local portalRaycast = workspace:Raycast(origin, raycast.Position - origin, World.raycastParams(World.ParamPreset.Portals))
			resultNotOnPortal = portalRaycast == nil
			if portalRaycast then
				entryPortal = portalRaycast.Instance
			end
		end

		if resultNotOnPortal or portalsNotActive or second then
			return true, {Position = raycast.Position, Instance = raycast.Instance, Distance = raycast.Distance, Normal = raycast.Normal}
		end
		
		if not entryPortal then
			entryPortal = raycast.Instance
		end
		local exitPortal = (entryPortal == bluePortal.PortalSurface) and redPortal.PortalSurface or bluePortal.PortalSurface
		
		local projectedTarget = Utils.projectThroughPortal(origin+direction, entryPortal.CFrame, exitPortal.CFrame)
		
		local projectedOrigin = Utils.projectThroughPortal(raycast.Position, entryPortal.CFrame, exitPortal.CFrame)
		local difference = projectedTarget - projectedOrigin
		
		return PortalService.RaycastThroughPortal(projectedOrigin, difference, raycastParamsCopy, debug, true)
	end
	return false, {Position = origin + direction}
end

return PortalService