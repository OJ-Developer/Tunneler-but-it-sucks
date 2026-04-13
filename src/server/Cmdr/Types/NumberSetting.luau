return function(registry)
    registry:RegisterType("numbersetting", registry.Cmdr.Util.MakeEnumType("numbersetting", {
        "ObjectHoldDist",
        "ObjectMaxGrabDist",
        "MinimumPlayerPortalVelocity",
        "PortalgunSpinAmount",
        "PortalgunSpinTime",
        "PortalBumpMaxSteps"
    }))
end
