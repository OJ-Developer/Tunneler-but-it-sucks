-- services

local tweenService = game:GetService("TweenService")



-- references

local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local loadingUi = playerGui.LoadingLevel

local john1 = loadingUi.John.John1
local john2 = loadingUi.John.John2



-- variables

local running = false



-- public functions

local module = {}

function module.Enable()
	
	if running then return end
	running = true
	game.Lighting.Blur.Enabled = true
	loadingUi.Enabled = true
	task.spawn(function()
		while running do
			john1.Position = UDim2.fromScale(0.5,0.5)
			john2.Position = UDim2.fromScale(0.5,-0.25)
			tweenService:Create(john1, TweenInfo.new(2,Enum.EasingStyle.Linear), {Position = UDim2.fromScale(0.5,1.25)}):Play()
			tweenService:Create(john2, TweenInfo.new(2,Enum.EasingStyle.Linear), {Position = UDim2.fromScale(0.5,0.5)}):Play()
			task.wait(2)
		end
	end)
end

function module.Disable()
	running = false
	game.Lighting.Blur.Enabled = false
	loadingUi.Enabled = false
end

return module
