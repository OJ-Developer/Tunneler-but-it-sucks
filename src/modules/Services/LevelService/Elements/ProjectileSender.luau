local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Object = require(ReplicatedStorage.Modules.Classes.Object)

local module = {}
module.__index = module

function module.new(sender)
	local finished = false

	local spawnPoint: Attachment = sender.ProjectileSpawnPoint
	local activatorElement = sender.Configuration.Activator.Value
	if not activatorElement then return end
	local activator: BoolValue = activatorElement.Activated

	local projectile: Object.ObjectType

	local thread
	local mainConnection = activator.Changed:Connect(function(val)
		if val and (not (projectile.Instance and projectile.Instance.Parent)) and (not finished) then
			thread = task.spawn(function()
				TweenService:Create(sender, TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {Rotation = Vector3.new(sender.Rotation.X, sender.Rotation.Y, 1800)}):Play()
				task.wait(2)

				projectile = Object.new("EnergyProjectile", spawnPoint.WorldCFrame, -sender.CFrame.LookVector)
			end)
		end
	end)

	return setmetatable({thread = thread, mainConnection = mainConnection}, module)
end

function module:Cleanup()
	if self.thread then
		task.cancel(self.thread)
	end
	self.mainConnection:Disconnect()
	if self.renderStepConnection then
		self.renderStepConnection:Disconnect()
	end
end

return module