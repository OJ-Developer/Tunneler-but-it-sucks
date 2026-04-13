return {
    Name = "configbool",
    Aliases = {},
    Description = "Change a setting that is a boolean",
    Group = "Tunneler but it sucks commands",
    Args = {
        {
            Type = "boolsetting",
            Name = "setting",
            Description = "the setting to change"
        },
        {
            Type = "boolean",
            Name = "boolean",
            Description = "new setting value"
        }
    },

    ClientRun = function(context, setting, number)
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        local MainConfig = require(ReplicatedStorage.Configs.MainConfig)
        MainConfig[setting] = number
        
        return `set setting {setting} to {number}`
    end
}