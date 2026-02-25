local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ScriptSignal = require(ReplicatedStorage.Packages.GoodSignal)
local MiscData = require(ReplicatedStorage.Data.MiscData)
local Utils = require(ReplicatedStorage.Modules.Utils)
local World = require(ReplicatedStorage.Modules.World)
local LevelService = require(script.Parent.LevelService)
local PortalPlacement = require(script.PortalPlacement)
local PortalRendering = require(script.PortalRendering)
local PortalTeleportationLogic = require(script.PortalTeleportationLogic)

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")
local head = char:WaitForChild("Head")
local headHeight = head.Position.Y - rootPart.Position.Y
local camera = workspace.CurrentCamera
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
	OnPlacementHelper: BoolValue,
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

    portalGunOffset = Instance.new("CFrameValue")
	portalGunOffset.Name = "PortalGunOffset"
	portalGunOffset.Parent = script
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

	PortalPlacement.Init(PortalService)
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

function PortalService.CanPlacePortalOnPart(part: Part)
    return PortalPlacement.CanPlacePortalOnPart(part)
end

function PortalService.PlacePortal(portal: Portal, redPortal: boolean, onPart: Part?, placedByPortalPlacer: boolean, pos: Vector3 | CFrame, normal)
	PortalPlacement.PlacePortal(portal, redPortal, onPart, placedByPortalPlacer, pos, normal)
end



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