return {
    Name = "confignumber",
    Aliases = {},
    Description = "Change a setting that is a number",
    Group = "Tunneler but it sucks commands",
    Args = {
        {
            Type = "numbersetting",
            Name = "setting",
            Description = "the setting to change"
        },
        {
            Type = "number",
            Name = "number",
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