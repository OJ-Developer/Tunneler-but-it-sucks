local rs = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local events = rs.Events
local levelLoadedEvent = events.Levels.LevelLoaded

local cooldown = 5
local teleportReady = cooldown

local bluePortal: Model = workspace:WaitForChild("BluePortal")
local redPortal: Model = workspace:WaitForChild("RedPortal")

local player =  game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")
local head = char:WaitForChild("Head")

local playerScripts = player.PlayerScripts
local vectorUtils = require(script.Parent.Parent.Utils.VectorUtils)
local raycastUtils = require(playerScripts.Utils.RaycastUtils)
local tableUtils = require(playerScripts.Utils.TableUtils)
local instanceUtils = require(playerScripts.Utils.InstanceUtils)
--local debug = require(playerScripts.Other.Debug)

local camera = workspace.CurrentCamera
local cameraModule = require(script.Parent.Parent.CameraScript.CameraModule)
local headHeight = head.Position.Y - rootPart.Position.Y

local updateStatEvent = events.Other.UpdateDevStat

local inBluePortal = {}
local inRedPortal = {}

local objectsInBluePortal = {}
local objectsInRedPortal = {}

local prevInBluePortal = {}
local prevInRedPortal = {}

local behindBluePortal = {}
local behindRedPortal = {}

local playerInBluePortal = false
local playerInRedPortal = false
local playerInPortal = false
local prevPlayerInPortal = false

local playerBehindBluePortal = false
local playerBehindRedPortal = false

local playerVel
local playerSpeed


local teleported = 0


local function updateStats(playerVelocity: Vector3, dtime: number)
	updateStatEvent:Fire("Fps", math.round(1/dtime))
	updateStatEvent:Fire("BluePortalZone", playerInBluePortal and "true" or "false")
	updateStatEvent:Fire("RedPortalZone", playerInRedPortal and "true" or "false")
	updateStatEvent:Fire("PlayerVelocity", tostring(vectorUtils.roundVector(playerVelocity)).." | "..math.round(playerVelocity.Magnitude))
end


local function thing()
	runService.RenderStepped:Connect(function(dtime)
		playerVel = char.HumanoidRootPart.AssemblyLinearVelocity
		playerSpeed = char.HumanoidRootPart.AssemblyLinearVelocity.Magnitude
		
		if bluePortal.OnPart.Value and redPortal.OnPart.Value then
			prevInBluePortal = table.clone(objectsInBluePortal)
			prevInRedPortal = table.clone(objectsInRedPortal)
			
			
			-- update portalzone size according to player speed
			bluePortal.PortalZone.Size = Vector3.new(bluePortal.PortalZone.Size.X, bluePortal.PortalZone.Size.Y, playerSpeed*dtime*10)
			redPortal.PortalZone.Size = Vector3.new(redPortal.PortalZone.Size.X, redPortal.PortalZone.Size.Y, playerSpeed*dtime*10)
			
			
			-- get parts in portal zones
			local params = raycastUtils.overlapParams("objects")
			params.FilterDescendantsInstances = {params.FilterDescendantsInstances, char}
			
			inBluePortal = workspace:GetPartsInPart(bluePortal.PortalZone, params)
			inRedPortal = workspace:GetPartsInPart(redPortal.PortalZone, params)
			
			
			-- is player in portal zone
			prevPlayerInPortal = playerInBluePortal or playerInRedPortal
			
			playerInBluePortal = tableUtils.contains(inBluePortal, instanceUtils.getInstancesOfType(char:GetChildren(), "BasePart"))
			playerInRedPortal = tableUtils.contains(inRedPortal, instanceUtils.getInstancesOfType(char:GetChildren(), "BasePart"))
			
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
			playerInPortal = playerInBluePortal or playerInRedPortal
			
			if playerInPortal ~= prevPlayerInPortal then
				for _, part in pairs(char:GetChildren()) do
					if part:IsA("BasePart") then
						local collisionGroup = "Default"
						if playerInBluePortal and not playerInRedPortal then
							collisionGroup = "InBluePortal"
						elseif (not playerInBluePortal) and playerInRedPortal then
							collisionGroup = "InRedPortal"
						elseif playerInBluePortal and playerInRedPortal then
							collisionGroup = "InBothPortals"
						end
						part.CollisionGroup = collisionGroup
					end
				end
			end
			
			
			-- update collision groups of objects in portals
			
			local function updateObjectsCollisionGroupsForPortal(inPortal: {Part}, prevInPortal: {Part}, portalColour: string)
				for _, part in pairs(tableUtils.merge(inPortal, prevInPortal)) do
					part:SetAttribute(`In{portalColour}Portal`, tableUtils.contains(inPortal, part))
					
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
			
			
			-- teleport object if they are behind the portal
			
			local function teleportObjectIfBehindPortal(object: Part, entrancePortal: Part, exitPortal: Part, isPlayer: boolean, enteringRed: boolean)
				local camera = workspace.CurrentCamera
				
				--local pos = isPlayer and camera.CFrame.Position or object.Position
				local pos = object.Position
				local camPos = camera.CFrame.Position
				
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
					local projectedPos = vectorUtils.projectThroughPortal(pos, entranceCframe, exitCframe)
					local projectedVel = vectorUtils.projectThroughPortal(vel + pos, entranceCframe, exitCframe) - projectedPos
					if isPlayer then
						rootPart.CFrame = CFrame.new(projectedPos - Vector3.new(0, headHeight, 0))
						rootPart.AssemblyLinearVelocity = projectedVel
					else
						object.Position = projectedPos
						object.AssemblyLinearVelocity = projectedVel
					end
					
					local newCollisionGroup = `In{enteringRed and "Blue" or "Red"}Portal`
					object.CollisionGroup = newCollisionGroup
					
					--[[createDebugObject:Fire(CFrame.new(pos), Vector3.one, Enum.PartType.Ball, Color3.new(1,0,0), 5)
					createDebugObject:Fire(CFrame.new(projectedPos), Vector3.one, Enum.PartType.Ball, Color3.new(1,0.5,0), 5)
					createDebugObject:Fire(CFrame.new(projectedPos), Vector3.one, Enum.PartType.Ball, enteringRed and Color3.new(1,0,0) or Color3.new(1,0.5,0), 5)]]

					if isPlayer then
						local projectedCam = vectorUtils.projectRotationThroughPortal(camera.CFrame.Rotation, entranceCframe, exitCframe).Rotation
						cameraModule.setCameraRotation(projectedCam)
						
						for _, part in pairs(object.Parent:GetChildren()) do
							if part:IsA("BasePart") then
								part.CollisionGroup = newCollisionGroup
							end
						end
					end
				end
			end
			
			for _, object in pairs(objectsInBluePortal) do
				teleportObjectIfBehindPortal(object, bluePortal.Portal, redPortal.Portal, false, false)
			end
			
			for _, object in pairs(objectsInRedPortal) do
				teleportObjectIfBehindPortal(object, redPortal.Portal, bluePortal.Portal, false, true)
			end
			
			if playerInBluePortal then
				teleportObjectIfBehindPortal(head, bluePortal.Portal, redPortal.Portal, true, false)
			elseif playerInRedPortal then
				teleportObjectIfBehindPortal(head, redPortal.Portal, bluePortal.Portal, true, true)
			end
			
		end
		
		updateStats(playerVel, dtime)
	end)
end


local thread
levelLoadedEvent.Event:Connect(function()
	if thread then
		task.cancel(thread)
	end
	teleported = 0
	thread = task.spawn(thing)
end)