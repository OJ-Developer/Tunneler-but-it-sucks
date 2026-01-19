local ReplicatedStorage = game:GetService("ReplicatedStorage")

local serviceModules = ReplicatedStorage.Modules.Services
local services = {}

for _, moduleScript in serviceModules:GetChildren() do
    local module = require(moduleScript)
    
    if module.Init then
        module.Init()
    end

    table.insert(services, module)
end

for _, service in services do
    if service.Start then
		service.Start()
	end
end