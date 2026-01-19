local module = {}

local tweenService = game:GetService("TweenService")

local events = game:GetService("ReplicatedStorage").Events
local levelLoaded = events.Levels.LevelLoaded

local voicelines = require(script.Voicelines)
local subtitles = require(script.Parent.Parent.UI.Subtitles)

local textures = script.Textures

local currentEmotion = "Happy"

local axis = workspace:WaitForChild("Axis")
local showSubtitles = axis.ShowSubtitles
local muteAxis = axis.MuteAxis

--Voicline stuff

function module.SetEmotion(emotion, speaking)
	if speaking == 1 then
		axis.TextureID = textures[emotion].Speaking.Texture
	elseif speaking == 2 then
		axis.TextureID = textures[emotion].Speaking2.Texture
	else
		axis.TextureID = textures[emotion].Normal.Texture
	end
end

function module.PlayVoiceline(voiceline)
	-- stop other sounds
	for _, sound in pairs(script.VoicelineSounds:GetChildren()) do
		sound:Stop()
	end
	
	-- play sound
	local sound = script.VoicelineSounds[voiceline]
	if muteAxis.Value then
		sound.Volume = 0
	end
	sound:Play()
	
	-- subtitles
	if showSubtitles.Value and not muteAxis.Value then
		subtitles.newSubtitle(voicelines[voiceline].Subtitle, "Axis", Color3.new(0, 0.737255, 0), sound.TimeLength*1.2)
	end
	
	-- update axis textures
	while sound.Playing do
		module.SetEmotion(voicelines[voiceline].Emotion, 1)
		wait(0.2)
		module.SetEmotion(voicelines[voiceline].Emotion, 2)
		wait(0.2)
	end
	
	module.SetEmotion(voicelines[voiceline].Emotion, 0)
end



-- movement

local currentPathPos
local currentPath

function module.PlayPath(path, startFrom)
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
			module.PlayVoiceline(pos:GetAttribute("Voiceline"))
		end
		
		-- moves axis to next point
		local time = (axis.Position - pos.WorldPosition).Magnitude / 10
		local tween = tweenService:Create(axis, TweenInfo.new(time, Enum.EasingStyle.Linear), {Position = pos.WorldPosition - Vector3.new(0,2,0)})
		tween:Play()
		task.wait(time)
		
		-- stops moving if necessary
		if pos:GetAttribute("Hold") and not (pos == startFrom) then
			currentPathPos = pos
			currentPath = path
			break
		end
	end
end

function module.scare()
	local scaredVoicelines = {"BeCarefull", "Carefull", "LookOut", "BackUp", "OhNo"}
	local voiceline = scaredVoicelines[math.random(1, #scaredVoicelines)]
	task.spawn(function()
		module.PlayVoiceline(voiceline)
	end)
end

levelLoaded.Event:Connect(function()
	axis.CurrentState.Speaking.Value = false
	axis.CurrentState.SpeakingTextureEnabled.Value = false
end)

return module
