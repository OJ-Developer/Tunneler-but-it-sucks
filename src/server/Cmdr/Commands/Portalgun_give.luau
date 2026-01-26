return {
    Name = "portalgun_give",
    Aliases = {},
    Description = "Gives you the Eclipse Corporation Small-Length Teleportation-Hole Making Device.",
    Group = "Tunneler but it sucks commands",
    Args = {},
    ClientRun = function()
        shared.PlayerState.HasGun = true
        shared.PlayerState.GunChanged:Fire(true, false)
        return "Gave portal gun"
    end
}