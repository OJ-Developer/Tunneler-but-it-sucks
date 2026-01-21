local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Settings = require(ReplicatedStorage.Modules.Settings)

shared.PlayerState = {}
shared.GameState = {}
shared.Settings = {}

local serviceModules = ReplicatedStorage.Modules.Services
local services = {}

task.wait(1)

function printMaybe(...)
    if Settings.MakeTheModuleLoaderSHUTUP then return end
    print(...)
end

for _, moduleScript in serviceModules:GetChildren() do
    printMaybe(`Loading module: "{moduleScript.Name}"`)

    local s, e = pcall(function()
        local module = require(moduleScript)    
        if module.Init then
            printMaybe(`Initializing module: "{moduleScript.Name}"`)
            module.Init()
            printMaybe(`Successfully initialized module: "{moduleScript.Name}"`)
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
            printMaybe(`Starting module: "{name}"`)
            service.Start()
            printMaybe(`Successfully started module: "{name}"`)
        end
    end)

    if not s then
        warn(`Module {name} experienced error "{e}"`)
    end
end