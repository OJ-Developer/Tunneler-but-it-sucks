return function(registry)
    registry:RegisterType("boolsetting", registry.Cmdr.Util.MakeEnumType("boolsetting", {
        "portalPlacementDebug"
    }))
end
