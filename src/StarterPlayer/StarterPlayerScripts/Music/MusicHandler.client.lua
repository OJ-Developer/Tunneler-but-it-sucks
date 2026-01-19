local events = game:GetService("ReplicatedStorage"):WaitForChild("Events")
local playsongEvent = events:WaitForChild("Audio"):WaitForChild("PlaySong")
local stopSongEvent = events.Audio:WaitForChild("StopSong")
local getPlayingSong = events.Audio:WaitForChild("GetPlayingSong")

local songs = script.Parent.Songs

local playingSong

playsongEvent.Event:Connect(function(songName)
	if songName == playingSong then return end
	
	stopSongEvent:Fire()
	if songs:FindFirstChild(songName) then
		task.wait() -- idk why but this just has to be here for it to work
		songs[songName]:Play()
		playingSong = songName
	else
		warn(songName.." is not a valid song")
	end
end)

stopSongEvent.Event:Connect(function()
	for _, song in pairs(songs:GetChildren()) do
		if song:IsA("Sound") then
			song:Stop()
			playingSong = nil
		end
	end
end)

getPlayingSong.OnInvoke = function()
	return playingSong
end