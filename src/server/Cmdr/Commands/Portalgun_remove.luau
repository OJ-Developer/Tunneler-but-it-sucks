return {
    Name = "portalgun_remove",
    Aliases = {},
    Description = "Takes away your Eclipse Corporation Small-Length Teleportation-Hole Making Device.",
    Group = "Tunneler but it sucks commands",
    Args = {},
    ClientRun = function()
        shared.PlayerState.HasGun = false
        shared.PlayerState.GunChanged:Fire(false, false)
        return "Removed portal gun"
    end
}