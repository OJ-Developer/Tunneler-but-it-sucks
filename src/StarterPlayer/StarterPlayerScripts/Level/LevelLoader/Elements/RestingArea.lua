local tweenService = game:GetService("TweenService")

local module = {}
module.__index = module

function module.new(restingArea)
	local thingIdkWhatToCall = restingArea.Thingidkwhattocall

	local upPos = thingIdkWhatToCall.Up

	local activator = restingArea.Configuration.Activator
	if not activator.Value then return end
	
	local t = task.spawn(function()
		repeat task.wait() until activator.Value.Activated.Value
		local tween = tweenService:Create(thingIdkWhatToCall, TweenInfo.new(5), {Position = upPos.WorldPosition})
		tween:Play()
	end)
	
	return setmetatable({t=t}, module)
end

function module:Cleanup()
	task.cancel(self.t)
end

return module
