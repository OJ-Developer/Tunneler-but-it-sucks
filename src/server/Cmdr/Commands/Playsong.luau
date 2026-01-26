return {
    Name = "playsong",
    Aliases = {},
    Description = "Plays the specified song. If another song is playing, it will be stopped.",
    Group = "Tunneler but it sucks commands",
    Args = {
        {
            Type = "song",
            Name = "Song Name",
            Description = "The song to play"
        }
    },
    ClientRun = function(_, song)
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local AudioService = require(ReplicatedStorage.Modules.Services.AudioService)
        local Sounds = require(ReplicatedStorage.Modules.Data.Sounds)
        local songData = Sounds.Music[song]
        if songData then
            AudioService.PlaySong(songData)
            return `Now playing song: "{song}"`
        else
            return `Song "{song}" does not exist`
        end 
    end
}