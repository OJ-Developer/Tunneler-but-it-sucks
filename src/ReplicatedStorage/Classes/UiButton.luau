local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LinkedData = require(ReplicatedStorage.Services.LinkedData)
local ScriptSignal = require(ReplicatedStorage.Packages.GoodSignal)

local button = {}
button.__index = button

function button.new(buttonUI)
	local self = setmetatable({}, button)
	self.instance = buttonUI
	self.OnClick = ScriptSignal.new()

	local hover
	if not buttonUI.Parent:HasTag("SettingsOption") then
		hover = buttonUI:FindFirstChild("Hover")
		if not hover then
			hover = Instance.new("Frame")
			hover.Size = UDim2.fromScale(1,1)
			hover.Transparency = 0.9
			hover.BackgroundColor3 = Color3.new(1, 1, 1)
			hover.BorderSizePixel = 0
			hover.Visible = false
			hover.ZIndex = -1
			hover.Parent = self.instance
		end
	end
	
	local showData
	
	for _, value in buttonUI:QueryDescendants(">StringValue#ShowData") do
		showData = value.Value
	end
	
	local show: {ObjectValue} = buttonUI:QueryDescendants(">ObjectValue#Show")
	local hide: {ObjectValue} = buttonUI:QueryDescendants(">ObjectValue#Hide")
	
	
	if hover then
		buttonUI.MouseEnter:Connect(function()
			hover.Visible = true
		end)

		buttonUI.MouseLeave:Connect(function()
			hover.Visible = false
		end)
	end

	buttonUI.MouseButton1Down:Connect(function(x,y)
		if hover then
			hover.Visible = false
		end
		self.OnClick:Fire()
		
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

	LinkedData.Set(buttonUI, "UiButtonClass", self)
	
	return self
end

return button
