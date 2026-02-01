local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Object = require(ReplicatedStorage.Classes.Object)
local ScriptSignal = require(ReplicatedStorage.Classes.ScriptSignal)
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


function InteractionService.Start()
    -- pressing e
    ReplicatedStorage.Inputs.Interact.Pressed:Connect(function()
        if shared.PlayerState.HoldingObject == nil then
            local success, raycast = PortalService.RaycastThroughPortal(mouse.UnitRay.Origin, mouse.UnitRay.Direction * Settings.ObjectMaxGrabDist, World.raycastParams(World.FdiPresets.Interactable))
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
        RunService.PreRender:Connect(function(dTime)
            if shared.PlayerState.HoldingObject then
                if shared.PlayerState.HoldingObject:IsA("BasePart") then
                    local _, raycast = PortalService.RaycastThroughPortal(mouse.UnitRay.Origin, mouse.UnitRay.Direction * Settings.ObjectHoldDist, World.raycastParams(World.FdiPresets.Collideable))
                    raycast.Position -= camera.CFrame.LookVector * Utils.average(shared.PlayerState.HoldingObject.Size) / 2
                
                    rotationOffset -= shared.PlayerState.HasGun and math.pi*0.5*dTime or rotationOffset
                    local playerRotationRy = rootPart.Orientation.Y
                    rotation = CFrame.Angles(0, math.rad(playerRotationRy+180)+rotationOffset, 0)
                    shared.PlayerState.HoldingObject.CFrame = CFrame.new(raycast.Position) * rotation
                end
            end
        end)
    end)
end

return InteractionService