return function(registry)
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local objects = {}
    for _, object in ReplicatedStorage.Objects:GetChildren() do
        table.insert(objects, object.Name)
    end

	registry:RegisterType("object", registry.Cmdr.Util.MakeEnumType("Object", objects))
end