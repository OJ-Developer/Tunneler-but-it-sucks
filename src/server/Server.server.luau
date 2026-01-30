local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

PhysicsService:RegisterCollisionGroup("InBluePortal")
PhysicsService:RegisterCollisionGroup("InRedPortal")
PhysicsService:RegisterCollisionGroup("InBothPortals")
PhysicsService:RegisterCollisionGroup("BehindBluePortal")
PhysicsService:RegisterCollisionGroup("BehindRedPortal")
PhysicsService:RegisterCollisionGroup("BehindBothPortals")
PhysicsService:CollisionGroupSetCollidable("InBluePortal", "BehindBluePortal", false)
PhysicsService:CollisionGroupSetCollidable("InBluePortal", "BehindBothPortals", false)
PhysicsService:CollisionGroupSetCollidable("InRedPortal", "BehindRedPortal", false)
PhysicsService:CollisionGroupSetCollidable("InRedPortal", "BehindBothPortals", false)
PhysicsService:CollisionGroupSetCollidable("InBothPortals", "BehindBluePortal", false)
PhysicsService:CollisionGroupSetCollidable("InBothPortals", "BehindRedPortal", false)
PhysicsService:CollisionGroupSetCollidable("InBothPortals", "BehindBothPortals", false)

local events = ReplicatedStorage.Events

events.UpdateCharAnchored.OnServerEvent:Connect(function(plr, val)
	plr.Character.HumanoidRootPart.Anchored = val
end)

events.TeleportPlayer.OnServerEvent:Connect(function(plr, placeid)
	TeleportService:TeleportAsync(placeid, {plr})
end)