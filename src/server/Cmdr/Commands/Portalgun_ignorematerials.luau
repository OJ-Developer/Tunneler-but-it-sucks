return {
    Name = "portalgun_ignorematerials",
    Aliases = {},
    Description = "Allows Eclipse Corporation Small-Length Teleportation-Hole Making Device to shoot portals in places where you wouldn't be able to normally.",
    Group = "Tunneler but it sucks commands",
    Args = {
        {
            Type = "boolean",
            Name = "Enabled",
            Description = "Whether this setting should be enabled or not"
        }
    },
    ClientRun = function(_, val)
        shared.PlayerState.GunIgnoreMaterials = val
        return (val and "Enabled" or "Disabled") .. " portalgun_ignorematerials"
    end
}