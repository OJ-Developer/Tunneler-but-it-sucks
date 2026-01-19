local connection = require(script.Parent.Connection)

local event = {}
event.__index = event

function event.new()
	return setmetatable({connections = {}}, event)
end

function event:Connect(fn)
	table.insert(self.connections, fn)
	return connection.new(self, fn)
end

function event:Once(fn)
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		fn(...)
	end)
end

function event:Wait()
	
end

function event:Fire(...)
	for _, fn in pairs(self.connections) do
		task.spawn(fn, ...)
	end
end

return event
