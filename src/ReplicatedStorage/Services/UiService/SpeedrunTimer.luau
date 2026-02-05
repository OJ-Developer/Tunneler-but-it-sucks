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

    local function formatTime(t)
        return string.format("%02i", math.floor(t/3600))..":"..string.format("%02i", math.floor((t/60)%60))..":"..string.format("%05.2f", t%60)
    end

    local function updateUi()
        ui.TotalTime.Text = formatTime(totalTime)
        if ui:FindFirstChild(currentlevel) then
            ui[currentlevel].Text = currentlevel..": "..formatTime(levelTime)
        end
    end

    LevelService.LevelLoaded:Connect(function(newLevelName, fromMenu)
        if workspace.Map.LevelSettings.MenuLevel.Value then
            timing = false
        elseif fromMenu then
            totalTime = 0
            portalsPlaced = 0
            for i = 0, 9 do
                ui["Level0"..tostring(i)].Text = "Level0"..tostring(i)..": 00:00:00.00"
            end
            timing = true
        else
            timing = true
        end

        currentlevel = newLevelName

        levelTime = 0
    end)

    RunService.PreRender:Connect(function(dtime)
        if timing then
            totalTime += dtime
            levelTime += dtime
            updateUi()
        end
    end)

    PortalService.PortalPlaced:Connect(function()
        portalsPlaced += 1
        ui.PortalsMade.Text = portalsPlaced
    end)
end

return SpeedrunTimer