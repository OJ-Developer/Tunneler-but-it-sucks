local uis = game:GetService("UserInputService")

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local head = char.Head
local camera = workspace.CurrentCamera

uis.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	
	if input.KeyCode == Enum.KeyCode.Q then
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Size = Vector3.new(3,3,3)
		part.Shape = Enum.PartType.Ball
		part.Position = head.Position + camera.CFrame.LookVector * 5
		part.AssemblyLinearVelocity = camera.CFrame.LookVector
		part.Parent = workspace.Map.Objects
		
		Instance.new("Highlight", part)
		
		task.spawn(function()
			for _ = 1, 500 do
				part.Position += part.AssemblyLinearVelocity * 0.2
				task.wait()
			end
			part:Destroy()
		end)
	end
end)