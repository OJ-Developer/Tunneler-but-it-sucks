return function(registry)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local AxisTextures = require(ReplicatedStorage.Data.AxisTextures)
    local emotions = {}
    for emotion in AxisTextures do
        table.insert(emotions, emotion)
    end

    registry:RegisterType("axisemotion", registry.Cmdr.Util.MakeEnumType("Axisemotion", emotions))
end
