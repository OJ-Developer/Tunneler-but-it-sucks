local CollectionService = game:GetService("CollectionService")
return {
    Name = "toggletriggers",
    Aliases = {},
    Description = "Toggles the visibility of all the usually invisible hitboxes and triggers.",
    Group = "Tunneler but it sucks commands",
    Args = {},
    ClientRun = function()
        shared.Misc.HitboxVisibility = not shared.Misc.HitboxVisibility

        for _, hitbox in CollectionService:GetTagged("hitboxVisibility") do
            hitbox.Transparency = shared.Misc.HitboxVisibility and 0.5 or 1
        end

        return "Triggers and hitboxes are now " .. (shared.Misc.HitboxVisibility and "Visible" or "Invisible")
    end
}