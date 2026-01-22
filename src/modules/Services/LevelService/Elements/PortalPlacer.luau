local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PortalService = require(ReplicatedStorage.Modules.Services.PortalService)
local module = {}
module.__index = module

function module.new(portalPlacer)
	local portalPlacePlace = portalPlacer.PortalPlacePlace

	local activator = portalPlacer.Configuration.Activator
	if not activator.Value then return end
	local onPart = portalPlacer.Configuration.OnPart
	local portal = workspace:WaitForChild(portalPlacer.Configuration.Portal.Value.."Portal")

	local prevActivated = activator.Value.Activated.Value

	local t = task.spawn(function()
		while task.wait() do
			if activator.Value.Activated.Value ~= prevActivated then
				if activator.Value.Activated.Value then
					PortalService.PlacePortal(portal, portalPlacer.Configuration.Portal.Value == "Red", onPart.Value, true, portalPlacePlace.WorldCFrame)
				end
			end

			prevActivated = activator.Value.Activated.Value
		end
	end)
	
	return setmetatable({t=t}, module)
end

function module:Cleanup()
	if not self.t then return end
	task.cancel(self.t)
end

return module
