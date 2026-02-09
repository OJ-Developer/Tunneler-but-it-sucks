local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(ReplicatedStorage.Modules.World)

local PortalGunStand = {}
PortalGunStand.__index = PortalGunStand

function PortalGunStand.new(portalGunStand)
	local self = setmetatable({}, PortalGunStand)

	self.Model = portalGunStand
	
	return self
end

function PortalGunStand:Init()
	local portalGunStand = self.Model

	local gun = portalGunStand.Stand.Gun
	local hitbox = portalGunStand.Hitbox
	
	self.t = task.spawn(function()
		while task.wait() do
			local partsInHitbox = workspace:GetPartsInPart(hitbox, World.overlapParams(World.ParamPreset.Player))
			
			if #partsInHitbox > 0 then
				shared.PlayerState.HasGun = true
				shared.PlayerState.GunChanged:Fire(true, true)
				gun.Transparency = 1
				return
			end
		end
	end)
end

function PortalGunStand:Cleanup()
	task.cancel(self.t)
end

return PortalGunStand
