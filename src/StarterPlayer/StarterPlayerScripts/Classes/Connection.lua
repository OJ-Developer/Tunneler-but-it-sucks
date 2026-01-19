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

return connection
