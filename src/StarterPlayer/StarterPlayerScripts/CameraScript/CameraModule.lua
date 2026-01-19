local module = {}


-- services

local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")


-- references

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local human = char:WaitForChild("Humanoid")
local rootPart = char:WaitForChild("HumanoidRootPart")
local head = char:WaitForChild("Head")
local camera = workspace.CurrentCamera


-- modules

local vectorUtils = require(script.Parent.Parent.Utils.VectorUtils)


-- variables

local initialized = false
local running = false

local rotation = Vector2.zero
local maxYRot = 1.57


-- private functions

local function updateCamera()
	rotation -= uis:GetMouseDelta() * math.rad(uis.MouseDeltaSensitivity / 2.5)
	
	local yRot = rotation.Y
	if yRot > maxYRot then
		yRot = maxYRot
	elseif yRot < -maxYRot then
		yRot = -maxYRot
	end
	rotation = Vector2.new(rotation.X, yRot)
	
	camera.CFrame = CFrame.new(head.Position) * CFrame.fromEulerAnglesYXZ(rotation.Y, rotation.X, 0)
end

local function updateRootPartOrientation()
	if human.Health > 0 then
		local camLook = camera.CFrame.LookVector
		rootPart.CFrame = CFrame.lookAt(Vector3.zero, Vector3.new(camLook.X, 0, camLook.Z)) + rootPart.Position
	end
end



-- public functions

function module.Init()
	module.setPlayerLocalTransparency(1)
	uis.MouseBehavior = Enum.MouseBehavior.LockCenter
	human.AutoRotate = false
	initialized = true
end

function module.Start()
	if not initialized then
		repeat task.wait() until initialized
	end
	if running then return end
	running = true
	local rotationVec3 = Vector3.new(camera.CFrame.Rotation:ToOrientation())
	rotation = Vector2.new(rotationVec3.Y, rotationVec3.X)
	runService:BindToRenderStep("UpdateCamera", 1, updateCamera)
	runService:BindToRenderStep("UpdateRootPartOrientation", 3002, updateRootPartOrientation)
end

function module.Stop()
	if not initialized then
		repeat task.wait() until initialized
		task.wait()
	end
	if not running then return end
	running = false
	runService:UnbindFromRenderStep("UpdateCamera")
	runService:UnbindFromRenderStep("UpdateRootPartOrientation")
end

function module.setPlayerLocalTransparency(transparency: number)
	for _, instance: Instance in pairs(char:GetDescendants()) do
		if instance:IsA("BasePart") or instance:IsA("Decal") then
			instance.LocalTransparencyModifier = transparency
		end
	end
end

function module.setCameraRotation(newRotation: Vector2 | Vector3, rotationInDegrees: boolean)
	local rotationType = typeof(newRotation)
	if rotationType == "Vector2" then
		rotation = newRotation
	elseif rotationType == "Vector3" then
		rotation = Vector2.new(newRotation.Y, newRotation.X)
	elseif rotationType == "CFrame" then
		module.setCameraRotation(Vector3.new(newRotation:ToOrientation()), false)
	end
	
	
	if rotationInDegrees then
		rotation = vectorUtils.rad(rotation)
	end
end

function module.getCameraRotation(inDegrees: boolean): Vector2
	if inDegrees then
		return vectorUtils.deg(rotation)
	else
		return rotation
	end
end

return module