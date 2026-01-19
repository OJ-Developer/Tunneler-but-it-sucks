local replicatedStorage = game:GetService("ReplicatedStorage")
local events = replicatedStorage:WaitForChild("Events")
local levelLoadedEvent = events:WaitForChild("Levels"):WaitForChild("LevelLoaded")

local cooldown = 5
local teleportReady = cooldown

local modules = replicatedStorage:WaitForChild("Modules")
local vectorFunctions = require(modules:WaitForChild("Operations"):WaitForChild("VectorFunctions"))

local function thing()
	local bluePortal = workspace.BluePortal
	local redPortal = workspace.RedPortal

	local player =  game.Players.LocalPlayer
	local char = player.Character

	local camera = workspace.CurrentCamera
	local cameraScript = player.PlayerGui.Scripts.CustomCameraScript

	local updateStatEvent = player.PlayerGui.DevStats.Frame.UpdateStat

	local inBluePortal = false
	local inRedPortal = false

	local behindBluePortal = false
	local behindRedPortal = false
	
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = {char}

	game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
		local playerSpeedVector = char.HumanoidRootPart.AssemblyLinearVelocity
		local playerSpeed = char.HumanoidRootPart.AssemblyLinearVelocity.Magnitude
		
		if bluePortal.OnPart.Value and bluePortal.OnPart.Value:IsA("BasePart") and redPortal.OnPart.Value and redPortal.OnPart.Value:IsA("BasePart") then
			-- walking into portals
			
			if playerSpeed / 10 < 1 then playerSpeed = 1 end
			
			bluePortal.PortalZone.Size = Vector3.new(bluePortal.PortalZone.Size.X, bluePortal.PortalZone.Size.Y, playerSpeed*deltaTime*10)
			redPortal.PortalZone.Size = Vector3.new(redPortal.PortalZone.Size.X, redPortal.PortalZone.Size.Y, playerSpeed*deltaTime*10)
			
			local partsInBluePortal = workspace:GetPartsInPart(bluePortal.PortalZone, overlapParams)
			local partsInRedPortal = workspace:GetPartsInPart(redPortal.PortalZone, overlapParams)
			
			inBluePortal = #partsInBluePortal > 0
			inRedPortal = #partsInRedPortal > 0
			
			if bluePortal.OnPart.Value == redPortal.OnPart.Value then
				bluePortal.OnPart.Value.CanCollide = not (inBluePortal or inRedPortal)
			else
				bluePortal.OnPart.Value.CanCollide = not inBluePortal
				redPortal.OnPart.Value.CanCollide = not inRedPortal
			end
			
			
			
			-- teleporting the player
			
			if not (teleportReady == cooldown) then teleportReady += 1 return end
			
			behindBluePortal = bluePortal.BluePortal.CFrame.LookVector:Dot((workspace.CurrentCamera.CFrame.Position - bluePortal.BluePortal.Position).Unit) < 0
			behindRedPortal = redPortal.RedPortal.CFrame.LookVector:Dot((workspace.CurrentCamera.CFrame.Position - redPortal.RedPortal.Position).Unit) < 0
			
			if inBluePortal and behindBluePortal then
				redPortal.OnPart.Value.CanCollide = false
				
				local tpTo = char.HumanoidRootPart.Position + (redPortal.RedPortal.Position - bluePortal.BluePortal.Position)
				--tpTo += (redPortal.RedPortal.Position - tpTo) * 2
				--tpTo -= (2 * (tpTo - redPortal.RedPortal.Position):Dot(redPortal.RedPortal.CFrame.LookVector) * redPortal.RedPortal.CFrame.LookVector)
			
				char.HumanoidRootPart.CFrame = CFrame.new(tpTo)
				local addRotation = redPortal.RedPortal.Orientation - bluePortal.BluePortal.Orientation
				cameraScript.RotationOffsetThingForWalkingIntoPortalsOrSomethingBecauseILikeMakingTheseNamesReallyLongForSomeReas.Value = Vector3.new(180 - addRotation.Y, 0 - addRotation.X)
				
				local newVelocity = Vector3.new(playerSpeed, playerSpeed, playerSpeed) * redPortal.RedPortal.CFrame.Rotation.LookVector
				char.HumanoidRootPart.AssemblyLinearVelocity = newVelocity
				
				teleportReady = 0
			elseif inRedPortal and behindRedPortal then
				bluePortal.OnPart.Value.CanCollide = false
				
				local tpTo = char.HumanoidRootPart.Position + (bluePortal.BluePortal.Position - redPortal.RedPortal.Position)
				--tpTo += (bluePortal.BluePortal.Position - tpTo) * 2
				--tpTo -= (2 * (tpTo - bluePortal.BluePortal.Position):Dot(bluePortal.BluePortal.CFrame.LookVector) * bluePortal.BluePortal.CFrame.LookVector)
				
				char.HumanoidRootPart.CFrame = CFrame.new(tpTo)
				local addRotation = bluePortal.BluePortal.Orientation - redPortal.RedPortal.Orientation
				cameraScript.RotationOffsetThingForWalkingIntoPortalsOrSomethingBecauseILikeMakingTheseNamesReallyLongForSomeReas.Value = Vector3.new(180 - addRotation.Y, 0 - addRotation.X)
				
				local newVelocity = Vector3.new(playerSpeed, playerSpeed, playerSpeed) * bluePortal.BluePortal.CFrame.Rotation.LookVector
				char.HumanoidRootPart.AssemblyLinearVelocity = newVelocity
				
				teleportReady = 0
			end
		end
		
		-- update stats
		
		updateStatEvent:Fire("Fps", math.round(1/deltaTime))
		updateStatEvent:Fire("BluePortalZone", inBluePortal and "true" or "false")
		updateStatEvent:Fire("RedPortalZone", inRedPortal and "true" or "false")
		updateStatEvent:Fire("BehindBluePortal", behindBluePortal and "true" or "false")
		updateStatEvent:Fire("BehindRedPortal", behindRedPortal and "true" or "false")
		updateStatEvent:Fire("PlayerVelocity", tostring(vectorFunctions.roundVector(playerSpeedVector)).." | "..math.round(playerSpeed))
	end)
end

local thread = nil
levelLoadedEvent.Event:Connect(function()
	if thread then
		task.cancel(thread)
	end
	thread = task.spawn(thing)
end)