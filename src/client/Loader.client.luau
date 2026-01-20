local ReplicatedStorage = game:GetService("ReplicatedStorage")

local serviceModules = ReplicatedStorage.Modules.Services
local services = {}

for _, moduleScript in serviceModules:GetChildren() do
    local module = require(moduleScript)
    
    if module.Init then
        local s, e = pcall(function()
            module.Init()
        end)

        if not s then
            warn(`Module {moduleScript.Name} experienced error "{e}" while initializing`)
            continue
        end
    end

    services[moduleScript.Name] = module
end

for name, service in services do
    if service.Start then
        local s, e = pcall(function()
            service.Start()
        end)

		if not s then
            warn(`Module {name} experienced error "{e}" while starting`)
        end
	end
end