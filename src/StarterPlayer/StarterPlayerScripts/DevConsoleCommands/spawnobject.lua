

return function(objectName)
	

	local object = require(game.Players.LocalPlayer.PlayerScripts.Classes.Object)

	local cam = workspace.CurrentCamera

	object.spawn(objectName, cam.CFrame + cam.CFrame.LookVector * 10, cam.CFrame.LookVector * 10)
end

