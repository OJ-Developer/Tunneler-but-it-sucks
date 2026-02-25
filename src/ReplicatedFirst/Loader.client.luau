-- LOADING SCREEN

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

-- load loading screen
ContentProvider:PreloadAsync({script.Parent:WaitForChild("LoadingGui")})

local loadingScreen = script.Parent.LoadingGui:Clone()

local startFrame = loadingScreen.StartFrame
local frames = loadingScreen.Frames:GetChildren()
table.sort(frames, function(a, b)
    return tonumber(a.Name) < tonumber(b.Name)
end)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

ReplicatedFirst:RemoveDefaultLoadingScreen()
loadingScreen.Parent = playerGui

-- load loading sound
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://78312487114248"
sound.Volume = 2
sound.Parent = script

ContentProvider:PreloadAsync({sound})

-- load stuff
local loaded = false

local ReplicatedStorage = game:GetService("ReplicatedStorage")

task.spawn(function()
    repeat task.wait() until game:IsLoaded()

    local AxisTextures = require(ReplicatedStorage.Data.AxisTextures)
    local Sounds = require(ReplicatedStorage.Data.Sounds)
    local Voicelines = require(ReplicatedStorage.Data.Voicelines)

    local assets = {}

    local cachedAssets = Instance.new("Folder", workspace)

    local function decalFromId(id)
        local decal = Instance.new("Decal")
        decal.ColorMap = id
        decal.Parent = cachedAssets
        table.insert(assets, decal)
        return decal
    end

    local function soundFromId(id)
        local sound = Instance.new("Sound")
        sound.SoundId = id
        sound.Parent = cachedAssets
        table.insert(assets, sound)
        return sound
    end
    
	for _, emotion in AxisTextures do
        for _, texture in emotion do
            decalFromId(texture)
        end
	end

    for _, song in Sounds.Music do
        soundFromId(song.NormalId)
        if song.HighVelId then
            soundFromId(song.HighVelId)
        end
        if song.HighAlertId then
            soundFromId(song.HighAlertId)
        end
	end

    for _, soundEffect in Sounds.SoundEffects do
        soundFromId(soundEffect.SoundId)
	end

    for _, character in Voicelines do
        for _, voiceline in character do
            soundFromId(voiceline.SoundId)
        end
    end

    decalFromId("rbxassetid://18169578588")
    decalFromId("rbxassetid://18871132115")

    ContentProvider:PreloadAsync(assets)
    ContentProvider:PreloadAsync({playerGui})
    ContentProvider:PreloadAsync({player.Character or player.CharacterAdded:Wait()})
    shared.DatastoreData = ReplicatedStorage.Events.GetPlayerDatastore:InvokeServer()
	
	loaded = true
end)


-- loading animation
local TweenService = game:GetService("TweenService")

sound:Play()
startFrame.Visible = false
frames[1].Visible = true
repeat task.wait() until sound.TimePosition >= 0.3
frames[1].Visible = false
frames[2].Visible = true
repeat task.wait() until sound.TimePosition >= 0.4
frames[2].Visible = false
frames[3].Visible = true
repeat task.wait() until sound.TimePosition >= 0.65
frames[3].Visible = false
frames[4].Visible = true
repeat task.wait() until sound.TimePosition >= 0.9
frames[4].Visible = false
frames[5].Visible = true

task.wait(1)

repeat task.wait() until loaded

TweenService:Create(frames[5], TweenInfo.new(1,Enum.EasingStyle.Linear), {ImageTransparency = 1}):Play()

task.spawn(function()
    task.wait(1)
    loadingScreen:Destroy()
end)



-- MODULE LOADER

local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")
local RunService = game:GetService("RunService")

local Settings = require(ReplicatedStorage.Configs.MainConfig)
local Enums = require(ReplicatedStorage.Data.Enums)

shared.PlayerState = {}
shared.GameState = {}
shared.Settings = {}
if UserInputService.GamepadEnabled then
    shared.InputDeviceType = Enums.InputDeviceType.Console
elseif UserInputService.MouseEnabled and UserInputService.KeyboardEnabled then
    shared.InputDeviceType = Enums.InputDeviceType.Keyboard
elseif UserInputService.TouchEnabled then
    shared.InputDeviceType = Enums.InputDeviceType.Mobile
elseif VRService.VREnabled then
    shared.InputDeviceType = Enums.InputDeviceType.VR
end

local serviceModules = ReplicatedStorage.Services
local services = {}

task.wait(1)

if Settings.MakeTheModuleLoaderSHUTUP == nil then
    Settings.MakeTheModuleLoaderSHUTUP = not RunService:IsStudio()
end

local function printMaybe(...)
    if Settings.MakeTheModuleLoaderSHUTUP then return end
    print(...)
end

for _, moduleScript in serviceModules:GetChildren() do
    printMaybe(`Loading module: "{moduleScript.Name}"`)

    local module = require(moduleScript)
    shared[moduleScript.Name] = module
    services[moduleScript.Name] = module
end

for name, service in services do
    local function initModule()
        if service.Init then
            printMaybe(`Initializing module: "{name}"`)
            service.Init()
            printMaybe(`Successfully initialized module: "{name}"`)
        end
    end

    if Settings.SafeLoad then
        local s, e = pcall(initModule)

        if not s then
            warn(`Module {name} experienced error "{e}" while initializing`)
        end
    else
        initModule()
    end
end

for name, service in services do
    local function startModule()
        if service.Start then
            printMaybe(`Starting module: "{name}"`)
            service.Start()
            printMaybe(`Successfully started module: "{name}"`)
        end
    end

    if Settings.SafeLoad then
        local s, e = pcall(startModule)

        if not s then
            warn(`Module {name} experienced error "{e}"`)
        end
    else
        startModule()
    end
end