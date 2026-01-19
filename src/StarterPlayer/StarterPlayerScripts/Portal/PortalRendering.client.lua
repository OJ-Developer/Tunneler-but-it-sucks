local ReplicatedStorage = game:GetService("ReplicatedStorage")

local events = ReplicatedStorage.Events
events.GameLoaded.Event:Wait()

local player = game.Players.LocalPlayer
local portalsUi = player.PlayerGui.Portals

local blueView = portalsUi.BluePortalView.Frame
local redView = portalsUi.RedPortalView.Frame
local bluePortal = workspace:WaitForChild("BluePortal"):WaitForChild("Portal")
local redPortal = workspace:WaitForChild("RedPortal"):WaitForChild("Portal")
local blueCam = Instance.new("Camera", workspace)
local redCam = Instance.new("Camera", workspace)

blueView.Parent.Adornee = bluePortal
redView.Parent.Adornee = redPortal

local frame = 0

while task.wait() do
	frame += 1
	if frame == 1 then
		blueView:ClearAllChildren()
		
		blueView.BackgroundColor3 = Color3.new(0,0,0)
		
		blueCam.CFrame = bluePortal.CFrame
		blueView.CurrentCamera = redCam
		
		for _, part in pairs(workspace:GetPartsInPart(redPortal.Parent.PortalVisibilityHitbox)) do
			if part:IsA("BasePart") and not part:IsA("Terrain") then
				local clone = part:Clone()
				clone.Parent = blueView
			end
		end
		local blueMask = redPortal.Parent:WaitForChild("RedViewportFrameMask"):Clone()
		blueMask.Parent = blueView
		blueMask.Transparency = 0
		
		if redPortal.Parent.OnPart.Value and bluePortal.Parent.OnPart.Value then continue end
		
		blueView.BackgroundColor3 = Color3.new(0, 0, 1)
		
		for _, part in pairs(blueView:GetChildren()) do
			if part.Name == "RedViewportFrameMask" then continue end
			part:Destroy()
		end
	else
		frame = 0
		
		redView:ClearAllChildren()
		
		redView.BackgroundColor3 = Color3.new(0,0,0)
		
		redCam.CFrame = redPortal.CFrame
		redView.CurrentCamera = blueCam
		
		for _, part in pairs(workspace:GetPartsInPart(bluePortal.Parent.PortalVisibilityHitbox)) do
			if part:IsA("BasePart") and not part:IsA("Terrain") then
				local clone = part:Clone()
				clone.Parent = redView
			end
		end
		local redMask = bluePortal.Parent:WaitForChild("BlueViewportFrameMask"):Clone()
		redMask.Parent = redView
		redMask.Transparency = 0
		
		if redPortal.Parent.OnPart.Value and bluePortal.Parent.OnPart.Value then continue end
		
		redView.BackgroundColor3 = Color3.new(1, 0.333333, 0)
		
		for _, part in pairs(redView:GetChildren()) do
			if part.Name == "BlueViewportFrameMask" then continue end
			part:Destroy()
		end
	end
end