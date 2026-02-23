local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Garbage = require(ReplicatedStorage.Classes.Garbage)
local LevelService = require(script.Parent.Parent)
local Sounds = require(ReplicatedStorage.Data.Sounds)
local Announcer = require(ReplicatedStorage.Services.Announcer)
local AudioService = require(ReplicatedStorage.Services.AudioService)
local Axis = require(ReplicatedStorage.Services.Axis)
local LinkedData = require(ReplicatedStorage.Services.LinkedData)

local module = {}

local garbage = Garbage.new()

function module.Start(player: Player)

	-- SETUP

	local level: typeof(workspace.Level01) = workspace.Map
	local elements = level.Elements


	-- MUSIC

	AudioService.PlaySong(Sounds.Music["0"])


	-- PORTAL GUN STAND

	local portalPlacer1 = LinkedData.Get(elements.PortalGunRoomPortalPlacer1, "ElementClass") 
	local portalPlacer2 = LinkedData.Get(elements.PortalGunRoomPortalPlacer2, "ElementClass")

	local portalGunStand = elements.PortalGunStand

	local portalGunCurrentlyAt = 2

	local function spinPortalGunStand(val)
		if val then
			if portalGunCurrentlyAt == 1 then
				local tween = TweenService:Create(portalGunStand.Stand.Gun, TweenInfo.new(5, Enum.EasingStyle.Linear), {CFrame = portalGunStand.Stand.Pos2.WorldCFrame})
				tween:Play()
				task.wait(5)
				portalPlacer2:SetActivated(true)
				portalPlacer1:SetActivated(false)
				portalGunCurrentlyAt = 2
			elseif portalGunCurrentlyAt == 2 then
				local tween = TweenService:Create(portalGunStand.Stand.Gun, TweenInfo.new(5, Enum.EasingStyle.Linear), {CFrame = portalGunStand.Stand.Pos1.WorldCFrame})
				tween:Play()
				task.wait(5)
				portalPlacer2:SetActivated(false)
				portalPlacer1:SetActivated(true)
				portalGunCurrentlyAt = 1
			end
		end
	end

	local portalGunSpinButton = LinkedData.Get(elements.PortalGunStandSpinButton, "ElementClass")

	garbage:Add(portalGunSpinButton.OnActivated:Connect(spinPortalGunStand))


	-- OTHER HITBOX THINGS AND STUFF

	local path = workspace.Map.AxisPaths.Path1
	
	garbage:Add(LinkedData.Get(elements.Room1EntranceTrigger, "ElementClass").OnActivated:Connect(function(val)
		if val then
			task.spawn(function()
				Announcer.PlayVoiceline("wtl1")
			end)
			task.spawn(function()
				Axis.PlayPath(path)
			end)
		end
	end))

	garbage:Add(LinkedData.Get(elements.Room2EntranceTrigger, "ElementClass").OnActivated:Connect(function(val)
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

	garbage:Add(LinkedData.Get(elements.Room3EntranceTrigger, "ElementClass").OnActivated:Connect(function(val)
		if val then
			task.spawn(function()
				portalGunSpinButton:Press()
				Axis.PlayPath(path, path.F)
			end)
			ethmdIntroThread = task.spawn(function()
				task.wait(5)
				Axis.PlayVoiceline("EclipseHoleMakingDevice")
				Axis.PlayVoiceline("DeviceSafety")
			end)
		end
	end))

	garbage:Add(shared.PlayerState.GunChanged:Connect(function(val)
		if val then
			AudioService.PlaySong(Sounds.Music.SmallLengthExperiment)
			
			if ethmdIntroThread then
				task.cancel(ethmdIntroThread)
			end
			task.spawn(function()
				Axis.PlayPath(path, path.H)
			end)
			garbage:Add(task.spawn(function()
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
			end))
		end
	end))

	garbage:Add(LinkedData.Get(elements.Room4EntranceTrigger, "ElementClass").OnActivated:Connect(function(val)
		if val then
			task.spawn(function()
				Axis.PlayPath(path, path.J)
			end)
		end
	end))

	garbage:Add(LinkedData.Get(elements.LevelEndTrigger, "ElementClass").OnActivated:Connect(function(val)
		if val then
			task.spawn(function()
				LevelService.LoadLevel("Level02")
			end)
		end
	end))
	
end

function module.Cleanup()
	garbage:Cleanup()
end

return module