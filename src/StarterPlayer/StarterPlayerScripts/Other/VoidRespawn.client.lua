local rs = game:GetService("ReplicatedStorage")
local events = rs.Events
local loadLevel = events.Levels.LoadLevel

local object = require(script.Parent.Parent.Classes.Object)

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")

rootPart.Changed:Connect(function()
	if rootPart.Position.Y <= -100 then
		loadLevel:Fire(workspace.Map:GetAttribute("LevelName"))
	end
end)

task.spawn(function()
	while task.wait() do
		for _, v in workspace.Map.Objects:GetChildren() do
			if v.Position.Y <= -100 then
				object.fizzle(v)
			end
		end
	end
end)