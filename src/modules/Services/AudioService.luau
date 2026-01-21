--[[local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sounds = require(ReplicatedStorage.Modules.Data.Sounds)]]

local AudioService = {}

local SoundsFolder: Folder
local SoundEffectsFolder: Folder
local SongsFolder: Folder

local playingSong: string

function AudioService.Init()
    SoundsFolder = Instance.new("Folder")
    SoundsFolder.Name = "Sounds"
    SoundsFolder.Parent = workspace

    SoundEffectsFolder = Instance.new("Folder")
    SoundEffectsFolder.Name = "SoundEffects"
    SoundEffectsFolder.Parent = SoundsFolder

    SongsFolder = Instance.new("Folder")
    SongsFolder.Name = "Songs"
    SongsFolder.Parent = SoundsFolder
end

function AudioService.Start()
    -- test for AudioService
    --[[task.spawn(function()
        task.wait(2)
        AudioService.PlaySoundEffectAndWait(Sounds.SoundEffects.PlaceHolder, 2)
        AudioService.PlaySong(Sounds.Music.TunnelerButItSucks)
        task.wait(5)
        AudioService.PlaySong(Sounds.Music.hurricane_ambience)
        while task.wait(0.1) do
            AudioService.PlaySoundEffect(Sounds.SoundEffects.GunFire, 1)
        end
    end)]]
end

function AudioService.SoundInstanceFromSoundData(SoundEffectData, Volume: number, ParentObject: Instance?)
    local sound = Instance.new("Sound")
    sound.SoundId = SoundEffectData.Id
    sound.Volume = SoundEffectData.VolumeMultiplier and SoundEffectData.VolumeMultiplier * Volume or Volume
    sound.Parent = ParentObject or SoundEffectsFolder
    return sound
end

function AudioService.PlaySoundEffect(SoundEffectData, Volume: number, ParentObject: Instance?)
    local sound = AudioService.SoundInstanceFromSoundData(SoundEffectData, Volume, ParentObject)
    sound:Play()
    task.spawn(function()
        sound.Ended:Wait()
        sound:Destroy()
    end)
    return sound
end

function AudioService.PlaySoundEffectAndWait(SoundEffectData, Volume: number, ParentObject: Instance?)
    local sound = AudioService.SoundInstanceFromSoundData(SoundEffectData, Volume, ParentObject)
    sound:Play()
    print("playing")
    sound.Ended:Wait()
    print("done")
    sound:Destroy()
    return sound
end

function AudioService.PlaySong(songData)
    if playingSong and playingSong == songData.NormalId then return end

    AudioService.StopSongs()

    playingSong = songData.NormalId

    local normalSong = Instance.new("Sound")
    normalSong.SoundId = songData.NormalId
    normalSong.Volume = songData.VolumeMultiplier or 1
    normalSong.Looped = true
    normalSong.Parent = SongsFolder
    
    normalSong:Play()
end

function AudioService.StopSongs()
    for _, song in SongsFolder:GetChildren() do
        song:Destroy()
    end
end

function AudioService.GetPlayingSong()
    return playingSong
end

return AudioService