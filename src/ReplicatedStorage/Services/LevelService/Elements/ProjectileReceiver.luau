local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Garbage = require(ReplicatedStorage.Classes.Garbage)
local ScriptSignal = require(ReplicatedStorage.Packages.GoodSignal)

local ProjectileReceiver = {}
ProjectileReceiver.__index = ProjectileReceiver

function ProjectileReceiver.new(reciever)
	local self = setmetatable({}, ProjectileReceiver)

	self.OnActivated = ScriptSignal.new()
	self.Activated = false
	self.Model = reciever

	self.Garbage = Garbage.new()

	return self
end

function ProjectileReceiver:Activate()
	if self.Activated then return end
	self.OnActivated:Fire()
	self.Garbage:Add(RunService.PreRender:Connect(function()
		self.Model.Rotation += Vector3.new(0, 0, 3)
	end))
end

function ProjectileReceiver:Cleanup()
	self.Garbage:Cleanup()
end

return ProjectileReceiver