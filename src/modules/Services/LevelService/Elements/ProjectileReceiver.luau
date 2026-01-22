local module = {}
module.__index = module

function module.new(reciever)
	local activated = reciever:WaitForChild("Activated")
	
	local t = task.spawn(function()
		while task.wait() do
			if activated.Value then
				reciever.Rotation += Vector3.new(0, 0, 3)
			end
		end
	end)
	
	return setmetatable({t=t}, module)
end

function module:Cleanup()
	task.cancel(self.t)
end

return module
