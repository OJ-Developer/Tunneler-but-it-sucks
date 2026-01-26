return {
    Name = "spawnobject",
    Aliases = {},
    Description = "Spawns the specified object infront of you.",
    Group = "Tunneler but it sucks commands",
    Args = {
        {
            Type = "object",
            Name = "Object Name",
            Description = "The name of the specified object."
        }
    },
    ClientRun = function(_, objectName)
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Object = require(ReplicatedStorage.Modules.Classes.Object)
        local camera = workspace.CurrentCamera
        local newObject = Object.new(objectName, camera.CFrame + camera.CFrame.lookVector * 10, camera.CFrame.lookVector)
        return newObject and `Created new "{objectName}" object` or `"{objectName}" is not a valid type of object`
    end
}