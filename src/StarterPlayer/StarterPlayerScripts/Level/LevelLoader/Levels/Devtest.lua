local module = {}

function module.Start()
	
	-- SETP
	local rs = game:GetService("ReplicatedStorage")
	local events = rs:WaitForChild("Events")



	-- MUSIC

	local stopSong = events:WaitForChild("Audio"):WaitForChild("StopSong")
	stopSong:Fire()
end

function module.Cleanup()
	
end

return module