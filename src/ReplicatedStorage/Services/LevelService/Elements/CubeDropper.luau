local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Garbage = require(ReplicatedStorage.Classes.Garbage)
local Object = require(ReplicatedStorage.Classes.Object)
local LinkedData = require(ReplicatedStorage.Services.LinkedData)

local CubeDropper = {}
CubeDropper.__index = CubeDropper

function CubeDropper.new(cubeDropper)
	local self = setmetatable({}, CubeDropper)
	
	self.Model = cubeDropper
	self.Dropping = false
	self.Garbage = Garbage.new()

	return self
end

function CubeDropper:Init()
	local dropObjectType = self.Model.Configuration.DropObjectType.Value
	local cubeSpawnPos = self.Model.Tube.CubeSpawnPos.WorldCFrame

	self.NextCube = Object.new(dropObjectType, cubeSpawnPos)

	local activatorObject = self.Model.Configuration.Activator
	local activator
	if activatorObject.Value then
		activator = LinkedData.Get(activatorObject.Value, "ElementClass")
	end

	if activator then
		self.Garbage:Add(activator.OnActivated:Connect(function(val)
			self:SetActivated(val)
		end))
	end
end

function CubeDropper:DropCube()
	local cubeDropper = self.Model
	local doorPart1 = cubeDropper.DoorPart1
	local doorPart2 = cubeDropper.DoorPart2
	local tube = cubeDropper.Tube

	local dropObjectType = self.Model.Configuration.DropObjectType.Value
	local cubeSpawnPos = self.Model.Tube.CubeSpawnPos.WorldCFrame
	local autoDropCube = cubeDropper.Configuration.AutoDropCube.Value

	local part1ClosedRot = tube.Part1ClosedRot
	local part1OpenedRot = tube.Part1OpenedRot
	local part2ClosedRot = tube.Part2ClosedRot
	local part2OpenedRot = tube.Part2OpenedRot

	self.CurrentCube = self.NextCube

	if autoDropCube then
		if self.AutoDropCubeConnection then
			self.AutoDropCubeConnection:Disconnect()
		end
		self.AutoDropCubeConnection = self.CurrentCube.OnFizzle:Connect(function()
			task.wait(3)
			self:DropCube()
		end)
		self.Garbage:Add(self.AutoDropCubeConnection)
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
		self.NextCube = Object.new(dropObjectType, cubeSpawnPos)
		self.Dropping = false
	end)
end

function CubeDropper:SetActivated(activated)
	if activated and not self.Dropping then
		task.spawn(function()
			self.Dropping = true
			
			if self.CurrentCube then
				if self.AutoDropCubeConnection then
					self.AutoDropCubeConnection:Disconnect()
				end
				self.CurrentCube:Fizzle()
			end

			self:DropCube()
		end)
	end
end

function CubeDropper:Cleanup()
	self.Garbage:Cleanup()
end

return CubeDropper

