return {
    Name = "announcer_playvoiceline",
    Aliases = {},
    Description = "Makes the announcer play the specified voiceline.",
    Group = "Tunneler but it sucks commands",
    Args = {
        {
            Type = "announcervoiceline",
            Name = "Voiceline Name",
            Description = "The voiceline for the announcer to play"
        }
    },
    ClientRun = function(_, voicelineName)
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Announcer = require(ReplicatedStorage.Services.Announcer)

        local success = Announcer.PlayVoiceline(voicelineName)

        return success and `Played announcer voiceline "{voicelineName}"` or `Announcer voiceline "{voicelineName}" does not exist`
    end
}