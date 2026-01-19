local module = {}
module.__index = module

local tweenService = game:GetService("TweenService")

local playerScripts = game.Players.LocalPlayer.PlayerScripts
local object = require(playerScripts.Classes.Object)

function module.new(cubeDropper)
	local doorPart1 = cubeDropper.DoorPart1
	local doorPart2 = cubeDropper.DoorPart2
	local tube = cubeDropper.Tube

	local activator = cubeDropper.Configuration.Activator
	if not activator.Value then
		return
	end
	local autoDropCube = cubeDropper.Configuration.AutoDropCube
	local dropObjectType = cubeDropper.Configuration.DropObjectType

	local currentCube = cubeDropper.CurrentCube
	local nextCube = cubeDropper.NextCube

	local cubeSpawnPos = tube.CubeSpawnPos
	local part1ClosedRot = tube.Part1ClosedRot
	local part1OpenedRot = tube.Part1OpenedRot
	local part2ClosedRot = tube.Part2ClosedRot
	local part2OpenedRot = tube.Part2OpenedRot
	
	local dropping = false
	
	local connection2
	
	local function dropCube()
		currentCube.Value = nextCube.Value
		
		if autoDropCube.Value then
			if connection2 then
				connection2:Disconnect()
			end
			connection2 = currentCube.value.AttributeChanged:Connect(function(attributeName)
				if attributeName == "Fizzled" then
					if currentCube.Value:GetAttribute("Fizzled") then
						task.wait(3)
						dropCube()
					end
				end
			end)
		end

		tweenService:Create(doorPart1, TweenInfo.new(0.5), {Rotation = part1OpenedRot.WorldRotation}):Play()
		tweenService:Create(doorPart2, TweenInfo.new(0.5), {Rotation = part2OpenedRot.WorldRotation}):Play()
		doorPart1.CanCollide = false
		doorPart2.CanCollide = false

		task.wait(1)

		tweenService:Create(doorPart1, TweenInfo.new(0.5), {Rotation = part1ClosedRot.WorldRotation}):Play()
		tweenService:Create(doorPart2, TweenInfo.new(0.5), {Rotation = part2ClosedRot.WorldRotation}):Play()
		doorPart1.CanCollide = true
		doorPart2.CanCollide = true

		task.spawn(function()
			task.wait(1)
			cubeDropper.NextCube.Value = object.spawn(dropObjectType.Value, cubeSpawnPos.WorldCFrame)
			dropping = false
		end)
	end

	cubeDropper.NextCube.Value = object.spawn(dropObjectType.Value, cubeSpawnPos.WorldCFrame)

	local connection1 = activator.Value.Activated.Changed:Connect(function(val)
		if val and not dropping then
			task.spawn(function()
				dropping = true
				
				if currentCube.Value then
					object.fizzle(currentCube.Value)
				end

				dropCube()
			end)
		end
	end)
	
	return setmetatable({c1 = connection1, c2 = connection2}, module)
end

function module:Cleanup()
	self.c1:Disconnect()
	if self.c2 then
		self.c2:Disconnect()
	end
end

return module

