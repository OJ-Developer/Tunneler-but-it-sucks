local module = {}

local connections: {RBXScriptConnection} = {}

function module.Start(player: Player)
	
	-- SETUP

	local tweenService = game:GetService("TweenService")

	local rs = game:GetService("ReplicatedStorage")

	local events = rs.Events
	local loadLevelEvent = events.Levels.LoadLevel

	local char = player.Character
	local cam = workspace.CurrentCamera
	local cameraModule = require(player.PlayerScripts.CameraScript.CameraModule)
	
	local axis = require(player.PlayerScripts.Services.Axis)
	local announcer = require(script.Parent.Parent.Parent.Parent.Services.Announcer)
	local screenEffects = require(script.Parent.Parent.Parent.Parent.Services.ScreenEffects)
	


	-- MUSIC

	local playSongEvent = events.Audio.PlaySong
	playSongEvent:Fire("0")
	


	-- CUTSCENE

	local cutscenePoints = workspace.Map.Other.CutscenePoints
	char.HumanoidRootPart.CFrame = workspace.Map.SpawnLocation.CFrame + Vector3.new(0, 3, 0)
	char.HumanoidRootPart.Anchored = true
	screenEffects.setScreenColourOverlay(0)
	script.CutsceneSound:Play()
	wait(script.CutsceneSound.TimeLength)
	cameraModule.Stop()
	cam.CFrame = cutscenePoints.A.WorldCFrame
	screenEffects.FadeScreenColourOverlay(1, 0.5)
	local tween = tweenService:Create(cam, TweenInfo.new(0.5), {CFrame = cutscenePoints.B.WorldCFrame})
	tween:Play()
	wait(1)
	local tween = tweenService:Create(cam, TweenInfo.new(1), {CFrame = cutscenePoints.C.WorldCFrame})
	tween:Play()
	wait(2)
	local tween = tweenService:Create(cam, TweenInfo.new(1), {CFrame = cutscenePoints.D.WorldCFrame})
	tween:Play()
	wait(1)
	cameraModule.Start()
	char.HumanoidRootPart.Anchored = false
	wait(5)



	-- AXIS INTRO

	local path = workspace.Map.AxisPaths.Path1
	axis.PlayPath(path)
	axis.PlayVoiceline("ImAxis")
	axis.PlayVoiceline("IWatchU")
	axis.PlayVoiceline("TestingIsDangerous")
	axis.PlayVoiceline("TheTestingWillBegin")

	local otherRandomStuff = workspace.Map.CustomFunctionality.OtherRandomStuff
	local thingIdkWhatToCall = otherRandomStuff.ThingIdkWhatToCall.Value

	local tween = tweenService:Create(thingIdkWhatToCall, TweenInfo.new(5), {Position = thingIdkWhatToCall.Position + Vector3.new(0, 22, 0)})
	tween:Play()
	for _, part in pairs(thingIdkWhatToCall:GetChildren()) do
		if part:IsA("BasePart") then
			local tween = tweenService:Create(part, TweenInfo.new(5), {Position = part.Position + Vector3.new(0, 22, 0)})
			tween:Play()
		end
	end
	wait(5)

	workspace.Map.CustomFunctionality.StartPortalActivator.Activated.Value = true

	task.spawn(function()
		axis.PlayPath(path, path.B)
	end)



	-- OTHER AXIS STUFF

	local otherActivators = workspace.Map.CustomFunctionality.OtherActivators

	table.insert(connections, otherActivators.AxisMoveHitbox1.Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				axis.PlayPath(path, path.C)
			end)
		end
	end))

	table.insert(connections, otherActivators.Room1EnterHitbox.Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				workspace.RedPortal.OnPart.Value = nil
				announcer.playVoiceline("wtl0")
				task.wait(0.5)
				axis.PlayVoiceline("Level0")
			end)
		end
	end))

	table.insert(connections, otherActivators.AxisMoveHitbox2.Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				axis.PlayPath(path, path.F)
			end)
		end
	end))

	table.insert(connections, otherActivators.Level1LoadHitbox.Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				loadLevelEvent:Fire("Level01")
			end)
		end
	end))

	table.insert(connections, otherActivators.AxisVoiclineHitbox1.Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				axis.PlayVoiceline("TunnelsConfuzzled")
			end)
		end
	end))

	table.insert(connections, otherActivators.AxisVoiclineHitbox2.Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				axis.PlayVoiceline("Level0Yay")
			end)
		end
	end))

	table.insert(connections, otherActivators.AxisVoiclineHitbox3.Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				axis.PlayVoiceline("RestAreas")
			end)
		end
	end))

end

function module.Cleanup()
	for _, connection in connections do
		connection:Disconnect()
	end
end

return module
