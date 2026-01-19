local playerScripts = game.Players.LocalPlayer.PlayerScripts
local raycastUtils = require(playerScripts.Utils.RaycastUtils)

local module = {}
module.__index = module

function module.new(hitboxPart)
	local activated = hitboxPart:WaitForChild("Activated")

	local singleUse = hitboxPart:WaitForChild("Configuration"):WaitForChild("SingleUse")
	
	local t = task.spawn(function()
		while task.wait() do
			local partsInHitbox = workspace:GetPartsInPart(hitboxPart, raycastUtils.overlapParams("player"))

			activated.Value = #partsInHitbox > 0

			if activated.Value and singleUse.Value then
				break
			end
		end
	end)
	
	return setmetatable({t=t}, module)
end

function module:Cleanup()
	task.cancel(self.t)
end

return module
