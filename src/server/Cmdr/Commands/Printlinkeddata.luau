return {
    Name = "printlinkeddata",
    Aliases = {},
    --Description = "",
    Group = "Devlocked",
    Args = {},
    ClientRun = function()
        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local LinkedData = require(ReplicatedStorage.Services.LinkedData)
        local player = Players.LocalPlayer
        local mouse: Mouse = player:GetMouse()
        local target = mouse.Target
        
        local found = false

        repeat
            if LinkedData.Get(target) then
                found = true
            else
                target = target.Parent
            end
        until found or target.Parent == workspace

        if found then
            print(LinkedData.Get(target))
            return "printed linkeddata"
        else
            return "could not find linkeddata"
        end
    end
}