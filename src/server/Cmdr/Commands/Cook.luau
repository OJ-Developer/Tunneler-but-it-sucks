return {
    Name = "WhatisBROcooking?(youCANTbelieveit)",
    Aliases = {"cook"},
    Description = "What is BRO cooking? (you CANT believe it)",
    Group = "Tunneler but it sucks commands",
    Args = {
        {
            Type = "number",
            Name = "amount",
            Description = "amount of What is BRO cooking? (you CANT believe it)"
        }
    },

    Data = function()
        return workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.lookVector * 10
    end,

    ClientRun = function(context, amount)
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        local Object = require(ReplicatedStorage.Classes.Object)
        local LinkedData = require(ReplicatedStorage.Services.LinkedData)

        for _ = 1, amount do
            local part = Instance.new("Part")
            part.Size = Vector3.new(2,2,2)
            for _, normal in Enum.NormalId:GetEnumItems() do
                local decal = Instance.new("Decal")
                decal.ColorMap = "rbxassetid://95122524380471"
                decal.Face = normal
                decal.Parent = part
            end
            part.Position = context:GetData()
            LinkedData.Set(part, "ObjectClass", Object.giveFunctionality(part))
            part.Parent = workspace.Map.Objects
        end
        return `Created {amount} new What is BRO cooking? (you CAN now believe it)s`
    end
}