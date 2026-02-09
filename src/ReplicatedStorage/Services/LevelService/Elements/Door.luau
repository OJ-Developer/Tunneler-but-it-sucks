local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local LinkedData = require(ReplicatedStorage.Services.LinkedData)

local doorOpenTime = 0.5

local Door = {}
Door.__index = Door

function Door.new(door)
	local self = setmetatable({}, Door)

	self.Model = door
	self.Connections = {}

	return self
end

function Door:Init()
	local door = self.Model

	local startOpen = door.Configuration.StartOpen
	if startOpen.Value then
		self.thread = task.spawn(function()
			self:Open()
		end)
	end

	local activatorObject = door.Configuration.Activator
	local activator
	if activatorObject.Value then
		activator = LinkedData.Get(activatorObject.Value, "ElementClass")
	end
	local deactivatorObject = door.Configuration.Deactivator
	local deactivator
	if deactivatorObject.Value then
		deactivator = LinkedData.Get(deactivatorObject.Value, "ElementClass")
	end
	
	if activator then
		table.insert(self.Connections, activator.OnActivated:Connect(function(activated)
			self:SetActivated(activated)
		end))
	end
	if deactivator then
		table.insert(self.Connections, deactivator.OnActivated:Once(function(activated)
			if activated then
				self:SetActivated(false, true)
			end
		end))
	end
end

function Door:Open()
	local frame = self.Model.Frame
	local topPart = self.Model.Top
	local bottomPart = self.Model.Bottom
	local thing = self.Model.Thing

	local BottomDownPos = frame.BottomDownPos
	local thingUpPos = frame.ThingUpPos
	local topUpPos = frame.TopUpPos

	tweenService:Create(thing, TweenInfo.new(doorOpenTime/2), {Rotation = thingUpPos.WorldRotation}):Play()

	task.wait(doorOpenTime/2)

	tweenService:Create(topPart, TweenInfo.new(doorOpenTime/2), {Position = topUpPos.WorldPosition}):Play()
	tweenService:Create(bottomPart, TweenInfo.new(doorOpenTime/2), {Position = BottomDownPos.WorldPosition}):Play()
	tweenService:Create(thing, TweenInfo.new(doorOpenTime/2), {Position = thingUpPos.WorldPosition}):Play()
end

function Door:Close()
	local frame = self.Model.Frame
	local topPart = self.Model.Top
	local bottomPart = self.Model.Bottom
	local thing = self.Model.Thing

	local bottomUpPos = frame.BottomUpPos
	local thingDownPos = frame.ThingDownPos
	local topDownPos = frame.TopDownPos

	tweenService:Create(topPart, TweenInfo.new(doorOpenTime/2), {Position = topDownPos.WorldPosition}):Play()
	tweenService:Create(bottomPart, TweenInfo.new(doorOpenTime/2), {Position = bottomUpPos.WorldPosition}):Play()
	tweenService:Create(thing, TweenInfo.new(doorOpenTime/2), {Position = thingDownPos.WorldPosition}):Play()

	task.wait(doorOpenTime/2)

	tweenService:Create(thing, TweenInfo.new(doorOpenTime/2), {Rotation = thingDownPos.WorldRotation}):Play()
end

function Door:SetActivated(activated, setTrueState)
	if self.thread then
		task.cancel(self.thread)
	end
	
	if activated ~= (self.Model.Configuration.StartOpen.Value and not setTrueState) then
		self.thread = task.spawn(function()
			self:Open()
		end)
	else
		self.thread = task.spawn(function()
			self:Close()
		end)
	end
end

function Door:Cleanup()
	for _, connection in self.Connections do
		connection:Disconnect()
	end
end

return Door

