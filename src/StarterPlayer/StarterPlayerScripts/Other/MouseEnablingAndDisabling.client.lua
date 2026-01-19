local events = game:GetService("ReplicatedStorage"):WaitForChild("Events")
local enableCrosshairEvent = events.UI.EnableCrosshair
local disableCrosshairEvent = events.UI.DisableCrosshair

local uis = game:GetService("UserInputService")

enableCrosshairEvent.Event:Connect(function()
	uis.MouseIconEnabled = false
end)

disableCrosshairEvent.Event:Connect(function()
	uis.MouseIconEnabled = true
end)