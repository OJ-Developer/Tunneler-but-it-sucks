local replicatedFirst = game:GetService("ReplicatedFirst")
local contentProvider = game:GetService("ContentProvider")
local tweenService = game:GetService("TweenService")


-- load loading screen
local loadingScreen = script:WaitForChild("Loading"):Clone()

local startFrame = loadingScreen:WaitForChild("0")
local frames = {
	loadingScreen:WaitForChild("1"),
	loadingScreen:WaitForChild("2"),
	loadingScreen:WaitForChild("3"),
	loadingScreen:WaitForChild("4"),
	loadingScreen:WaitForChild("5")
}

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

replicatedFirst:RemoveDefaultLoadingScreen()
loadingScreen.Parent = playerGui


-- load loading sound
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://78312487114248"
sound.Volume = 2
sound.Parent = script


-- load stuff
contentProvider:PreloadAsync(frames)
contentProvider:PreloadAsync({sound})

local loaded = false

task.spawn(function()
	local assets = game:GetChildren()
	table.insert(assets, playerGui)
	table.insert(assets, script:WaitForChild("AssetsToLoad"))
	
	contentProvider:PreloadAsync(assets)
	
	loaded = true
end)


-- loading animation
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

tweenService:Create(frames[5], TweenInfo.new(1,Enum.EasingStyle.Linear), {ImageTransparency = 1}):Play()
task.wait(1)
frames[5].Visible = false

game:GetService("ReplicatedStorage").Events.GameLoaded:Fire()
loadingScreen:Destroy()