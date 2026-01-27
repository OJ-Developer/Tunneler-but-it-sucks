local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Object = require(ReplicatedStorage.Classes.Object)

local module = {}
module.__index = module

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

	local currentCube: Object.ObjectType
	local nextCube: Object.ObjectType
	local currentCubeValue: ObjectValue = cubeDropper.CurrentCube
	local nextCubeValue: ObjectValue = cubeDropper.NextCube

	local cubeSpawnPos = tube.CubeSpawnPos
	local part1ClosedRot = tube.Part1ClosedRot
	local part1OpenedRot = tube.Part1OpenedRot
	local part2ClosedRot = tube.Part2ClosedRot
	local part2OpenedRot = tube.Part2OpenedRot
	
	local dropping = false
	
	local connection2
	
	local function dropCube()
		currentCube = nextCube
		currentCubeValue.Value = currentCube.Instance

		if autoDropCube.Value then
			if connection2 then
				connection2:Disconnect()
			end
			connection2 = currentCube.OnFizzle:Connect(function()
				task.wait(3)
				dropCube()
			end)
		end

		TweenService:Create(doorPart1, TweenInfo.new(0.5), {Rotation = part1OpenedRot.WorldRotation}):Play()
		TweenService:Create(doorPart2, TweenInfo.new(0.5), {Rotation = part2OpenedRot.WorldRotation}):Play()
		doorPart1.CanCollide = false
		doorPart2.CanCollide = false

		task.wait(1)

		TweenService:Create(doorPart1, TweenInfo.new(0.5), {Rotation = part1ClosedRot.WorldRotation}):Play()
		TweenService:Create(doorPart2, TweenInfo.new(0.5), {Rotation = part2ClosedRot.WorldRotation}):Play()
		doorPart1.CanCollide = true
		doorPart2.CanCollide = true

		task.spawn(function()
			task.wait(1)
			nextCube = Object.new(dropObjectType.Value, cubeSpawnPos.WorldCFrame)
			nextCubeValue.Value = nextCube.Instance
			dropping = false
		end)
	end

	nextCube = Object.new(dropObjectType.Value, cubeSpawnPos.WorldCFrame)
	nextCubeValue.Value = nextCube.Instance

	local connection1 = activator.Value.Activated.Changed:Connect(function(val)
		if val and not dropping then
			task.spawn(function()
				dropping = true
				
				if currentCube then
					currentCube:Fizzle()
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

