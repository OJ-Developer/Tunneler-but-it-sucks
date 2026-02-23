local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Object = require(ReplicatedStorage.Classes.Object)
local ScriptSignal = require(ReplicatedStorage.Packages.GoodSignal)
local Settings = require(ReplicatedStorage.Configs.MainConfig)
local Utils = require(ReplicatedStorage.Modules.Utils)
local World = require(ReplicatedStorage.Modules.World)
local LinkedData = require(script.Parent.LinkedData)
local PortalService = require(script.Parent.PortalService)

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

shared.PlayerState.HoldingObjectChanged = ScriptSignal.new()

local InteractionService = {}

function InteractionService.Init()
    local noCollisionsFolder = Instance.new("Folder")
    noCollisionsFolder.Name = "NoObjectCollision"
    noCollisionsFolder.Parent = char

    for _, part in char:GetChildren() do
        if part:IsA("BasePart") and part.CanCollide then
            local constraint = Instance.new("NoCollisionConstraint")
            constraint.Part0 = part
            constraint.Parent = noCollisionsFolder
        end
    end
end

function InteractionService.Start()
    -- pressing e
    ReplicatedStorage.Inputs.Interact.Pressed:Connect(function()
        if shared.PlayerState.HoldingObject == nil then
            local success, raycast = PortalService.RaycastThroughPortal(mouse.UnitRay.Origin, mouse.UnitRay.Direction * Settings.ObjectMaxGrabDist, World.raycastParams(World.ParamPreset.Interactable))
            if success then
                if raycast.Instance:IsA("BasePart") then
                    if raycast.Instance.Anchored == false then
                        LinkedData.Get(raycast.Instance, "ObjectClass"):Pickup()
                    elseif raycast.Instance.Name == "Button" and raycast.Instance.Parent.Name == "StandingButton" then
                        LinkedData.Get(raycast.Instance.Parent, "ElementClass"):Press()
                    end
                end
            end
        else
            Object.Drop()
        end
    end)

    -- update holding object position
    task.spawn(function()
        local rotation = CFrame.new()
        local rotationOffset = 0
        RunService.PreRender:Connect(function(dtime)
            if shared.PlayerState.HoldingObject then
                if shared.PlayerState.HoldingObject:IsA("BasePart") then
                    local _, raycast = PortalService.RaycastThroughPortal(mouse.UnitRay.Origin, mouse.UnitRay.Direction * Settings.ObjectHoldDist, World.raycastParams(World.ParamPreset.ObjectCollideable))
                    raycast.Position -= camera.CFrame.LookVector * Utils.average(shared.PlayerState.HoldingObject.Size) / 2
                
                    rotationOffset -= shared.PlayerState.HasGun and math.pi*0.5*dtime or rotationOffset
                    local playerRotationRy = rootPart.Orientation.Y
                    rotation = CFrame.Angles(0, math.rad(playerRotationRy+180)+rotationOffset, 0)
                    shared.PlayerState.HoldingObject.CFrame = CFrame.new(raycast.Position) * rotation
                    shared.PlayerState.HoldingObject.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end)
    end)
end

return InteractionService