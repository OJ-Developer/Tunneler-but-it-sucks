local rs = game:GetService("ReplicatedStorage")

local portals = rs:WaitForChild("Portals")
local bluePortal = portals:WaitForChild("BluePortal"):Clone()
bluePortal.Parent = workspace
local redPortal = portals:WaitForChild("RedPortal"):Clone()
redPortal.Parent = workspace