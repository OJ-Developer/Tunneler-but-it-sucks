local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cmdr = require(ReplicatedStorage.Packages.Cmdr)

Cmdr:RegisterDefaultCommands({"Help", "DefaultUtil"})
Cmdr:RegisterCommandsIn(script.Parent.Commands)
Cmdr:RegisterHooksIn(script.Parent.Hooks)
Cmdr:RegisterTypesIn(script.Parent.Types)