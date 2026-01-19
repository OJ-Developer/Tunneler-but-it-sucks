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

	local prevActivated = activator.Value.Activated.Value
	
	task.spawn(function()
		if startOpen.Value then
			tweenService:Create(thing, TweenInfo.new(doorOpenTime/2), {Rotation = thingUpPos.WorldRotation}):Play()

			wait(doorOpenTime/2)

			tweenService:Create(topPart, TweenInfo.new(doorOpenTime/2), {Position = topUpPos.WorldPosition}):Play()
			tweenService:Create(bottomPart, TweenInfo.new(doorOpenTime/2), {Position = BottomDownPos.WorldPosition}):Play()
			tweenService:Create(thing, TweenInfo.new(doorOpenTime/2), {Position = thingUpPos.WorldPosition}):Play()
		end
	end)

	local thread = task.spawn(function()
		while task.wait() do
			if activator.Value.Activated.Value ~= prevActivated then
				prevActivated = activator.Value.Activated.Value
				if activator.Value.Activated.Value ~= startOpen.Value then
					tweenService:Create(thing, TweenInfo.new(doorOpenTime/2), {Rotation = thingUpPos.WorldRotation}):Play()

					wait(doorOpenTime/2)

					tweenService:Create(topPart, TweenInfo.new(doorOpenTime/2), {Position = topUpPos.WorldPosition}):Play()
					tweenService:Create(bottomPart, TweenInfo.new(doorOpenTime/2), {Position = BottomDownPos.WorldPosition}):Play()
					tweenService:Create(thing, TweenInfo.new(doorOpenTime/2), {Position = thingUpPos.WorldPosition}):Play()
				else
					tweenService:Create(topPart, TweenInfo.new(doorOpenTime/2), {Position = topDownPos.WorldPosition}):Play()
					tweenService:Create(bottomPart, TweenInfo.new(doorOpenTime/2), {Position = bottomUpPos.WorldPosition}):Play()
					tweenService:Create(thing, TweenInfo.new(doorOpenTime/2), {Position = thingDownPos.WorldPosition}):Play()

					wait(doorOpenTime/2)

					tweenService:Create(thing, TweenInfo.new(doorOpenTime/2), {Rotation = thingDownPos.WorldRotation}):Play()
				end
			end

			if deactivator.Value.Activated.Value then
				tweenService:Create(topPart, TweenInfo.new(doorOpenTime/2), {Position = topDownPos.WorldPosition}):Play()
				tweenService:Create(bottomPart, TweenInfo.new(doorOpenTime/2), {Position = bottomUpPos.WorldPosition}):Play()
				tweenService:Create(thing, TweenInfo.new(doorOpenTime/2), {Position = thingDownPos.WorldPosition}):Play()

				wait(doorOpenTime/2)

				tweenService:Create(thing, TweenInfo.new(doorOpenTime/2), {Rotation = thingDownPos.WorldRotation}):Play()

				break
			end
		end
	end)
	
	return setmetatable({t = thread}, module)
end

function module:Cleanup()
	task.cancel(self.t)
end

return module

