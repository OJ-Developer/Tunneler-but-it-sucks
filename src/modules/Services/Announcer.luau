local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AudioService = require(script.Parent.AudioService)
local Voicelines = require(ReplicatedStorage.Modules.Data.Voicelines)

local module = {}

function module.PlayVoiceline(voicelineName: string)
	local voiceline = Voicelines.Announcer[voicelineName]
	if voiceline then
		--local subtitle = voiceline.Subtitle
		local sound = AudioService.PlaySoundEffect(voiceline, 1)
		--subtitles.newSubtitle(subtitle, "Announcer", Color3.new(1, 1, 0), sound.TimeLength * 2)
		task.wait(sound.TimeLength)

		return true
	else
		warn(`Announcer voiceline "{voicelineName}" does not exist`)
		return false
	end
end

return module
