local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Object = require(ReplicatedStorage.Classes.Object)
local LinkedData = require(ReplicatedStorage.Services.LinkedData)

local CubeDropper = {}
CubeDropper.__index = CubeDropper

function CubeDropper.new(cubeDropper)
	local self = setmetatable({}, CubeDropper)
	
	self.Model = cubeDropper
	self.Dropping = false

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
		self.c1 = activator.OnActivated:Connect(function(val)
			self:SetActivated(val)
		end)
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

	print("dropCube()")

	self.CurrentCube = self.NextCube

	print("Auto drop cube", autoDropCube)
	if autoDropCube then
		if self.c2 then
			self.c2:Disconnect()
			print("remove old connection")
		end
		print("current cube: ", self.CurrentCube)
		self.c2 = self.CurrentCube.OnFizzle:Connect(function()
			print("about to drop new cube")
			task.wait(3)
			self:DropCube()
		end)
		print("connected", self.CurrentCube)
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
				self.CurrentCube:Fizzle()
			end

			self:DropCube()
		end)
	end
end

function CubeDropper:Cleanup()
	self.c1:Disconnect()
	if self.c2 then
		self.c2:Disconnect()
	end
end

return CubeDropper

