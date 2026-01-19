local CAS = game:GetService("ContextActionService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

local camScript = player.PlayerScripts.CameraScript

local playerScripts = player.PlayerScripts
local raycastUtils = require(playerScripts.Utils.RaycastUtils)

local crouchDist = (char:WaitForChild("Head").Position.Y - char:WaitForChild("HumanoidRootPart").Position.Y) * 1.2

local normalWalkspeed = hum.WalkSpeed
local normalJumpHeight = hum.JumpHeight
local normalHipHeight = hum.HipHeight

local crouchWalkspeed = normalWalkspeed * 0.5
local crouchJumpHeight = normalJumpHeight * 0.5
local crouchHipHeight = normalHipHeight - crouchDist

local crouching = false
local prevCrouching = false

local function cameraTween(newCamPos)
	local tween = tweenService:Create(
		camScript.OffsetVector,
		TweenInfo.new(0.2),
		{Value = newCamPos}
	)
	tween:Play()
end

local function crouch(actionName, inputState)
	prevCrouching = crouching
	if inputState == Enum.UserInputState.Begin then
		crouching = true
	elseif inputState == Enum.UserInputState.End then
		repeat task.wait() until workspace:Blockcast(CFrame.new(char.HumanoidRootPart.Position), char.HumanoidRootPart.Size, Vector3.new(0,crouchDist,0), raycastUtils.raycastParams("map")) == nil
		crouching = false
	end
	
	if prevCrouching == crouching then return end
	
	hum.WalkSpeed = crouching and crouchWalkspeed or normalWalkspeed
	hum.JumpHeight = crouching and crouchJumpHeight or normalJumpHeight
	tweenService:Create(hum, TweenInfo.new(0.2), {HipHeight = crouching and crouchHipHeight or normalHipHeight}):Play()
end

CAS:BindAction("Crouch", crouch, true, Enum.KeyCode.LeftShift)