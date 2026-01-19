script.Parent.MouseButton1Down:Connect(function()
	script.Parent.Parent.Parent.Parent.Enabled = false
	if workspace.Map.LevelSettings.MenuLevel.Value then
		script.Parent.Parent.Parent.Parent.Parent.MainMenu.Enabled = true
	else
		script.Parent.Parent.Parent.Parent.Parent.PauseMenu.Enabled = true
	end
end)
