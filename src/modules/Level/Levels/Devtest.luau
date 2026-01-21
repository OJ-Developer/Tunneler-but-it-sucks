local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AudioService = require(ReplicatedStorage.Modules.Services.AudioService)

local module = {}

function module.Start()
	
	-- SETP




	-- MUSIC

	AudioService.StopSongs()
end

function module.Cleanup()
	
end

return module