return function(registry)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Voicelines = require(ReplicatedStorage.Modules.Data.Voicelines).Announcer
    local voicelines = {}
    for voicelineName in Voicelines do
        table.insert(voicelines, voicelineName)
    end

    registry:RegisterType("announcervoiceline", registry.Cmdr.Util.MakeEnumType("Announcervoiceline", voicelines))
end