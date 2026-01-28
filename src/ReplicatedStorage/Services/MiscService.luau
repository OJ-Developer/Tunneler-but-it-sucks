local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player.PlayerGui

local Misc = {}

function Misc.Init()
    shared.Misc = {}

    -- Hitbox visibility stuff
    shared.Misc.HitboxVisility = false

    for _, hitbox in CollectionService:GetTagged("hitboxVisibility") do
        hitbox.Transparency = 1
    end

    -- unlock mouse in devconsole
    local unlockMouse = Instance.new("TextButton")
    unlockMouse.Text = ""
    local cmdrFrame = playerGui:WaitForChild("Cmdr"):WaitForChild("Frame")
    unlockMouse.Parent = cmdrFrame
    cmdrFrame.Changed:Connect(function(property)
        if property == "Visible" then
            unlockMouse.Modal = cmdrFrame.Visible
        end
    end)
end

return Misc