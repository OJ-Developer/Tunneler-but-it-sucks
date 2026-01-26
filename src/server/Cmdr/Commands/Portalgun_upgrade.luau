return {
    Name = "portalgun_upgrade",
    Aliases = {},
    Description = "Upgrades your Eclipse Corporation Small-Length Teleportation-Hole Making Device, if you have one.",
    Group = "Tunneler but it sucks commands",
    Args = {},
    ClientRun = function()
        shared.PlayerState.GunUpgraded = true
        shared.PlayerState.GunChanged:Fire(true, true)
        return "Upgraded portal gun"
    end
}