local CAS = game:GetService("ContextActionService")
local runService = game:GetService("RunService")
local rs = game:GetService("ReplicatedStorage")
local uis = game:GetService("UserInputService")

local events = rs.Events

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")

local playerScripts = player.PlayerScripts
local object = require(playerScripts.Classes.Object)
local vectorUtils = require(playerScripts.Utils.VectorUtils)
local raycastUtils = require(playerScripts.Utils.RaycastUtils)

local standingButtonClickEvent = events.Game.StandingButtonClick

local holdingObject = script.Parent.HoldingObject

local function updateHoldingItemPosition()
	local rotation = CFrame.new()
	local rotationOffset = 0
	runService.RenderStepped:Connect(function(dTime)
		if holdingObject.Value then
			if holdingObject.Value:IsA("BasePart") then
				--local success, raycast = raycastUtils.raycastThroughPortal(mouse.UnitRay.Origin, mouse.UnitRay.Direction * script.Parent.Configuration.HoldDist.Value, raycastUtils.raycastParams("collideable"))
				local pos = raycastUtils.raycastThroughPortalLegacy(mouse.UnitRay.Origin, mouse.UnitRay.Direction * script.Parent.Configuration.HoldDist.Value, raycastUtils.raycastParams("collideable"))
				pos -= camera.CFrame.LookVector * vectorUtils.average(holdingObject.Value.Size) / 2
			
				rotationOffset -= script.Parent.Parent.Portal.HasGun.Value and math.pi*0.5*dTime or rotationOffset
				local playerRotationRy = rootPart.Orientation.Y
				rotation = CFrame.Angles(0, math.rad(playerRotationRy+180)+rotationOffset, 0)
				holdingObject.Value.CFrame = CFrame.new(pos) * rotation
			end
		end
	end)
end

local function interact(actionName, inputState)
	if inputState == Enum.UserInputState.End then return end
	if holdingObject.Value == nil then
		local success, raycast = raycastUtils.raycastThroughPortal(mouse.UnitRay.Origin, mouse.UnitRay.Direction * script.Parent.Configuration.MaxGrabDist.Value, raycastUtils.raycastParams("interactable"))
		if success then
			if raycast.Instance:IsA("BasePart") then
				if raycast.Instance.Anchored == false then
					object.pickup(raycast.Instance)
				elseif raycast.Instance.Name == "Button" and raycast.Instance.Parent.Name == "StandingButton" then
					standingButtonClickEvent:Fire(raycast.Instance)
				end
			end
		end
	else
		object.drop()
	end
end

CAS:BindAction("Interact", interact, true)

task.spawn(updateHoldingItemPosition)

uis.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.E then
		if gameProcessedEvent then return end
		interact()
	end
end)