local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local RaycastUtils = require(ReplicatedStorage.Modules.Utils.RaycastUtils)

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")
local human = char:WaitForChild("Humanoid")
local head = char:WaitForChild("Head")
local kilometers

local crouchDist = (head.Position.Y - rootPart.Position.Y) * 1.2

local normalWalkspeed = human.WalkSpeed
local normalJumpHeight = human.JumpHeight
local normalHipHeight = human.HipHeight

local crouchWalkspeed = normalWalkspeed * 0.5
local crouchJumpHeight = normalJumpHeight * 0.5
local crouchHipHeight = normalHipHeight - crouchDist

local CharacterService = {}

function CharacterService.Init()
    kilometers = ReplicatedStorage.Other.Characters.Kilometers:Clone()
    kilometers.Parent = workspace
    kilometers.LocalTransparencyModifier = 1

    RunService.PreRender:Connect(function()
        kilometers.CFrame = rootPart.CFrame - Vector3.new(0,0.5,0)
    end)
end

function CharacterService.Start()
    local crouching = false
    local prevCrouching = false

    ReplicatedStorage.Inputs.Crouch.StateChanged:Connect(function(inputState)
        prevCrouching = crouching
        if inputState then
            crouching = true
        else
            repeat task.wait() until workspace:Blockcast(CFrame.new(char.HumanoidRootPart.Position), char.HumanoidRootPart.Size, Vector3.new(0,crouchDist,0), RaycastUtils.raycastParams("map")) == nil
            crouching = false
        end
        
        if prevCrouching == crouching then return end
        
        human.WalkSpeed = crouching and crouchWalkspeed or normalWalkspeed
        human.JumpHeight = crouching and crouchJumpHeight or normalJumpHeight
        TweenService:Create(human, TweenInfo.new(0.2), {HipHeight = crouching and crouchHipHeight or normalHipHeight}):Play()
    end)
end

return CharacterService