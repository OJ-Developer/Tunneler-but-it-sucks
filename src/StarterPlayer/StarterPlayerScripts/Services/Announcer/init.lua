local module = {}

local sounds = script.VoicelineSounds

local subtitles = require(script.Parent.Parent.UI.Subtitles)
local voicelines = require(script.Voicelines)

function module.playVoiceline(voicelineName: string)
	local voiceline = voicelines[voicelineName]
	local subtitle = voiceline.Subtitle
	local sound = sounds:FindFirstChild(voicelineName)
	if sound then
		sound:Play()
	else
		warn("No sound for announcer voiceline: "..voicelineName)
	end
	subtitles.newSubtitle(subtitle, "Announcer", Color3.new(1, 1, 0), sound.TimeLength * 2)
	task.wait(sound.TimeLength)
end

return module
