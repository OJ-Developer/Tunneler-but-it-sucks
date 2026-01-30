local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MainConfig = require(ReplicatedStorage.Configs.MainConfig)
local World = require(ReplicatedStorage.Modules.World)

local left: ImageLabel
local right: ImageLabel
local dot: ImageLabel

local player = Players.LocalPlayer
local playerGui = player.PlayerGui.Gui
local mouse = player:GetMouse()

local Crosshair = {}

local function updateCrosshairVisibility(visible)
	left.Visible = visible
	right.Visible = visible
	dot.Visible = visible
end

function Crosshair.Init()
    local crosshair = playerGui.Crosshair
    left = crosshair.Left
    right = crosshair.Right
    dot = crosshair.Dot

    shared.PlayerState.HoldingObjectChanged:Connect(function(v)
        updateCrosshairVisibility(v == nil)
    end)
end

function Crosshair.Start()
    task.spawn(function()
        while task.wait() do
            if shared.PlayerState.HasGun then
                local objectRaycast = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * MainConfig.ObjectMaxGrabDist, World.raycastParams(World.FdiPresets.Interactable))

                if objectRaycast then
                    if (objectRaycast.Instance.Parent == workspace.Map.Objects) or (objectRaycast.Instance.Parent.Parent == workspace.Map.Elements and objectRaycast.Instance.Parent.Name == "StandingButton" and objectRaycast.Instance.Name == "Button") then
                        left.ImageColor3 = Color3.new(1, 1, 0)
                        right.ImageColor3 = Color3.new(1, 1, 0)
                        left.ImageTransparency = 0
                        right.ImageTransparency = 0
                        continue
                    end
                end
                
                left.ImageColor3 = Color3.new(0, 0, 1)
                right.ImageColor3 = shared.PlayerState.GunUpgraded and Color3.new(1, 0.5, 0) or Color3.new(0, 0, 1)
                
                local raycast = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 1000, World.raycastParams(World.FdiPresets.PortalCollision))
                if raycast then
                    if raycast.Instance:IsA("BasePart") then
                        if raycast.Instance:GetAttribute("CanHavePortals") then
                            left.ImageTransparency = 0
                            right.ImageTransparency = 0
                        else
                            left.ImageTransparency = 1
                            right.ImageTransparency = 1
                        end
                    end
                else
                    left.ImageTransparency = 1
                    right.ImageTransparency = 1
                end
            else
                left.ImageTransparency = 1
                right.ImageTransparency = 1
            end
        end
    end)
end

function Crosshair.Enable()
    updateCrosshairVisibility(true)
end

function Crosshair.Disable()
    updateCrosshairVisibility(false)
end

return Crosshair