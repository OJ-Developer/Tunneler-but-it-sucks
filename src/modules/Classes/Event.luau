local connection = require(script.Parent.Connection)

local event = {}
event.__index = event

export type EventType = typeof(event) & {
	connections: {}
}

export type ConnectionType = typeof(connection) & {
	event: EventType,
	fn: any,
	connected: boolean
}

function event.new()
	return setmetatable({connections = {}}, event)
end

function event:Connect(fn): ConnectionType
	table.insert(self.connections, fn)
	return connection.new(self, fn)
end

function event:Once(fn): ConnectionType
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		fn(...)
	end)
	return connection
end

function event:Wait()
	local waiting = true
	self:Once(function()
		waiting = false
	end)
	repeat
		task.wait()
	until not waiting
end

function event:Fire(...)
	for _, fn in pairs(self.connections) do
		task.spawn(fn, ...)
	end
end

return event
