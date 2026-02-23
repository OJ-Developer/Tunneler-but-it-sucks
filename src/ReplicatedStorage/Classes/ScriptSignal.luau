local connection = {}
connection.__index = connection

function connection.new(event, fn)
	return setmetatable({event = event, fn = fn, connected = true}, connection)
end

function connection:Disconnect()
	if not self.connected then return end
	self.connected = false
	
	for i, fn in pairs(self.event.connections) do
		if fn == self.fn then
			table.remove(self.event.connections, i)
			return
		end
	end
end

local event = {}
event.__index = event

export type ScriptSignal = typeof(event) & {
	connections: {}
}

export type Connection = typeof(connection) & {
	event: ScriptSignal,
	fn: any,
	connected: boolean
}

function event.new()
	return setmetatable({connections = {}}, event)
end

function event:Connect(fn): Connection
	table.insert(self.connections, fn)
	return connection.new(self, fn)
end

function event:Once(fn): Connection
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
	for _, fn in self.connections do
		task.spawn(fn, ...)
	end
end

return event
