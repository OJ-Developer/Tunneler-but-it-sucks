game:GetService("ReplicatedStorage").Events.GameLoaded.Event:Wait()

local cs = game:GetService("CollectionService")

local uiButton = require(script.Parent.Classes.Button)
for _, button in cs:GetTagged("uiButton") do
	if button:IsDescendantOf(game:GetService("StarterGui")) then continue end
	uiButton.new(button)
end
