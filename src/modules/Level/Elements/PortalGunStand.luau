local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RaycastUtils = require(ReplicatedStorage.Modules.Utils.RaycastUtils)

local module = {}
module.__index = module

function module.new(portalGunStand)
	local gun = portalGunStand.Stand.Gun
	local hitbox = portalGunStand.Hitbox

	local t = task.spawn(function()
		while task.wait() do
			local partsInHitbox = workspace:GetPartsInPart(hitbox, RaycastUtils.overlapParams(RaycastUtils.FdiPresets.Player))

			if #partsInHitbox > 0 then
				shared.PlayerState.HasGun = true
				shared.PlayerState.GunChanged:Fire(true, false)
				gun.Transparency = 1
				return
			end
		end
	end)
	
	return setmetatable({t=t}, module)
end

function module:Cleanup()
	task.cancel(self.t)
end

return module
