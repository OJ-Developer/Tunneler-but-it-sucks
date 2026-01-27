local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utils = require(ReplicatedStorage.Modules.Utils)
local LinkedData = require(ReplicatedStorage.Services.LinkedData)
local ScriptSignal = require(script.Parent.ScriptSignal)

local button = {}
button.__index = button

function button.new(buttonUI: GuiButton)
	local newButton = setmetatable({
		instance = buttonUI,
		OnClick = ScriptSignal.new(),
	}, button)

	local hover = buttonUI:FindFirstChild("Hover")
	if not hover then
		hover = Instance.new("Frame")
		hover.Size = UDim2.fromScale(1,1)
		hover.Transparency = 0.9
		hover.BackgroundColor3 = Color3.new(1,1,1)
		hover.BorderSizePixel = 0
		hover.Visible = false
		hover.ZIndex = -1
		hover.Parent = newButton.instance
	end
	
	
	local showData
	
	for _, value in buttonUI:GetChildren() do
		if value:IsA("StringValue") then
			if value.Name == "ShowData" then
				showData = value.Value
			end
		end
	end
	
	local children = buttonUI:GetChildren()
	local show: {ObjectValue} = Utils.getInstancesWithProperty(children, "ObjectValue", "Name", "Show")
	local hide: {ObjectValue} = Utils.getInstancesWithProperty(children, "ObjectValue", "Name", "Hide")
	
	

	buttonUI.MouseEnter:Connect(function()
		hover.Visible = true
	end)

	buttonUI.MouseLeave:Connect(function()
		hover.Visible = false
	end)

	buttonUI.MouseButton1Down:Connect(function(x,y)
		hover.Visible = false
		newButton.OnClick:Fire()
		
		local function fireShowEvent(value)
			if showData and value.Value:FindFirstChild("Show") and value.Value.Show:IsA("BindableEvent") then
				value.Value.Show:Fire(showData)
			end
		end
		
		for _, value in show do
			if not value then continue end
			if value.Value:IsA("LayerCollector") then
				value.Value.Enabled = true
				fireShowEvent(value)
			elseif value.Value:IsA("GuiObject") then
				value.Value.Visible = true
				fireShowEvent(value)
			end
		end
		
		for _, value in hide do
			if not value then continue end
			if value.Value:IsA("LayerCollector") then
				value.Value.Enabled = false
			elseif value.Value:IsA("GuiObject") then
				value.Value.Visible = false
			end
		end
	end)

	LinkedData.Set(buttonUI, "UiButtonClass", newButton)
	
	return newButton
end

return button
