local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Object = require(ReplicatedStorage.Classes.Object)
local LinkedData = require(ReplicatedStorage.Services.LinkedData)

local ProjectileSender = {}
ProjectileSender.__index = ProjectileSender

function ProjectileSender.new(sender)
	local self = setmetatable({}, ProjectileSender)

	self.Model = sender
	self.Finished = false
	self.Active = false

	self.SpawnPoint = sender.ProjectileSpawnPoint.WorldCFrame

	return self
end

function ProjectileSender:Init()
	local sender = self.Model

	local activatorObject = sender.Configuration.Activator
	local activator
	if activatorObject.Value then
		activator = LinkedData.Get(activatorObject.Value, "ElementClass")
	end

	if activator then
		self.c = activator.OnActivated:Connect(function(val)
			self:SetActivated(val)
		end)
	end
end

function ProjectileSender:SetActivated(activated)
	if activated and not self.Active and not self.Finished then
		self.t = task.spawn(function()
			self.Active = true

			TweenService:Create(
				self.Model, 
				TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), 
				{Rotation = Vector3.new(self.Model.Rotation.X, self.Model.Rotation.Y, 1800)}
			):Play()

			task.wait(2)

			self.Projectile = Object.new("EnergyProjectile", self.SpawnPoint, -self.Model.CFrame.LookVector, self)
		end)
	end
end

function ProjectileSender:Cleanup()
	if self.t then
		task.cancel(self.t)
	end
	if self.c then
		self.c:Disconnect()
	end
end

return ProjectileSender