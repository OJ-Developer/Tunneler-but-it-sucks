local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local rs = game:GetService("ReplicatedStorage")

local events = rs.Events

local object = require(script.Parent.Parent.Parent.Parent.Classes.Object)
local instanceUtils = require(script.Parent.Parent.Parent.Parent.Utils.InstanceUtils)
local vectorUtils = require(script.Parent.Parent.Parent.Parent.Utils.VectorUtils)

local module = {}
module.__index = module

function module.new(sender: Part)
	local finished = false

	local spawnPoint: Attachment = sender.ProjectileSpawnPoint
	local activatorElement: Instance = sender.Configuration.Activator.Value
	if not activatorElement then return end
	local activator: BoolValue = activatorElement.Activated

	local projectile: Part

	local thread
	local mainConnection = activator.Changed:Connect(function(val)
		if val and (not (projectile and projectile.Parent)) and (not finished) then
			thread = task.spawn(function()
				tweenService:Create(sender, TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {Rotation = Vector3.new(sender.Rotation.X, sender.Rotation.Y, 1800)}):Play()
				task.wait(2)

				projectile = object.spawn("EnergyProjectile", spawnPoint.WorldCFrame, -sender.CFrame.LookVector)
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