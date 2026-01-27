return function(registry)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Voicelines = require(ReplicatedStorage.Data.Voicelines).Axis
    local voicelines = {}
    for voicelineName in Voicelines do
        table.insert(voicelines, voicelineName)
    end

    registry:RegisterType("axisvoiceline", registry.Cmdr.Util.MakeEnumType("Axisvoiceline", voicelines))
end
