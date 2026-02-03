local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

Cmdr:SetActivationKeys({ReplicatedStorage.Inputs.DevConsole.Keyboard.KeyCode})
ReplicatedStorage.Inputs.DevConsole.Keyboard.Changed:Connect(function(property)
    if property == "KeyCode" then
        Cmdr:SetActivationKeys({ReplicatedStorage.Inputs.DevConsole.Keyboard.KeyCode})
    end
end)

ReplicatedStorage.Events.UpdateDevConsoleEnabled.Event:Connect(function(v)
    Cmdr:SetEnabled(v)
end)

