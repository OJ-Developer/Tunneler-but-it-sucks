local rs = game:GetService("ReplicatedStorage")
local tps = game:GetService("TeleportService")

local events = rs.Events

events.UpdateCharAnchored.OnServerEvent:Connect(function(plr, val)
	plr.Character.HumanoidRootPart.Anchored = val
end)

events.TeleportPlayer.OnServerEvent:Connect(function(plr, placeid)
	tps:TeleportAsync(placeid, {plr})
end)