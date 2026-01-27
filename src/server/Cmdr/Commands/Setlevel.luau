return {
    Name = "setlevel",
    Aliases = {},
    Description = "Loads the specified level.",
    Group = "Tunneler but it sucks commands",
    Args = {
        {
            Type = "level",
            Name = "Level Name",
            Description = "The level to load"
        }
    },
    ClientRun = function(_, level)
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local LevelService = require(ReplicatedStorage.Services.LevelService)
        local success = LevelService.LoadLevel(level)
        return success and `Successfully loaded level "{level}"` or `Level "{level}" does not exist`
    end
}