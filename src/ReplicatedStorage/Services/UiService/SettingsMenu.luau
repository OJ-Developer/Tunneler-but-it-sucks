local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Enums = require(ReplicatedStorage.Data.Enums)
local SettingsOptions = require(ReplicatedStorage.Data.SettingsOptions)
local LinkedData = require(ReplicatedStorage.Services.LinkedData)

local setPlayerDatastore = ReplicatedStorage.Events.SetPlayerDatastore

local player = Players.LocalPlayer
local playerGui = player.PlayerGui.Gui
local settingsUi = playerGui.Settings
local settingsMenu = settingsUi.Settings
local referenceSettingsOptions = settingsUi.ReferenceSettingsOptions

local SettingsMenu = {}

local function newBoolOption(setting, catagory)
    local optionUi = referenceSettingsOptions.ButtonSetting:Clone()
    optionUi.Label.Text = setting.Name
    
    local state = shared.DatastoreData["Settings"..catagory..setting.Name] or setting.Default
    setting.Default = state
    optionUi.Button.Text = state and "On" or "Off"

    optionUi.Button.MouseButton1Down:Connect(function()
        state = not state
        optionUi.Button.Text = state and "On" or "Off"
        setting.OnChange(state)
        setPlayerDatastore:FireServer("Settings"..catagory..setting.Name, state)
    end)

    if setting.OnStart then
        setting.OnStart(optionUi, setting)
    end
    if setting.RunOnChangeOnStart then
        setting.OnChange(state)
    end

    optionUi.Parent = settingsMenu[catagory].Settings
    optionUi.Visible = true
end

local function newSliderOption(setting, catagory)
    local optionUi = referenceSettingsOptions.SliderSetting:Clone()
    optionUi.Label.Text = setting.Name

    local slider = optionUi.Slider
    local dot = slider.Dot

    local state = shared.DatastoreData["Settings"..catagory..setting.Name] or setting.Default
    setting.Default = state
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

            setPlayerDatastore:FireServer("Settings"..catagory..setting.Name, state)
        end
    end)

    optionUi.Value.FocusLost:Connect(function()
        local number = tonumber(optionUi.Value.Text)
        if number and number >= min and number <= max then
            state = tonumber(optionUi.Value.Text)
            updateDotPosition()
            setting.OnChange(state)

            setPlayerDatastore:FireServer("Settings"..catagory..setting.Name, state)
        else
            optionUi.Value.Text = math.round(state)
        end
    end)

    if setting.OnStart then
        setting.OnStart(optionUi, setting)
    end
    if setting.RunOnChangeOnStart then
        setting.OnChange(state)
    end

    optionUi.Parent = settingsMenu[catagory].Settings
    optionUi.Visible = true
end

local userInputTypeReplacements = {
    [Enum.UserInputType.MouseButton1] = Enum.KeyCode.MouseLeftButton,
    [Enum.UserInputType.MouseButton2] = Enum.KeyCode.MouseRightButton,
    [Enum.UserInputType.MouseButton3] = Enum.KeyCode.MouseMiddleButton,
}

function newKeybingOption(setting, catagory)
    local optionUi = referenceSettingsOptions.ButtonSetting:Clone()
    optionUi.Label.Text = setting.Name

    local inputDeviceType = shared.InputDeviceType
    local inputBinding: InputBinding = setting.InputAction[inputDeviceType]
    local savedBinding = shared.DatastoreData["Settings"..catagory..setting.Name]
    if savedBinding then
        local keycode = Enum.KeyCode:FromValue(savedBinding)
        inputBinding.KeyCode = keycode
        setting.Default = keycode
    end
    
    optionUi.Button.Text = inputBinding.KeyCode.Name

    optionUi.Button.MouseButton1Down:Connect(function()
        optionUi.Button.Interactable = false
        optionUi.Button.Text = ""
        task.wait()
        UserInputService.InputBegan:Once(function(input)
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                inputBinding.KeyCode = input.KeyCode
            elseif userInputTypeReplacements[input.UserInputType] then
                inputBinding.KeyCode = userInputTypeReplacements[input.UserInputType]
            end
            
            optionUi.Button.Text = inputBinding.KeyCode.Name
            optionUi.Button.Interactable = true

            setPlayerDatastore:FireServer("Settings"..catagory..setting.Name, inputBinding.KeyCode.Value)
        end)
    end)

    if setting.OnStart then
        setting.OnStart(optionUi)
    end

    optionUi.Parent = settingsMenu[catagory].Settings
    optionUi.Visible = true
end

function SettingsMenu.Start()
    LinkedData.Get(settingsMenu.SettingsMenus.Back, "UiButtonClass").OnClick:Connect(function()
        if workspace.Map.LevelSettings.MenuLevel.Value then
            playerGui.MainMenu.MainMenu.Visible = true
        else
            playerGui.PauseMenu.Enabled = true
        end
    end)

    for catagory, catagorySettings in SettingsOptions do
        for _, setting in catagorySettings do
            if setting.Type == Enums.SettingType.Boolean then
                newBoolOption(setting, catagory)
            elseif setting.Type == Enums.SettingType.Slider then
                newSliderOption(setting, catagory)
            elseif setting.Type == Enums.SettingType.Keybind then
                newKeybingOption(setting, catagory)
            end
        end

        local padding = referenceSettingsOptions.Padding:Clone()
        padding.Parent = settingsMenu[catagory].Settings
    end
end

return SettingsMenu