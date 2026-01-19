local rs = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local chars = rs:WaitForChild("Other"):WaitForChild("Characters")
local kilosRef = chars:WaitForChild("Kilometers")

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")
local human: Humanoid = char:WaitForChild("Humanoid")

for _, v in pairs(char:GetDescendants()) do
	if v:IsA("BasePart") then
		v.Transparency = 1
	elseif v:IsA("Decal") then
		v:Destroy()
	end
end

local kilos = kilosRef:Clone()
kilos.Parent = workspace
kilos.LocalTransparencyModifier = 1

runService.RenderStepped:Connect(function(dtime)
	kilos.CFrame = rootPart.CFrame - Vector3.new(0,0.5,0)
end)

human.Died:Connect(function()
	kilos:Destroy()
end)