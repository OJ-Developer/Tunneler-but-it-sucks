local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Object = require(ReplicatedStorage.Modules.Classes.Object)
local LinkedData = require(script.Parent.LinkedData)
local RaycastUtils = require(ReplicatedStorage.Modules.Utils.RaycastUtils)
local VectorUtils = require(ReplicatedStorage.Modules.Utils.VectorUtils)

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local InteractionService = {}


function InteractionService.Start()
    -- pressing e
    ReplicatedStorage.Inputs.Interact.Pressed:Connect(function()
        if shared.PlayerState.HoldingObject == nil then
            local success, raycast = RaycastUtils.raycastThroughPortal(mouse.UnitRay.Origin, mouse.UnitRay.Direction * script.Parent.Configuration.MaxGrabDist.Value, RaycastUtils.raycastParams(RaycastUtils.FdiPresets.Interactable))
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
                    --local success, raycast = raycastUtils.raycastThroughPortal(mouse.UnitRay.Origin, mouse.UnitRay.Direction * script.Parent.Configuration.HoldDist.Value, RaycastUtils.raycastParams(RaycastUtils.FdiPresets.Collideable))
                    local pos = RaycastUtils.raycastThroughPortalLegacy(mouse.UnitRay.Origin, mouse.UnitRay.Direction * script.Parent.Configuration.HoldDist.Value, RaycastUtils.raycastParams(RaycastUtils.FdiPresets.Collideable))
                    pos -= camera.CFrame.LookVector * VectorUtils.average(shared.PlayerState.HoldingObject.Size) / 2
                
                    rotationOffset -= script.Parent.Parent.Portal.HasGun.Value and math.pi*0.5*dTime or rotationOffset
                    local playerRotationRy = rootPart.Orientation.Y
                    rotation = CFrame.Angles(0, math.rad(playerRotationRy+180)+rotationOffset, 0)
                    shared.PlayerState.HoldingObject.CFrame = CFrame.new(pos) * rotation
                end
            end
        end)
    end)
end

return InteractionService