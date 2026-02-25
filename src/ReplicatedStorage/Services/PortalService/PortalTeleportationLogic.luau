local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MainConfig = require(ReplicatedStorage.Configs.MainConfig)
local Utils = require(ReplicatedStorage.Modules.Utils)
local World = require(ReplicatedStorage.Modules.World)
local CameraService = require(ReplicatedStorage.Services.CameraService)
local UiService = require(ReplicatedStorage.Services.UiService)

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

return function(redPortal, bluePortal, char, dtime, headHeight)
    local rootPart = char.HumanoidRootPart
    local head = char.Head

    local playerSpeed = char.HumanoidRootPart.AssemblyLinearVelocity.Magnitude

    local active = bluePortal.OnPart.Value and redPortal.OnPart.Value
    if active then
        prevInBluePortal = table.clone(objectsInBluePortal)
        prevInRedPortal = table.clone(objectsInRedPortal)
        
        
        -- update portalzone size according to player speed
        bluePortal.PortalZone.Size = Vector3.new(bluePortal.PortalZone.Size.X, bluePortal.PortalZone.Size.Y, playerSpeed*dtime*10)
        redPortal.PortalZone.Size = Vector3.new(redPortal.PortalZone.Size.X, redPortal.PortalZone.Size.Y, playerSpeed*dtime*10)
        
        
        -- get parts in portal zones
        local params = World.overlapParams(World.ParamPreset.Objects)
        params.FilterDescendantsInstances = {params.FilterDescendantsInstances, char}
        
        inBluePortal = workspace:GetPartsInPart(bluePortal.PortalZone, params)
        inRedPortal = workspace:GetPartsInPart(redPortal.PortalZone, params)
        
        
        -- is player in portal zone
        playerInBluePortal = Utils.tableContains(inBluePortal, Utils.getInstancesOfType(char:GetChildren(), "BasePart"))
        playerInRedPortal = Utils.tableContains(inRedPortal, Utils.getInstancesOfType(char:GetChildren(), "BasePart"))
        

        -- get objects in portal zone
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
        prevPlayerInPortal = playerInPortal
        playerInPortal = playerInBluePortal or playerInRedPortal

        if playerInPortal ~= prevPlayerInPortal then
            local collisionGroup = "Default"
            if playerInBluePortal and not playerInRedPortal then
                collisionGroup = "InBluePortal"
            elseif (not playerInBluePortal) and playerInRedPortal then
                collisionGroup = "InRedPortal"
            elseif playerInBluePortal and playerInRedPortal then
                collisionGroup = "InBothPortals"
            end

            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CollisionGroup = collisionGroup
                end
            end
        end
        
        
        -- update collision groups of objects in portals
        
        local function updateObjectsCollisionGroupsForPortal(inPortal: {Part}, prevInPortal: {Part}, portalColour: string)
            for _, part in pairs(Utils.merge(inPortal, prevInPortal)) do
                part:SetAttribute(`In{portalColour}Portal`, table.find(inPortal, part) ~= nil)
                
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
        
        
        -- teleport things if they are behind a portal
        local function teleportObjectIfBehindPortal(object, entrancePortal: Part, exitPortal: Part, isPlayer: boolean, enteringRed: boolean)
            local camera = workspace.CurrentCamera
            
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
                -- project the position and velocity of the object and then apply the new values to the object
                local projectedPos = Utils.projectThroughPortal(pos, entranceCframe, exitCframe)
                local projectedVel = (Utils.projectThroughPortal(vel + pos, entranceCframe, exitCframe) - projectedPos) * 0.8
                if isPlayer then
                    rootPart.CFrame = CFrame.new(projectedPos - Vector3.new(0, headHeight, 0))
                    rootPart.AssemblyLinearVelocity = projectedVel
                else
                    object.Position = projectedPos
                    
                    -- add minimum velocity when going through a portal
                    local length = projectedVel.magnitude
                    if length < MainConfig.MinimumPlayerPortalVelocity and length ~= 0 then
                        print(`Speed is {length} which is less than {MainConfig.MinimumPlayerPortalVelocity}. Increasing speed.`)
                        projectedVel = Utils.Unit(projectedVel) * MainConfig.MinimumPlayerPortalVelocity
                    end

                    object.AssemblyLinearVelocity = projectedVel
                end
                
                -- update collision groups
                local newCollisionGroup = `In{enteringRed and "Blue" or "Red"}Portal`
                object.CollisionGroup = newCollisionGroup

                if isPlayer then
                    local projectedCam = Utils.projectRotationThroughPortal(camera.CFrame.Rotation, entranceCframe, exitCframe).Rotation
                    CameraService.setCameraRotation(projectedCam)
                    
                    for _, part in pairs(object.Parent:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CollisionGroup = newCollisionGroup
                        end
                    end
                end
            end
        end

        -- teleport object if they are behind the portal
        for _, object in pairs(objectsInBluePortal) do
            teleportObjectIfBehindPortal(object, bluePortal.Portal, redPortal.Portal, false, false)
        end
        
        for _, object in pairs(objectsInRedPortal) do
            teleportObjectIfBehindPortal(object, redPortal.Portal, bluePortal.Portal, false, true)
        end

        -- teleport player if behind portal
        if playerInBluePortal then
            teleportObjectIfBehindPortal(head, bluePortal.Portal, redPortal.Portal, true, false)
        elseif playerInRedPortal then
            teleportObjectIfBehindPortal(head, redPortal.Portal, bluePortal.Portal, true, true)
        end
    end

    UiService.UpdateDevstats(math.round(1/dtime), playerInBluePortal and active, playerInRedPortal and active, char.HumanoidRootPart.AssemblyLinearVelocity)
end
