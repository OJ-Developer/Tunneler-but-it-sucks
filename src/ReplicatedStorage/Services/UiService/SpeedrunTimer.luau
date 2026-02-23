local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local ui = player.PlayerGui.Gui.SpeedrunTimer.Frame

local SpeedrunTimer = {}

function SpeedrunTimer.Init()
    local LevelService = shared.LevelService
    local PortalService = shared.PortalService

    local totalTime = 0
    local levelTime = 0
    local currentlevel = ""
    local portalsPlaced = 0

    local timing = false

    local renderStepConnection

    local function formatTime(t)
        return string.format("%02i", math.floor(t/3600))..":"..string.format("%02i", math.floor((t/60)%60))..":"..string.format("%05.2f", t%60)
    end

    local function updateUi()
        ui.TotalTime.Text = formatTime(totalTime)
        if ui:FindFirstChild(currentlevel) then
            ui[currentlevel].Text = currentlevel..": "..formatTime(levelTime)
        end
    end

    local function start()
        if renderStepConnection then return end

        timing = true

        renderStepConnection = RunService.PreRender:Connect(function(dtime)
            totalTime += dtime
            levelTime += dtime
            updateUi()
        end)
    end

    local function pause()
        if renderStepConnection then
            timing = false
            renderStepConnection:Disconnect()
        end
    end

    LevelService.LevelLoaded:Connect(function(newLevelName, fromMenu)
        if workspace.Map.LevelSettings.MenuLevel.Value then
            pause()
        elseif fromMenu then
            totalTime = 0
            portalsPlaced = 0
            for i = 0, 9 do
                ui["Level0"..tostring(i)].Text = "Level0"..tostring(i)..": 00:00:00.00"
            end
            start()
        else
            start()
        end

        currentlevel = newLevelName

        levelTime = 0
    end)

    LevelService.LevelLoadStarted:Connect(function()
        pause()
    end)
    LevelService.LevelLoaded:Connect(function()
        if timing then
            start()
        end
    end)

    PortalService.PortalPlaced:Connect(function()
        portalsPlaced += 1
        ui.PortalsMade.Text = portalsPlaced
    end)
end

return SpeedrunTimer