local enabled = false

script.Parent.MouseButton1Down:Connect(function()
	enabled = not enabled
	workspace.Axis.MuteAxis.Value = enabled
	script.Parent.Text = enabled and "On" or "Off"
end)