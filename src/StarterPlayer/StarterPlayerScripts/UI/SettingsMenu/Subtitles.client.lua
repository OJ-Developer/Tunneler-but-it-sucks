local enabled = true

script.Parent.MouseButton1Down:Connect(function()
	enabled = not enabled
	workspace.Axis.ShowSubtitles.Value = enabled
	script.Parent.Text = enabled and "On" or "Off"
end)