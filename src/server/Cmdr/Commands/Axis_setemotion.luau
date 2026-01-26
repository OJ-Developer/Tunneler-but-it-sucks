return {
    Name = "axis_setemotion",
    Aliases = {},
    Description = "Sets Axis's current emotion.",
    Group = "Tunneler but it sucks commands",
    Args = {
        {
            Type = "axisemotion",
            Name = "Emotion",
            Description = "The emotion for axis"
        }
    },
    ClientRun = function(_, emotion)
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Axis = require(ReplicatedStorage.Modules.Services.Axis)

        local success = Axis.SetEmotion(emotion)

        return success and `Set Axis's emotion to "{emotion}"` or `Axis emotion "{emotion}" does not exist`
    end
}