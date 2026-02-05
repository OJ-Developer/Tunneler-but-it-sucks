local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Voicelines = require(ReplicatedStorage.Data.Voicelines)
local AudioService = require(script.Parent.AudioService)
local UiService = require(script.Parent.UiService)

local module = {}

function module.PlayVoiceline(voicelineName: string)
	local voiceline = Voicelines.Announcer[voicelineName]
	if voiceline then
		local subtitle = voiceline.Subtitle
		local sound = AudioService.PlaySoundEffect(voiceline, 1, nil, true)
		if shared.Settings.Subtitles then
			UiService.Subtitle(subtitle, "Announcer", Color3.new(1, 1, 0), sound.TimeLength * 2)
		end
		task.wait(sound.TimeLength)

		return true
	else
		warn(`Announcer voiceline "{voicelineName}" does not exist`)
		return false
	end
end

return module
