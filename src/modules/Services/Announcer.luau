local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AudioService = require(script.Parent.AudioService)
local Voicelines = require(ReplicatedStorage.Modules.Data.Voicelines)

local module = {}

function module.playVoiceline(voicelineName: string)
	local voiceline = Voicelines.Announcer[voicelineName]
	local subtitle = voiceline.Subtitle
	local sound = AudioService.PlaySoundEffect({Id = voiceline.SoundId}, 1)
	--subtitles.newSubtitle(subtitle, "Announcer", Color3.new(1, 1, 0), sound.TimeLength * 2)
	task.wait(sound.TimeLength)
end

return module
