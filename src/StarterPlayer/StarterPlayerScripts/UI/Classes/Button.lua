local event = require(script.Parent.Parent.Parent.Classes.Event)
local instanceUtils = require(script.Parent.Parent.Parent.Utils.InstanceUtils)
local LinkedData = require(script.Parent.Parent.Parent.Services.LinkedData)

local button = {}



function button.new(buttonUI: GuiButton)
	local newButton = {
		instance = buttonUI,
		OnClick = event.new(),
	}
	
	local clickTypes: {string} = newButton.clickMode

	local hover: Frame = buttonUI:FindFirstChild("Hover")
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
	
	
	local children = buttonUI:GetChildren()
	local showDataInstance: StringValue? = instanceUtils.getInstancesWithProperty(children, "StringValue", "Name", "ShowData")[1]
	local showData: string = showDataInstance and showDataInstance.Value or nil
	local show: {ObjectValue} = instanceUtils.getInstancesWithProperty(children, "ObjectValue", "Name", "Show")
	local hide: {ObjectValue} = instanceUtils.getInstancesWithProperty(children, "ObjectValue", "Name", "Hide")
	
	local callEvents: {ObjectValue} = instanceUtils.getInstancesWithProperty(children, "ObjectValue", "Name", "CallEvent")
	
	

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
		
		for _, value in callEvents do
			local paramsValues = value:GetChildren()
			table.sort(paramsValues, function(a, b)
				return tonumber(a.Name) < tonumber(b.Name)
			end)
			local params = {}
			for _, param in paramsValues do
				table.insert(params, param.Value)
			end
			
			if value.Value:IsA("BindableEvent") then
				value.Value:Fire(unpack(params))
			elseif value.Value:IsA("RemoteEvent") then
				value.Value:FireServer(unpack(params))
			end
		end
	end)
	
	LinkedData.Set(buttonUI, "UiButtonClass", newButton)
	
	return newButton
end



return button
