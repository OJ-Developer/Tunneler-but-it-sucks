local module = {}

local connections: {RBXScriptConnection} = {}

function module.Start(player: Player)
	
	-- SETUP

	local rs = game:GetService("ReplicatedStorage")

	local events = rs:WaitForChild("Events")
	local loadLevelEvent = events:WaitForChild("Levels"):WaitForChild("LoadLevel")

	local axis = require(player.PlayerScripts.Services.Axis)
	local announcer = require(script.Parent.Parent.Parent.Parent.Services.Announcer)

	local tweenService = game:GetService("TweenService")

	local activationDetectors = workspace.Map.CustomFunctionality.ActivationDetectors
	local portalGunStandSpinButton = activationDetectors:WaitForChild("PortalGunStandSpinButton")

	local player = game.Players.LocalPlayer


	-- MUSIC

	local events = game:GetService("ReplicatedStorage"):WaitForChild("Events")
	local playSongEvent = events:WaitForChild("Audio"):WaitForChild("PlaySong")
	playSongEvent:Fire("0")



	-- PORTAL GUN STAND

	local portalPlacer1 = workspace.Map.CustomFunctionality.CustomActivators.PortalPlacer1
	local portalPlacer2 = workspace.Map.CustomFunctionality.CustomActivators.PortalPlacer2

	local portalGunStand = workspace.Map.CustomFunctionality.Other.PortalGunStand

	local portalGunCurrentlyAt = 2

	local function spinPortalGunStand(val)
		if val then
			if portalGunCurrentlyAt == 1 then
				local tween = tweenService:Create(portalGunStand.Value.Stand.Gun, TweenInfo.new(5, Enum.EasingStyle.Linear), {CFrame = portalGunStand.Value.Stand.Pos2.WorldCFrame})
				tween:Play()
				wait(5)
				portalPlacer2.Activated.Value = true
				portalPlacer1.Activated.Value = false
				portalGunCurrentlyAt = 2
			elseif portalGunCurrentlyAt == 2 then
				local tween = tweenService:Create(portalGunStand.Value.Stand.Gun, TweenInfo.new(5, Enum.EasingStyle.Linear), {CFrame = portalGunStand.Value.Stand.Pos1.WorldCFrame})
				tween:Play()
				wait(5)
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
				announcer.playVoiceline("wtl1")
			end)
			task.spawn(function()
				axis.PlayPath(path)
			end)
		end
	end))

	table.insert(connections, activationDetectors:WaitForChild("Room2EntranceHitbox").Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				axis.PlayVoiceline("AnotherTestDone")
			end)
			task.spawn(function()
				axis.PlayPath(path, path.C)
			end)
		end
	end))

	local ethmdIntroThread = nil

	table.insert(connections, activationDetectors:WaitForChild("Room3EntranceHitbox").Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				events.Game.StandingButtonClick:Fire(portalGunStandSpinButton.Value.Button)
				axis.PlayPath(path, path.F)
			end)
			ethmdIntroThread = task.spawn(function()
				task.wait(5)
				axis.PlayVoiceline("EclipseHoleMakingDevice")
				axis.PlayVoiceline("DeviceSafety")
			end)
		end
	end))

	local ruleVoicelineThread = nil

	table.insert(connections, player.PlayerScripts.Portal.HasGun.Changed:Connect(function(val)
		if val then
			playSongEvent:Fire("Small-Length_Experiment")
			
			if ethmdIntroThread then
				task.cancel(ethmdIntroThread)
			end
			task.spawn(function()
				axis.PlayPath(path, path.H)
			end)
			ruleVoicelineThread = task.spawn(function()
				axis.PlayVoiceline("SafetyGuildlines")
				axis.PlayVoiceline("Rule1")
				axis.PlayVoiceline("Rule2")
				axis.PlayVoiceline("Rule3")
				axis.PlayVoiceline("Rule4")
				axis.PlayVoiceline("Rule5")
				axis.PlayVoiceline("Rule6")
				axis.PlayVoiceline("Rule7")
				axis.PlayVoiceline("Rule8")
				axis.PlayVoiceline("Rule9")
				axis.PlayVoiceline("Rule10")
				axis.PlayVoiceline("Rule10Extra")
				axis.PlayVoiceline("Rule11Wait")
				axis.PlayVoiceline("Sorry")
				task.wait(60)
				axis.PlayVoiceline("Rule11")
			end)
		end
	end))

	table.insert(connections, activationDetectors:WaitForChild("Room4EntranceHitbox").Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				axis.PlayPath(path, path.J)
			end)
		end
	end))

	table.insert(connections, activationDetectors:WaitForChild("LevelEndHitbox").Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				if ruleVoicelineThread then
					task.cancel(ruleVoicelineThread)
				end
				
				loadLevelEvent:Fire("Level02")
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