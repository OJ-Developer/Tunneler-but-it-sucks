local AudioService = {
    MusicVolume = 100,
    SoundsVolume = 100,
    VoiceVolume = 100
}

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

function AudioService.SoundInstanceFromSoundData(SoundEffectData, Volume: number?, ParentObject: Instance?, isVoiceline: boolean?)
    local sound = Instance.new("Sound")
    sound.SoundId = SoundEffectData.SoundId
    sound.Volume = Volume and (SoundEffectData.VolumeMultiplier and SoundEffectData.VolumeMultiplier * Volume or Volume) or (SoundEffectData.VolumeMultiplier or 1)
    sound:SetAttribute("BaseVolume", sound.Volume)
    sound.Volume *= (isVoiceline and AudioService.VoiceVolume or AudioService.SoundsVolume) / 100
    sound:SetAttribute("Voice", isVoiceline)
    sound.Parent = ParentObject or SoundEffectsFolder
    return sound
end

function AudioService.PlaySoundEffect(SoundEffectData, Volume: number?, ParentObject: Instance?, isVoiceline: boolean?)
    local sound = AudioService.SoundInstanceFromSoundData(SoundEffectData, Volume, ParentObject, isVoiceline)
    sound:Play()
    task.spawn(function()
        sound.Ended:Wait()
        sound:Destroy()
    end)
    return sound
end

function AudioService.PlaySoundEffectAndWait(SoundEffectData, Volume: number?, ParentObject: Instance?)
    local sound = AudioService.SoundInstanceFromSoundData(SoundEffectData, Volume, ParentObject)
    sound:Play()
    sound.Ended:Wait()
    sound:Destroy()
end

function AudioService.PlaySong(songData)
    if playingSong and playingSong == songData.NormalId then return end

    AudioService.StopSongs()

    playingSong = songData.NormalId

    local normalSong = Instance.new("Sound")
    normalSong.SoundId = songData.NormalId
    normalSong.Volume = songData.VolumeMultiplier or 1
    normalSong:SetAttribute("BaseVolume", normalSong.Volume)
    normalSong.Volume *= AudioService.MusicVolume / 100
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

function AudioService.UpdateVolume()
    for _, sound in workspace.Sounds.SoundEffects:GetChildren() do
        if sound:GetAttribute("Voice") then
            sound.Volume = sound:GetAttribute("BaseVolume") * (AudioService.VoiceVolume / 100)
        else
            sound.Volume = sound:GetAttribute("BaseVolume") * (AudioService.SoundsVolume / 100)
        end
    end

    for _, song in workspace.Sounds.Songs:GetChildren() do
        song.Volume = song:GetAttribute("BaseVolume") * (AudioService.MusicVolume / 100)
    end
end

return AudioService