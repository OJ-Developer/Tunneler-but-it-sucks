local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LinkedData = require(ReplicatedStorage.Services.LinkedData)

local RestingArea = {}
RestingArea.__index = RestingArea

function RestingArea.new(restingArea)
	local self = setmetatable({}, RestingArea)

	self.Model = restingArea
	self.Activated = false

	return self
end

function RestingArea:Init()
	local restingArea = self.Model

	local activatorObject = restingArea.Configuration.Activator
	local activator
	if activatorObject.Value then
		activator = LinkedData.Get(activatorObject.Value, "ElementClass")
	end
	
	if activator then
		self.c = activator.OnActivated:Connect(function(activated)
			self:SetActivated(activated)
		end)
	end
end

function RestingArea:SetActivated(activated)
	if activated and not self.Activated then
		self.Activated = true
		local tween = TweenService:Create(self.Model.Thingidkwhattocall, TweenInfo.new(5), {Position = self.Model.Thingidkwhattocall.Up.WorldPosition})
		tween:Play()
	end
end

function RestingArea:Cleanup()
	if self.c then
		self.c:Disconnect()
	end
end

return RestingArea
