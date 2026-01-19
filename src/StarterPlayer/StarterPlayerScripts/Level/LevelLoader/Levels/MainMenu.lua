local module = {}

function module.Start()
	local player = game.Players.LocalPlayer
	local char = player.Character
	local rootPart = char:WaitForChild("HumanoidRootPart")
	rootPart.Anchored = true

	local menuUI = player.PlayerGui.MainMenu
	menuUI.Enabled = true

	local camera = workspace.CurrentCamera
	camera.CFrame = workspace.Map.Other.Camera.CFrame

	local events = game:GetService("ReplicatedStorage").Events
	local playSongEvent = events.Audio.PlaySong
	playSongEvent:Fire("Tunneler_but_it_sucks")
end

function module.Cleanup()
	
end

return module
