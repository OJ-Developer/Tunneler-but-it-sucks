local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LevelService = require(script.Parent.LevelService)
local LinkedData = require(script.Parent.LinkedData)
local UiButton = require(ReplicatedStorage.Modules.Classes.UiButton)

local UiService = {}

local player = Players.LocalPlayer
local playerGui = player.PlayerGui
local char = player.Character
local rootPart = char.HumanoidRootPart

function UiService.Init()
    -- setup buttons
    for _, button in CollectionService:GetTagged("uiButton") do
        if button:IsDescendantOf(playerGui) then
            UiButton.new(button)
        end
    end

    -- main menu stuff
    local mainMenu = playerGui.MainMenu
    local mainMenuOptions = mainMenu.MainMenu
    local playMenu = mainMenu.PlayMenu

    local levels = ReplicatedStorage.Levels:GetChildren()
    table.sort(levels, function(a,b)
        if a:GetAttribute("DisplayName") and b:GetAttribute("DisplayName") then
            return a:GetAttribute("DisplayName") < b:GetAttribute("DisplayName")
        end
        return false
    end)

    local exampleLevelOption = playMenu.PlayMenu.ExampleLevelOption

    for _, level in pairs(levels) do
        if level:GetAttribute("ShowOnPlayMenu") then
            local newLevelOption = exampleLevelOption:Clone()
            newLevelOption.LevelNameLabel.Text = level:GetAttribute("DisplayName")
            newLevelOption.LevelIcon.Image = level:GetAttribute("MenuIconId")
            newLevelOption.Name = level.Name
            newLevelOption.Parent = playMenu.PlayMenu
            newLevelOption.Visible = true
            
            local loadLevelButton = UiButton.new(newLevelOption.Play)
            loadLevelButton.OnClick:Connect(function()
                LevelService.LoadLevel(level.Name)
                playMenu.Visible = false
                playMenu.Parent.Enabled = false
            end)
        end
    end

    LinkedData.Get(mainMenuOptions.Quit, "UiButtonClass").OnClick:Connect(function()
        player:Kick("That's what the quit button does")
    end)

    -- loading screen setup
    LevelService.LevelLoadStarted:Connect(UiService.EnableLoadingScreen)
    LevelService.LevelLoaded:Connect(UiService.DisableLoadingScreen)

    -- pause menu stuff
    local pauseMenu = playerGui.PauseMenu

    local function togglePauseMenu()
        pauseMenu.Enabled = not pauseMenu.Enabled
        rootPart.Anchored = pauseMenu.Enabled
        --(pauseMenu.Enabled and disasbleCrosshair or enableCrosshair)()
    end

    ReplicatedStorage.Inputs.Pause.Pressed:Connect(togglePauseMenu)
    LinkedData.Get(pauseMenu.MainMenu.Resume, "UiButtonClass").OnClick:Connect(togglePauseMenu)
    LinkedData.Get(pauseMenu.MainMenu.Quit, "UiButtonClass").OnClick:Connect(function()
        LevelService.LoadLevel("MainMenu")
    end)

    -- settings menu stuff
    local settingsMenu = playerGui.Settings
    local settingsMenus = settingsMenu.Settings.SettingsMenus
    LinkedData.Get(settingsMenus.Back, "UiButtonClass").OnClick:Connect(function()
        (workspace.Map.LevelSettings.MenuLevel.Value and mainMenu or pauseMenu).Enabled = true
    end)
end

-- level loading screen stuff
local loadingScreenRunning = false
local loadingUi = playerGui.LoadingLevel

local john1 = loadingUi.John.John1
local john2 = loadingUi.John.John2

function UiService.EnableLoadingScreen()
    if loadingScreenRunning then return end
    loadingScreenRunning = true
    game.Lighting.Blur.Enabled = true
    loadingUi.Enabled = true
    task.spawn(function()
        while loadingScreenRunning do
            john1.Position = UDim2.fromScale(0.5,0.5)
            john2.Position = UDim2.fromScale(0.5,-0.25)
            TweenService:Create(john1, TweenInfo.new(2,Enum.EasingStyle.Linear), {Position = UDim2.fromScale(0.5,1.25)}):Play()
            TweenService:Create(john2, TweenInfo.new(2,Enum.EasingStyle.Linear), {Position = UDim2.fromScale(0.5,0.5)}):Play()
            task.wait(2)
        end
    end)
end

function UiService.DisableLoadingScreen()
    loadingScreenRunning = false
    game.Lighting.Blur.Enabled = false
    loadingUi.Enabled = false
end


return UiService