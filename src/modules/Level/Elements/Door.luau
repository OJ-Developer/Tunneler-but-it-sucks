local tweenService = game:GetService("TweenService")

local doorOpenTime = 0.5

local module = {}
module.__index = module

function module.new(door)
	local frame = door.Frame
	local topPart = door.Top
	local bottomPart = door.Bottom
	local thing = door.Thing

	local bottomUpPos = frame.BottomUpPos
	local BottomDownPos = frame.BottomDownPos
	local thingUpPos = frame.ThingUpPos
	local thingDownPos = frame.ThingDownPos
	local topUpPos = frame.TopUpPos
	local topDownPos = frame.TopDownPos

	local activator = door.Configuration.Activator
	if not activator.Value then return end
	local deactivator = door.Configuration.Deactivator
	local startOpen = door.Configuration.StartOpen
	
	local connections = {}

	local function open()
		tweenService:Create(thing, TweenInfo.new(doorOpenTime/2), {Rotation = thingUpPos.WorldRotation}):Play()

		task.wait(doorOpenTime/2)

		tweenService:Create(topPart, TweenInfo.new(doorOpenTime/2), {Position = topUpPos.WorldPosition}):Play()
		tweenService:Create(bottomPart, TweenInfo.new(doorOpenTime/2), {Position = BottomDownPos.WorldPosition}):Play()
		tweenService:Create(thing, TweenInfo.new(doorOpenTime/2), {Position = thingUpPos.WorldPosition}):Play()
	end

	local function close()
		tweenService:Create(topPart, TweenInfo.new(doorOpenTime/2), {Position = topDownPos.WorldPosition}):Play()
		tweenService:Create(bottomPart, TweenInfo.new(doorOpenTime/2), {Position = bottomUpPos.WorldPosition}):Play()
		tweenService:Create(thing, TweenInfo.new(doorOpenTime/2), {Position = thingDownPos.WorldPosition}):Play()

		task.wait(doorOpenTime/2)

		tweenService:Create(thing, TweenInfo.new(doorOpenTime/2), {Rotation = thingDownPos.WorldRotation}):Play()
	end

	if startOpen.Value then
		task.spawn(function()
			open()
		end)
	end

	table.insert(connections, activator.Value.Activated.Changed:Connect(function(activated)
		if activated ~= startOpen.Value then
			open()
		else
			close()
		end
	end))
	
	table.insert(connections, deactivator.Value.Activated.Changed:Once(function(activated)
		if activated then
			close()
		end
	end))
	
	return setmetatable({connections = connections}, module)
end

function module:Cleanup()
	for _, connection in self.connections do
		connection:Disconnect()
	end
end

return module

