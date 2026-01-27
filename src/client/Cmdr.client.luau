local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

Cmdr:SetActivationKeys({ReplicatedStorage.Inputs.DevConsole.Keyboard.KeyCode})
ReplicatedStorage.Inputs.DevConsole.Keyboard.Changed:Connect(function(property)
    if property == "KeyCode" then
        Cmdr:SetActivationKeys({ReplicatedStorage.Inputs.DevConsole.Keyboard.KeyCode})
    end
end)
