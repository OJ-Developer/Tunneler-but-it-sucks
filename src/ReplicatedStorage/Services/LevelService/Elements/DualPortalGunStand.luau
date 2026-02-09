local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(ReplicatedStorage.Modules.World)

local DualPortalGunStand = {}
DualPortalGunStand.__index = DualPortalGunStand

function DualPortalGunStand.new(portalGunStand)
	local self = setmetatable({}, DualPortalGunStand)

	self.Model = portalGunStand
	
	return self
end

function DualPortalGunStand:Init()
	local portalGunStand = self.Model

	local gun = portalGunStand.Stand.Gun
	local hitbox = portalGunStand.Hitbox
	
	self.t = task.spawn(function()
		while task.wait() do
			local partsInHitbox = workspace:GetPartsInPart(hitbox, World.overlapParams(World.ParamPreset.Player))
			
			if #partsInHitbox > 0 then
				shared.PlayerState.GunUpgraded = true
				shared.PlayerState.HasGun = true
				shared.PlayerState.GunChanged:Fire(true, true)
				gun.Transparency = 1
				return
			end
		end
	end)
end

function DualPortalGunStand:Cleanup()
	task.cancel(self.t)
end

return DualPortalGunStand
