local rs = game:GetService("ReplicatedStorage")
local tps = game:GetService("TeleportService")

local events = rs.Events

events.Other.UpdateCharAnchored.OnServerEvent:Connect(function(plr, val)
	plr.Character.HumanoidRootPart.Anchored = val
end)

events.Other.TeleportPlayer.OnServerEvent:Connect(function(plr, placeid)
	tps:TeleportAsync(placeid, {plr})
end)