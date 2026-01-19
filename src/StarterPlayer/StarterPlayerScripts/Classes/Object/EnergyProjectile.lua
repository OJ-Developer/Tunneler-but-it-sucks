local runService = game:GetService("RunService")

local instanceUtils = require(script.Parent.Parent.Parent.Utils.InstanceUtils)
local vectorUtils = require(script.Parent.Parent.Parent.Utils.VectorUtils)

local energyProjectile = {}
energyProjectile.__index = energyProjectile

local projectileSpeed = 17

function energyProjectile.new(projectile, startDir)
	local newEnergyProjectile = setmetatable({}, energyProjectile)

	projectile.AssemblyLinearVelocity = startDir * projectileSpeed

	task.spawn(function()
		newEnergyProjectile.renderStepConnection = runService.RenderStepped:Connect(function(dtime)
			local oParams = OverlapParams.new()
			oParams.FilterType = Enum.RaycastFilterType.Include
			local elements = workspace.Map.Elements:GetChildren()
			local filteredElements = {}
			for _, element in elements do
				if element.Name == "ProjectileSender" or element.Name == "Hitbox" then continue end
				table.insert(filteredElements, element)
			end
			oParams.FilterDescendantsInstances = {
				filteredElements,
				workspace.Map.Building:GetDescendants(),
				game.Players.LocalPlayer.Character
			}
			local overlappingParts = workspace:GetPartsInPart(projectile, oParams)

			for _, part in overlappingParts do
				if part.Parent == workspace.Map.Elements and part.Name == "ProjectileReceiver" then
					projectile:Destroy()

					part.Activated.Value = true
					newEnergyProjectile.renderStepConnection:Disconnect()
					return
				elseif part:GetAttribute("Bounce") and part.Parent == workspace.Map.Building then
					local rParams = RaycastParams.new()
					rParams.FilterType = Enum.RaycastFilterType.Include
					rParams.FilterDescendantsInstances = instanceUtils.getInstancesWithAttribute(workspace.Map.Building:GetDescendants(), "Bounce", true)
					local raycast = workspace:Raycast(projectile.Position, projectile.AssemblyLinearVelocity, rParams)
					if raycast then
						projectile.AssemblyLinearVelocity = vectorUtils.mirrorVector(projectile.AssemblyLinearVelocity, raycast.Normal)
					end
				else
					if projectile:GetAttribute("InBluePortal") or projectile:GetAttribute("InRedPortal") then break end
					projectile:Destroy()
					newEnergyProjectile:Cleanup()

					newEnergyProjectile.renderStepConnection:Disconnect()
					return
				end
			end

			projectile.Position += projectile.AssemblyLinearVelocity * dtime
		end)
	end)

	return newEnergyProjectile
end

function energyProjectile:Cleanup()
	print("cleaning up energy projectile")
	if self.renderStepConnection then
		self.renderStepConnection:Disconnect()
	end
end

return energyProjectile
