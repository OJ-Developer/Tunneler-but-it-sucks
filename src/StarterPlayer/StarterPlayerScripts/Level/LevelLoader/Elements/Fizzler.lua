local rs = game:GetService("ReplicatedStorage")

local events = rs.Events
local placePortal = events.Portal.PlacePortal

local playerScripts = game.Players.LocalPlayer.PlayerScripts
local object = require(playerScripts.Classes.Object)
local raycastUtils = require(playerScripts.Utils.RaycastUtils)

local module = {}
module.__index = module

function module.new(fizzler)
	local particleEmitter = fizzler:WaitForChild("ParticleEmitter")

	local activator = fizzler:WaitForChild("Configuration"):WaitForChild("Activator")
	local connected = activator ~= nil
	local startEnabled = fizzler.Configuration:WaitForChild("StartEnabled")

	local enabled = fizzler:WaitForChild("Enabled")

	local prevActivated
	if connected then
		prevActivated = activator.Value:WaitForChild("Activated").Value
	end

	if startEnabled.Value then
		fizzler.Transparency = 0.5
		particleEmitter.Enabled = true
	else
		fizzler.Transparency = 1
		particleEmitter.Enabled = false
	end

	local starting = true

	local t = task.spawn(function()
		while task.wait() do
			if connected and (activator.Value.Activated.Value ~= prevActivated) or starting then
				enabled.Value = activator.Value.Activated.Value ~= startEnabled.Value
				if enabled.Value then
					fizzler.Transparency = 0.5
					particleEmitter.Enabled = true
				else
					fizzler.Transparency = 1
					particleEmitter.Enabled = false
				end
			end

			prevActivated = activator.Value.Activated.Value
			if enabled.Value then
				local partsInFizzler = workspace:GetPartsInPart(fizzler)

				for _, part in pairs(partsInFizzler) do
					if part.Parent == workspace.Map.Objects then
						object.drop()
						object.fizzle(part)
					end
					if part.Parent == game.Players.LocalPlayer.Character then
						if workspace.BluePortal.Fizzleable.Value then
							placePortal:Fire(workspace.BluePortal, false, nil, true, CFrame.new(Vector3.new(0,-20,20)))
						end
						if workspace.RedPortal.Fizzleable.Value then
							placePortal:Fire(workspace.RedPortal, true, nil, true, CFrame.new(Vector3.new(0,-20,20)))
						end
					end
				end
			end
			starting = false
		end
	end)
	
	return setmetatable({t=t}, module)
end

function module:Cleanup()
	task.cancel(self.t)
end

return module
