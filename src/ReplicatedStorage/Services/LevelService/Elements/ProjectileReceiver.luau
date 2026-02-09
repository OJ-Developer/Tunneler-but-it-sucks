local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ScriptSignal = require(ReplicatedStorage.Classes.ScriptSignal)

local ProjectileReceiver = {}
ProjectileReceiver.__index = ProjectileReceiver

function ProjectileReceiver.new(reciever)
	local self = setmetatable({}, ProjectileReceiver)

	self.OnActivated = ScriptSignal.new()
	self.Activated = false
	self.Model = reciever

	return self
end

function ProjectileReceiver:Activate()
	if self.Activated then return end
	self.OnActivated:Fire()
	self.c = RunService.PreRender:Connect(function()
		self.Model.Rotation += Vector3.new(0, 0, 3)
	end)
end

function ProjectileReceiver:Cleanup()
	if self.c then
		self.c:Disconnect()
	end
end

return ProjectileReceiver