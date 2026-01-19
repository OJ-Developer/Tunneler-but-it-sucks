local rs = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer

local playerScripts = player.PlayerScripts
local raycastUtils = require(playerScripts.Utils.RaycastUtils)

local module = {}
module.__index = module

function module.new(portalGunStand)
local gun = portalGunStand.Stand.Gun
	local hitbox = portalGunStand.Hitbox
	
	local t = task.spawn(function()
		while task.wait() do
			local partsInHitbox = workspace:GetPartsInPart(hitbox, raycastUtils.overlapParams("player"))
			
			if #partsInHitbox > 0 then
				player.PlayerScripts.Portal.GunUpgraded.Value = true
				player.PlayerScripts.Portal.HasGun.Value = true
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
