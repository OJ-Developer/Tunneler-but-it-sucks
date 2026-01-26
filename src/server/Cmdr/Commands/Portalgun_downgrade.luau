return {
    Name = "portalgun_downgrade",
    Aliases = {},
    Description = "Downgrades your Eclipse Corporation Small-Length Teleportation-Hole Making Device, if you have one.",
    Group = "Tunneler but it sucks commands",
    Args = {},
    ClientRun = function()
        shared.PlayerState.GunUpgraded = false
        shared.PlayerState.GunChanged:Fire(true, false)
        return "Downgraded portal gun"
    end
}