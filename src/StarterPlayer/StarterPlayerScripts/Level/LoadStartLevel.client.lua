local events = game:GetService("ReplicatedStorage").Events
local loadLevelEvent = events.Levels.LoadLevel

events.GameLoaded.Event:Once(function()
	loadLevelEvent:Fire("MainMenu")
end)

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
char:WaitForChild("HumanoidRootPart")

char:PivotTo(workspace:WaitForChild("Map"):WaitForChild("SpawnLocation").CFrame + Vector3.new(0, 3, 0))