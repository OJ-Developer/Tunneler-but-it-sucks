return {
    -- level
    StartLevel = "MainMenu",

    -- objects
    ObjectHoldDist = 9,
    ObjectMaxGrabDist = 9,

    -- portal
    MinimumPlayerPortalVelocity = 30,
    PortalgunSpinAmount = math.rad(120),
    PortalgunSpinTime = 0.3,
    PortalBumpMaxSteps = 10,

    -- debug
    MakeTheModuleLoaderSHUTUP = nil, -- if value is nil, it will be automatically enabled or not depending on if the game is running in normally or in studio
    SafeLoad = false,
    portalPlacementDebug = false
}