local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LevelService = require(script.Parent.Parent)
local Sounds = require(ReplicatedStorage.Data.Sounds)
local Announcer = require(ReplicatedStorage.Services.Announcer)
local AudioService = require(ReplicatedStorage.Services.AudioService)
local Axis = require(ReplicatedStorage.Services.Axis)
local CameraService = require(ReplicatedStorage.Services.CameraService)
local UiService = require(ReplicatedStorage.Services.UiService)

local module = {}

local connections: {RBXScriptConnection} = {}

function module.Start(player: Player)
	
	-- SETUP

	local char = player.Character
	local cam = workspace.CurrentCamera

	-- MUSIC

	AudioService.PlaySong(Sounds.Music["0"])
	


	-- CUTSCENE

	local cutscenePoints = workspace.Map.Other.CutscenePoints
	char.HumanoidRootPart.CFrame = workspace.Map.SpawnLocation.CFrame + Vector3.new(0, 3, 0)
	char.HumanoidRootPart.Anchored = true
	UiService.ScreenEffects.setScreenColourOverlay({Transparency = 0})
	AudioService.PlaySoundEffectAndWait(Sounds.SoundEffects.PlaceHolder)
	CameraService.Disable()
	cam.CFrame = cutscenePoints.A.WorldCFrame
	UiService.ScreenEffects.FadeScreenColourOverlay(0.5, {Transparency = 1})
	local tween = TweenService:Create(cam, TweenInfo.new(0.5), {CFrame = cutscenePoints.B.WorldCFrame})
	tween:Play()
	task.wait(1)
	tween = TweenService:Create(cam, TweenInfo.new(1), {CFrame = cutscenePoints.C.WorldCFrame})
	tween:Play()
	task.wait(2)
	tween = TweenService:Create(cam, TweenInfo.new(1), {CFrame = cutscenePoints.D.WorldCFrame})
	tween:Play()
	task.wait(1)
	CameraService.Enable()
	char.HumanoidRootPart.Anchored = false
	task.wait(5)



	-- AXIS INTRO

	local path = workspace.Map.AxisPaths.Path1
	Axis.PlayPath(path)
	Axis.PlayVoiceline("ImAxis")
	Axis.PlayVoiceline("IWatchU")
	Axis.PlayVoiceline("TestingIsDangerous")
	Axis.PlayVoiceline("TheTestingWillBegin")

	local otherRandomStuff = workspace.Map.CustomFunctionality.OtherRandomStuff
	local thingIdkWhatToCall = otherRandomStuff.ThingIdkWhatToCall.Value

	tween = TweenService:Create(thingIdkWhatToCall, TweenInfo.new(5), {Position = thingIdkWhatToCall.Position + Vector3.new(0, 22, 0)})
	tween:Play()
	for _, part in pairs(thingIdkWhatToCall:GetChildren()) do
		if part:IsA("BasePart") then
			tween = TweenService:Create(part, TweenInfo.new(5), {Position = part.Position + Vector3.new(0, 22, 0)})
			tween:Play()
		end
	end
	task.wait(5)

	workspace.Map.CustomFunctionality.StartPortalActivator.Activated.Value = true

	task.spawn(function()
		Axis.PlayPath(path, path.B)
	end)



	-- OTHER AXIS STUFF

	local otherActivators = workspace.Map.CustomFunctionality.OtherActivators

	table.insert(connections, otherActivators.AxisMoveHitbox1.Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				Axis.PlayPath(path, path.C)
			end)
		end
	end))

	table.insert(connections, otherActivators.Room1EnterHitbox.Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				workspace.RedPortal.OnPart.Value = nil
				Announcer.PlayVoiceline("wtl0")
				task.wait(0.5)
				Axis.PlayVoiceline("Level0")
			end)
		end
	end))

	table.insert(connections, otherActivators.AxisMoveHitbox2.Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				Axis.PlayPath(path, path.F)
			end)
		end
	end))

	table.insert(connections, otherActivators.Level1LoadHitbox.Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				LevelService.LoadLevel("Level01")
			end)
		end
	end))

	table.insert(connections, otherActivators.AxisVoiclineHitbox1.Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				Axis.PlayVoiceline("TunnelsConfuzzled")
			end)
		end
	end))

	table.insert(connections, otherActivators.AxisVoiclineHitbox2.Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				Axis.PlayVoiceline("Level0Yay")
			end)
		end
	end))

	table.insert(connections, otherActivators.AxisVoiclineHitbox3.Value.Activated.Changed:Connect(function(val)
		if val then
			task.spawn(function()
				Axis.PlayVoiceline("RestAreas")
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
