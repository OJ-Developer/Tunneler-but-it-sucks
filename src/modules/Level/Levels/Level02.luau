local module = {}

function module.Start(player: Player)
	

	-- MUSIC

	local rs = game:GetService("ReplicatedStorage")
	local events = rs:WaitForChild("Events")
	local playSongEvent = events:WaitForChild("Audio"):WaitForChild("PlaySong")
	playSongEvent:Fire("Small-Length_Experiment")
	
end

function module.Cleanup()
	
end

return module
