local ReplicatedStorage = game:GetService("ReplicatedStorage")

shared.PlayerState = {}
shared.GameState = {}
shared.Settings = {}

local serviceModules = ReplicatedStorage.Modules.Services
local services = {}

task.wait(1)

for _, moduleScript in serviceModules:GetChildren() do
    print(`Loading module: "{moduleScript.Name}"`)

    local s, e = pcall(function()
        local module = require(moduleScript)    
        if module.Init then
            print(`Initializing module: "{moduleScript.Name}"`)
            module.Init()
            print(`Successfully initialized module: "{moduleScript.Name}"`)
        end
        services[moduleScript.Name] = module
    end)

    if not s then
        warn(`Module {moduleScript.Name} experienced error "{e}" while initializing`)
    end
end

for name, service in services do
    local s, e = pcall(function()
        if service.Start then
            print(`Starting module: "{name}"`)
            service.Start()
            print(`Successfully started module: "{name}"`)
        end
    end)

    if not s then
        warn(`Module {name} experienced error "{e}"`)
    end
end