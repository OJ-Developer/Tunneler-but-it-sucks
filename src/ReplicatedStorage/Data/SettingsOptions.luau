local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(script.Parent.Enums)
local AudioService = require(ReplicatedStorage.Services.AudioService)

local player = Players.LocalPlayer
local playerGui = player.PlayerGui.Gui

local settings = {
    Video = {
        Bloom = {
            Type = Enums.SettingType.Boolean,
            Default = true,
            OnChange = function(v)
                Lighting.Bloom.Enabled = v
            end,
            SortOrder = 1
        },
        Shadows = {
            Type = Enums.SettingType.Boolean,
            Default = true,
            OnChange = function(v)
                Lighting.GlobalShadows = v
            end,
            SortOrder = 2
        },
        PortalRendering = {
            DisplayName = "Portal Rendering",
            Type = Enums.SettingType.Boolean,
            Default = true,
            OnChange = function(v)
                shared.Settings.PortalRendering = v
            end,
            SortOrder = 3
        },
        FpsCounter = {
            DisplayName = "FPS Counter",
            Type = Enums.SettingType.Boolean,
            Default = false,
            OnChange = function(v)
                playerGui.DevStats.Enabled = v
            end,
            SortOrder = 4
        }
    },

    Audio = {
        Music = {
            Type = Enums.SettingType.Slider,
            SliderMin = 0,
            SliderMax = 200,
            Default = 100,
            OnChange = function(v)
                AudioService.MusicVolume = v
            end,
            SortOrder = 1
        },
        Sounds = {
            Type = Enums.SettingType.Slider,
            SliderMin = 0,
            SliderMax = 200,
            Default = 100,
            OnChange = function(v)
                AudioService.SoundsVolume = v
            end,
            SortOrder = 2
        },
        Voice = {
            Type = Enums.SettingType.Slider,
            SliderMin = 0,
            SliderMax = 200,
            Default = 100,
            OnChange = function(v)
                AudioService.VoiceVolume = v
            end,
            SortOrder = 3
        },
        Subtitles = {
            Type = Enums.SettingType.Boolean,
            Default = true,
            OnChange = function(v)
                shared.Settings.Subtitles = v
            end,
            SortOrder = 4
        }
    },

    Gameplay = {
        MuteAxis = {
            DisplayName = "Mute Axis",
            Type = Enums.SettingType.Boolean,
            Default = false,
            OnChange = function(v)
                shared.Settings.MuteAxis = v
            end,
            SortOrder = 1
        },
        SpeedrunTimer = {
            DisplayName = "Speedrun Timer",
            Type = Enums.SettingType.Boolean,
            Default = false,
            OnChange = function(v)
                playerGui.SpeedrunTimer.Enabled = v
            end,
            SortOrder = 2
        },
        DevConsole = {
            DisplayName = "Developer Console",
            Type = Enums.SettingType.Boolean,
            Default = false,
            OnStart = function(_, default)
                ReplicatedStorage.Events.UpdateDevConsoleEnabled:Fire(default)
            end,
            OnChange = function(v)
                shared.Settings.DevConsoleEnabled = not shared.Settings.DevConsoleEnabled
                ReplicatedStorage.Events.UpdateDevConsoleEnabled:Fire(v)
            end,
            SortOrder = 3
        }
    },

    Controls = {
        CamSens = {
            DisplayName = "Camera Sensitivity",
            Type = Enums.SettingType.Slider,
            SliderMin = 0,
            SliderMax = 200,
            Default = 100,
            OnChange = function(v)
                shared.Settings.CamSens = v
            end,
            SortOrder = 1
        },
        Portal1 = {
            DisplayName = "Portal 1",
            Type = Enums.SettingType.Keybind,
            InputAction = ReplicatedStorage.Inputs.FireBlue,
            SortOrder = 2
        },
        Portal2 = {
            DisplayName = "Portal 2",
            Type = Enums.SettingType.Keybind,
            InputAction = ReplicatedStorage.Inputs.FireRed,
            SortOrder = 3
        },
        Crouch = {
            Type = Enums.SettingType.Keybind,
            InputAction = ReplicatedStorage.Inputs.Crouch,
            SortOrder = 4
        },
        Interact = {
            Type = Enums.SettingType.Keybind,
            InputAction = ReplicatedStorage.Inputs.Interact,
            SortOrder = 5
        },
        DevConsole = {
            DisplayName = "Developer Console",
            Type = Enums.SettingType.Keybind,
            InputAction = ReplicatedStorage.Inputs.DevConsole,
            SortOrder = 6
        }
    }
}

for catagory, catagorySettings in settings do
    for name, setting in catagorySettings do
        if setting.Default and not shared.Settings[name] then
            shared.Settings[name] = setting.Default
        end
    end
end

return settings