return function(registry)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Sounds = require(ReplicatedStorage.Modules.Data.Sounds)
    local songNames = {}
    for songName in Sounds.Music do
        table.insert(songNames, songName)
    end

    registry:RegisterType("song", registry.Cmdr.Util.MakeEnumType("Song", songNames))
end
