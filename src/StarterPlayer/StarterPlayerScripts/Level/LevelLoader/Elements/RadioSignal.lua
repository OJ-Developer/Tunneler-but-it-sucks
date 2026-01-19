local module = {}
module.__index = module

function module.new()
	return setmetatable({}, module)
end

function module:Cleanup()

end

return module