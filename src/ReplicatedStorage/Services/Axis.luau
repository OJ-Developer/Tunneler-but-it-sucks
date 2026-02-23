local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")

local AxisTextures = require(ReplicatedStorage.Data.AxisTextures)
local Enums = require(ReplicatedStorage.Data.Enums)
local Voicelines = require(ReplicatedStorage.Data.Voicelines).Axis
local AudioService = require(script.Parent.AudioService)
local UiService = require(script.Parent.UiService)

local Axis = {
	State = {
		Speaking = false,
		Emotion = Enums.AxisEmotion.Happy
	}
}

local axis

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local head = char:WaitForChild("Head")

local playingSound: Sound

function Axis.Init()
	axis = ReplicatedStorage.Assets.Axis:Clone()
	axis.Parent = workspace
end

function Axis.Start()
	task.spawn(function()
		while task.wait() do
			axis.CFrame = CFrame.lookAt(axis.Position, head.Position) * CFrame.Angles(0,math.rad(270),0)
		end
	end)
end

--Voicline stuff

function Axis.SetEmotion(emotion, speaking)
	if AxisTextures[emotion] then
		if speaking == 1 then
			axis.TextureID = AxisTextures[emotion].Speaking1
		elseif speaking == 2 then
			axis.TextureID = AxisTextures[emotion].Speaking2
		else
			axis.TextureID = AxisTextures[emotion].Normal
		end

		return true
	else
		warn(`Axis emotion "{emotion}" does not exist`)
		return false
	end
end

function Axis.PlayVoiceline(voiceline)
	if Voicelines[voiceline] then
		Axis.ShutUp()

		-- stop other sounds
		if playingSound and playingSound.Parent then
			playingSound:Stop()
		end
		
		-- play sound
		playingSound = AudioService.PlaySoundEffect(Voicelines[voiceline], shared.Settings.MuteAxis and 0 or 2, nil, true)
		
		-- subtitles
		if shared.Settings.Subtitles and not shared.Settings.MuteAxis then
			UiService.Subtitle(Voicelines[voiceline].Subtitle, "Axis", Color3.new(0, 0.737255, 0), playingSound.TimeLength*1.2)
		end
		
		-- update axis textures
		while playingSound.Playing do
			Axis.SetEmotion(Voicelines[voiceline].Emotion, 1)
			task.wait(0.2)
			Axis.SetEmotion(Voicelines[voiceline].Emotion, 2)
			task.wait(0.2)
		end
		
		Axis.SetEmotion(Voicelines[voiceline].Emotion, 0)

		return true
	else
		warn(`Axis voiceline "{voiceline}" does not exist`)
		return false
	end
end

function Axis.ShutUp()
	if not playingSound then return end
	playingSound.Playing = false
end



-- movement

function Axis.PlayPath(path, startFrom)
	-- axis start pos
	if startFrom then
		axis.Position = startFrom.WorldPosition
	else
		axis.Position = path.Position
	end
	
	local foundStartFrom = false
	
	-- getting and sorting the path
	local pathChildren = path:GetChildren()
	table.sort(pathChildren, function(a, b)
		return a.Name < b.Name
	end)
	for i, pos in pairs(pathChildren) do	
		-- skipping points until the correct starting point is found
		if startFrom and not foundStartFrom then
			if pos == startFrom then
				foundStartFrom = true
			else
				continue
			end
		end
		
		-- plays voiceline if necessary
		if pos:GetAttribute("Voiceline") then
			Axis.PlayVoiceline(pos:GetAttribute("Voiceline"))
		end
		
		-- moves axis to next point
		local time = (axis.Position - pos.WorldPosition).Magnitude / 10
		local tween = tweenService:Create(axis, TweenInfo.new(time, Enum.EasingStyle.Linear), {Position = pos.WorldPosition - Vector3.new(0,2,0)})
		tween:Play()
		task.wait(time)
		
		-- stops moving if necessary
		if pos:GetAttribute("Hold") and not (pos == startFrom) then
			break
		end
	end
end

function Axis.scare()
	local scaredVoicelines = {"BeCarefull", "Carefull", "LookOut", "BackUp", "OhNo"}
	local voiceline = scaredVoicelines[math.random(1, #scaredVoicelines)]
	task.spawn(function()
		Axis.PlayVoiceline(voiceline)
	end)
end

return Axis
