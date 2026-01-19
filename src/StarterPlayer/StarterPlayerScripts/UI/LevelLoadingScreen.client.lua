local rs = game:GetService("ReplicatedStorage")

local events = rs.Events
local levelLoadStarted = events.Levels.LevelLoadStarted
local levelLoaded = events.Levels.LevelLoaded

local LoadingScreen = require(script.Parent.Parent.Services.LoadingScreen)

levelLoadStarted.Event:Connect(LoadingScreen.Enable)
levelLoaded.Event:Connect(LoadingScreen.Disable)