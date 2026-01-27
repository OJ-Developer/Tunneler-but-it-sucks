local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sounds = require(ReplicatedStorage.Data.Sounds)
local AudioService = require(ReplicatedStorage.Services.AudioService)

local module = {}

function module.Start(player: Player)
	

	-- MUSIC

	AudioService.PlaySong(Sounds.Music.SmallLengthExperiment)
	
end

function module.Cleanup()
	
end

return module
