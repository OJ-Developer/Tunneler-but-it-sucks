local Players = game:GetService("Players")

local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player.PlayerGui.Gui

local loadingScreenRunning = false
local loadingUi = playerGui.LoadingLevel

local john1 = loadingUi.John.John1
local john2 = loadingUi.John.John2

local LoadingScreen = {}

function LoadingScreen.Enable()
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

function LoadingScreen.Disable()
    loadingScreenRunning = false
    game.Lighting.Blur.Enabled = false
    loadingUi.Enabled = false
end

return LoadingScreen