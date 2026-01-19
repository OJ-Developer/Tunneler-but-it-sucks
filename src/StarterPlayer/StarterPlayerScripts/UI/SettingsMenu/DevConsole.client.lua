local enabled = false

script.Parent.MouseButton1Down:Connect(function()
	enabled = not enabled
	script.Parent.Parent.Parent.Parent.Parent.Parent.DeveloperConsole.Enabled = enabled
	script.Parent.Text = enabled and "On" or "Off"
end)