return {
    Name = "axis_playvoiceline",
    Aliases = {},
    Description = "Makes axis play the specified voiceline.",
    Group = "Tunneler but it sucks commands",
    Args = {
        {
            Type = "axisvoiceline",
            Name = "Voiceline Name",
            Description = "The voiceline for axis to play"
        }
    },
    ClientRun = function(_, voicelineName)
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Axis = require(ReplicatedStorage.Modules.Services.Axis)

        local success = Axis.PlayVoiceline(voicelineName)

        return success and `Played axis voiceline "{voicelineName}"` or `Axis voiceline "{voicelineName}" does not exist`
    end
}