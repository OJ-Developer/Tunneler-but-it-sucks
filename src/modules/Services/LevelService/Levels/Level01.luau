local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Sounds = require(ReplicatedStorage.Modules.Data.Sounds)
local Announcer = require(ReplicatedStorage.Modules.Services.Announcer)
local AudioService = require(ReplicatedStorage.Modules.Services.AudioService)
local Axis = require(ReplicatedStorage.Modules.Services.Axis)
local LevelService = require(ReplicatedStorage.Modules.Services.LevelService)
local LinkedData = require(ReplicatedStorage.Modules.Services.LinkedData)

local module = {}

local connections = {}

function module.Start(player: Player)
	
	-- SETUP

	local activationDetectors = workspace.Map.CustomFunctionality.ActivationDetectors
	local portalGunStandSpinButton = activationDetectors:WaitForChild("PortalGunStandSpinButton")


	-- MUSIC

	AudioService.PlaySong(Sounds.Music["0"])



	-- PORTAL GUN STAND

	local portalPlacer1 = workspace.Map.CustomFunctionality.CustomActivators.PortalPlacer1
	local portalPlacer2 = workspace.Map.CustomFunctionality.CustomActivators.PortalPlacer2

	local portalGunStand = workspace.Map.CustomFunctionality.Other.PortalGunStand

	local portalGunCurrentlyAt = 2

	local function spinPortalGunStand(val)
		if val then
			if portalGunCurrentlyAt == 1 then
				local tween = TweenService:Create(portalGunStand.Value.Stand.Gun, TweenInfo.new(5, Enum.EasingStyle.Linear), {CFrame = portalGunStand.Value.Stand.Pos2.WorldCFrame})
				tween:Play()
				task.wait(5)
				portalPlacer2.Activated.Value = true
				portalPlacer1.Activated.Value = false
				portalGunCurrentlyAt = 2
			elseif portalGunCurrentlyAt == 2 then
				local tween = TweenService:Create(portalGunStand.Value.Stand.Gun, TweenInfo.new(5, Enum.EasingStyle.Linear), {CFrame = portalGunStand.Value.Stand.Pos1.WorldCFrame})
				tween:Play()
				task.wait(5)
				portalPlacer2.Activated.Value = false
				portalPlacer1.Activated.Value = true
				portalGunCurrentlyAt = 1
			end
		end
	end

	table.insert(connections, portalGunStandSpinButton.Value.Activated.Changed:Connect(spinPortalGunStand))


	-- OTHER HITBOX THINGS AND STUFF

	local path = workspace.Map.AxisPaths.Path1

	table.insert(connections, activationDetectors:WaitForChild("Room1EntranceHitbox").Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				Announcer.playVoiceline("wtl1")
			end)
			task.spawn(function()
				Axis.PlayPath(path)
			end)
		end
	end))

	table.insert(connections, activationDetectors:WaitForChild("Room2EntranceHitbox").Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				Axis.PlayVoiceline("AnotherTestDone")
			end)
			task.spawn(function()
				Axis.PlayPath(path, path.C)
			end)
		end
	end))

	local ethmdIntroThread = nil

	table.insert(connections, activationDetectors:WaitForChild("Room3EntranceHitbox").Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				LinkedData.Get(portalGunStandSpinButton.Value, "ElementClass"):Press()
				Axis.PlayPath(path, path.F)
			end)
			ethmdIntroThread = task.spawn(function()
				task.wait(5)
				Axis.PlayVoiceline("EclipseHoleMakingDevice")
				Axis.PlayVoiceline("DeviceSafety")
			end)
		end
	end))

	local ruleVoicelineThread = nil

	table.insert(connections, shared.PlayerState.GunChanged:Connect(function(val)
		if val then
			AudioService.PlaySong(Sounds.Music.SmallLengthExperiment)
			
			if ethmdIntroThread then
				task.cancel(ethmdIntroThread)
			end
			task.spawn(function()
				Axis.PlayPath(path, path.H)
			end)
			ruleVoicelineThread = task.spawn(function()
				Axis.PlayVoiceline("SafetyGuildlines")
				Axis.PlayVoiceline("Rule1")
				Axis.PlayVoiceline("Rule2")
				Axis.PlayVoiceline("Rule3")
				Axis.PlayVoiceline("Rule4")
				Axis.PlayVoiceline("Rule5")
				Axis.PlayVoiceline("Rule6")
				Axis.PlayVoiceline("Rule7")
				Axis.PlayVoiceline("Rule8")
				Axis.PlayVoiceline("Rule9")
				Axis.PlayVoiceline("Rule10")
				Axis.PlayVoiceline("Rule10Extra")
				Axis.PlayVoiceline("Rule11Wait")
				Axis.PlayVoiceline("Sorry")
				task.wait(60)
				Axis.PlayVoiceline("Rule11")
			end)
		end
	end))

	table.insert(connections, activationDetectors:WaitForChild("Room4EntranceHitbox").Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				Axis.PlayPath(path, path.J)
			end)
		end
	end))

	table.insert(connections, activationDetectors:WaitForChild("LevelEndHitbox").Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				if ruleVoicelineThread then
					task.cancel(ruleVoicelineThread)
				end
				
				LevelService.LoadLevel("Level02")
			end)
		end
	end))
	
end

function module.Cleanup()
	for _, v in connections do
		v:Disconnect()
	end
end

return module