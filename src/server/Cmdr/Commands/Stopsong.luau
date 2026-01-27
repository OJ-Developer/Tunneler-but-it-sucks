return {
    Name = "stopsong",
    Aliases = {},
    Description = "If a song is playing, it will be stopped.",
    Group = "Tunneler but it sucks commands",
    Args = {},
    ClientRun = function(_, song)
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local AudioService = require(ReplicatedStorage.Services.AudioService)
        AudioService.StopSongs()
        return "Stopped playing song"
    end
}