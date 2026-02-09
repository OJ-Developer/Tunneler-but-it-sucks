local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LinkedData = require(ReplicatedStorage.Services.LinkedData)
local PortalService = require(ReplicatedStorage.Services.PortalService)

local PortalPlacer = {}
PortalPlacer.__index = PortalPlacer

function PortalPlacer.new(portalPlacer)
	local self = setmetatable({}, PortalPlacer)

	self.Model = portalPlacer
	self.Configuration = portalPlacer.Configuration
	
	self.PortalPlacePlace = portalPlacer.PortalPlacePlace.WorldCFrame

	self.OnPart = portalPlacer.Configuration.OnPart.Value
	self.PortalColour = portalPlacer.Configuration.Portal.Value
	self.Portal = workspace[self.PortalColour.."Portal"]

	return self
end

function PortalPlacer:Init()
	local portalPlacer = self.Model

	local activatorObject = portalPlacer.Configuration.Activator
	local activator
	if activatorObject.Value then
		activator = LinkedData.Get(activatorObject.Value, "ElementClass")
	end
	
	if activator then
		self.c = activator.OnActivated:Connect(function(activated)
			self:SetActivated(activated)
		end)
	end
end

function PortalPlacer:SetActivated(activated)
	if activated then
		PortalService.PlacePortal(self.Portal, self.PortalColour == "Red", self.OnPart, true, self.PortalPlacePlace.WorldCFrame)
	end
end

function PortalPlacer:Cleanup()
	if self.c then
		self.c:Disconnect()
	end
end

return PortalPlacer
