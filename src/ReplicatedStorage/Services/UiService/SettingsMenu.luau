local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Enums = require(ReplicatedStorage.Data.Enums)
local SettingsOptions = require(ReplicatedStorage.Data.SettingsOptions)
local LinkedData = require(ReplicatedStorage.Services.LinkedData)

local player = Players.LocalPlayer
local playerGui = player.PlayerGui.Gui
local settingsUi = playerGui.Settings
local settingsMenu = settingsUi.Settings
local referenceSettingsOptions = settingsUi.ReferenceSettingsOptions

local SettingsMenu = {}

function SettingsMenu.Init()
    LinkedData.Get(settingsMenu.SettingsMenus.Back, "UiButtonClass").OnClick:Connect(function()
        if workspace.Map.LevelSettings.MenuLevel.Value then
            playerGui.MainMenu.MainMenu.Visible = true
        else
            playerGui.PauseMenu.Enabled = true
        end
    end)

    for catagory, catagorySettings in SettingsOptions do
        for name, setting in catagorySettings do
            if setting.Type == Enums.SettingType.Boolean then
                local optionUi = referenceSettingsOptions.ButtonSetting:Clone()
                optionUi.Label.Text = setting.Name
                
                local state = setting.Default
                optionUi.Button.Text = state and "On" or "Off"

                optionUi.Button.MouseButton1Down:Connect(function()
                    state = not state
                    optionUi.Button.Text = state and "On" or "Off"
                    setting.OnChange(state)
                end)

                if setting.OnStart then
                    setting.OnStart(optionUi, setting)
                end

                optionUi.Parent = settingsMenu[catagory].Settings
                optionUi.Visible = true
            elseif setting.Type == Enums.SettingType.Slider then
                local optionUi = referenceSettingsOptions.SliderSetting:Clone()
                optionUi.Label.Text = setting.Name

                local slider = optionUi.Slider
                local dot = slider.Dot

                local state = setting.Default
                local min = setting.SliderMin
                local max = setting.SliderMax
                optionUi.Value.Text = state
                
                local function updateDotPosition()
                    dot.Position = UDim2.fromScale((state - min) / (max - min), .5)
                end
                updateDotPosition()

                dot.Changed:Connect(function(property)
                    if property == "Position" then
                        local nonClamped = min + (max - min) * dot.Position.X.Scale
                        state = math.clamp(nonClamped, min, max)
                        if state ~= nonClamped then
                            updateDotPosition()
                        end
                        optionUi.Value.Text = math.round(state)
                        setting.OnChange(state)
                    end
                end)

                optionUi.Value.FocusLost:Connect(function()
                    local number = tonumber(optionUi.Value.Text)
                    if number and number >= min and number <= max then
                        state = tonumber(optionUi.Value.Text)
                        updateDotPosition()
                        setting.OnChange(state)
                    else
                        optionUi.Value.Text = math.round(state)
                    end
                end)

                if setting.OnStart then
                    setting.OnStart(optionUi, setting)
                end

                optionUi.Parent = settingsMenu[catagory].Settings
                optionUi.Visible = true
            elseif setting.Type == Enums.SettingType.Keybind then
                local optionUi = referenceSettingsOptions.ButtonSetting:Clone()
                optionUi.Label.Text = setting.Name

                local inputDeviceType = shared.InputDeviceType
                local inputBinding: InputBinding = setting.InputAction[inputDeviceType]
                
                optionUi.Button.Text = inputBinding.KeyCode.Name

                optionUi.Button.MouseButton1Down:Connect(function()
                    optionUi.Button.Interactable = false
                    optionUi.Button.Text = ""
                    task.wait()
                    UserInputService.InputBegan:Once(function(input)
                        if input.KeyCode ~= Enum.KeyCode.Unknown then
                            inputBinding.KeyCode = input.KeyCode
                        else
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                inputBinding.KeyCode = Enum.KeyCode.MouseLeftButton
                            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                                inputBinding.KeyCode = Enum.KeyCode.MouseRightButton
                            elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                                inputBinding.KeyCode = Enum.KeyCode.MouseMiddleButton
                            end
                        end
                        
                        optionUi.Button.Text = inputBinding.KeyCode.Name
                        optionUi.Button.Interactable = true
                    end)
                end)

                if setting.OnStart then
                    setting.OnStart(optionUi)
                end

                optionUi.Parent = settingsMenu[catagory].Settings
                optionUi.Visible = true
            end
        end

        local padding = referenceSettingsOptions.Padding:Clone()
        padding.Parent = settingsMenu[catagory].Settings
    end
end

return SettingsMenu