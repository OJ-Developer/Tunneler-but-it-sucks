return function(registry)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local levels = {}
    for _, level in ReplicatedStorage.Levels:GetChildren() do
        table.insert(levels, level.Name)
    end

    registry:RegisterType("level", registry.Cmdr.Util.MakeEnumType("Level", levels))
end
