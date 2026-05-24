local ReplicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local Utils = require(ReplicatedStorage.Modules.Utils)
local LinkedData = require(ReplicatedStorage.Services.LinkedData)

local energyProjectile = {}
energyProjectile.__index = energyProjectile

local projectileSpeed = 17

function energyProjectile.new(projectile, startDir, sender)
	local self = setmetatable({}, energyProjectile)

	projectile.AssemblyLinearVelocity = startDir * projectileSpeed

	local parentClass = LinkedData.Get(projectile, "ObjectClass")

	if sender then
		self.OnFizzleConnection = parentClass.OnFizzle:Connect(function()
			sender.Active = false
		end)
	end

	task.spawn(function()
		self.renderStepConnection = runService.RenderStepped:Connect(function(dtime)
			local oParams = OverlapParams.new()
			oParams.FilterType = Enum.RaycastFilterType.Include
			local filteredElements = workspace.Map.Elements:QueryDescendants(">:not([$ElementType = ProjectileSender],[$ElementType = TouchTrigger])")
			oParams.FilterDescendantsInstances = {
				filteredElements,
				workspace.Map.Building:GetDescendants(),
				game.Players.LocalPlayer.Character
			}
			local overlappingParts = workspace:GetPartsInPart(projectile, oParams)
			
			for _, part in overlappingParts do
				if part.Parent == workspace.Map.Elements and part:GetAttribute("ElementType") == "ProjectileReceiver" then
					projectile:Destroy()

					LinkedData.Get(part, "ElementClass"):Activate()
					self.renderStepConnection:Disconnect()
					if sender then
						sender.Finished = true
					end
					return
				elseif part:GetAttribute("Bounce") and part.Parent == workspace.Map.Building then
					local rParams = RaycastParams.new()
					rParams.FilterType = Enum.RaycastFilterType.Include
					rParams.FilterDescendantsInstances = workspace.Map.Building:QueryDescendants("[$Bounce = true]")
					local raycast = workspace:Raycast(projectile.Position, projectile.AssemblyLinearVelocity, rParams)
					if raycast then
						projectile.AssemblyLinearVelocity = Utils.mirrorVector(projectile.AssemblyLinearVelocity, raycast.Normal)
					end
				else
					if projectile:GetAttribute("InBluePortal") or projectile:GetAttribute("InRedPortal") then break end
					projectile:Destroy()
					self:Cleanup()

					self.renderStepConnection:Disconnect()
					if sender then
						sender.Active = false
					end
					return
				end
			end

			projectile.Position += projectile.AssemblyLinearVelocity * dtime
		end)
	end)

	return self
end

function energyProjectile:Cleanup()
	if self.renderStepConnection then
		self.renderStepConnection:Disconnect()
	end
	if self.OnFizzleConnection then
		self.OnFizzleConnection:Disconnect()
	end
end

return energyProjectile
