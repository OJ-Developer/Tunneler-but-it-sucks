local runService = game:GetService("RunService")

local camera = workspace.CurrentCamera

local player = game.Players.LocalPlayer

local gun = game:GetService("ReplicatedStorage").Other.Gun:Clone()

local hasGun = script.Parent.HasGun

gun.Parent = workspace
gun.Name = "PortalGun"
script.Parent.Gun.Value = gun

runService.RenderStepped:Connect(function()
	if hasGun.Value then
		gun.Transparency = 0
		gun.CFrame = camera.CFrame*script.Offset.Value
	else
		gun.Transparency = 1
	end
end)