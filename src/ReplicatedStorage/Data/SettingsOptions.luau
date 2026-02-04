local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(script.Parent.Enums)
local AudioService = require(ReplicatedStorage.Services.AudioService)

local player = Players.LocalPlayer
local playerGui = player.PlayerGui.Gui

local settings = {
    Video = {
        {
            Name = "Bloom",
            Type = Enums.SettingType.Boolean,
            Default = true,
            OnChange = function(v)
                Lighting.Bloom.Intensity = v and 1 or 0
            end,
        },
        {
            Name = "Shadows",
            Type = Enums.SettingType.Boolean,
            Default = true,
            OnChange = function(v)
                Lighting.GlobalShadows = v
            end,
        },
        {
            Name = "Portal Rendering",
            Type = Enums.SettingType.Boolean,
            Default = true,
            OnChange = function(v)
                shared.Settings.PortalRendering = v
            end,
        },
        {
            Name = "FPS Counter",
            Type = Enums.SettingType.Boolean,
            Default = false,
            OnChange = function(v)
                playerGui.DevStats.Enabled = v
            end,
        }
    },

    Audio = {
        {
            Name = "Music",
            Type = Enums.SettingType.Slider,
            SliderMin = 0,
            SliderMax = 200,
            Default = 100,
            OnChange = function(v)
                AudioService.MusicVolume = v
            end,
        },
        {
            Name = "Sounds",
            Type = Enums.SettingType.Slider,
            SliderMin = 0,
            SliderMax = 200,
            Default = 100,
            OnChange = function(v)
                AudioService.SoundsVolume = v
            end,
        },
        {
            Name = "Voice",
            Type = Enums.SettingType.Slider,
            SliderMin = 0,
            SliderMax = 200,
            Default = 100,
            OnChange = function(v)
                AudioService.VoiceVolume = v
            end,
        },
        {
            Name = "Subtitles",
            Type = Enums.SettingType.Boolean,
            Default = true,
            OnChange = function(v)
                shared.Settings.Subtitles = v
            end,
        }
    },

    Gameplay = {
        {
            Name = "Mute Axis",
            Type = Enums.SettingType.Boolean,
            Default = false,
            OnChange = function(v)
                shared.Settings.MuteAxis = v
            end,
        },
        {
            Name = "Speedrun Timer",
            Type = Enums.SettingType.Boolean,
            Default = false,
            OnChange = function(v)
                playerGui.SpeedrunTimer.Enabled = v
            end,
        },
        {
            Name = "Developer Console",
            Type = Enums.SettingType.Boolean,
            Default = false,
            OnStart = function(_, setting)
                ReplicatedStorage.Events.UpdateDevConsoleEnabled:Fire(setting.Default)
            end,
            OnChange = function(v)
                shared.Settings.DevConsoleEnabled = not shared.Settings.DevConsoleEnabled
                ReplicatedStorage.Events.UpdateDevConsoleEnabled:Fire(v)
            end,
        }
    },

    Controls = {
        {
            Name = "Camera Sensitivity",
            Type = Enums.SettingType.Slider,
            SliderMin = 0,
            SliderMax = 200,
            Default = 100,
            OnChange = function(v)
                shared.Settings.CamSens = v
            end,
        },
        {
            Name = "Portal 1",
            Type = Enums.SettingType.Keybind,
            InputAction = ReplicatedStorage.Inputs.FireBlue,
        },
        {
            Name = "Portal 2",
            Type = Enums.SettingType.Keybind,
            InputAction = ReplicatedStorage.Inputs.FireRed,
        },
        {
            Name = "Crouch",
            Type = Enums.SettingType.Keybind,
            InputAction = ReplicatedStorage.Inputs.Crouch,
        },
        {
            Name = "Interact",
            Type = Enums.SettingType.Keybind,
            InputAction = ReplicatedStorage.Inputs.Interact,
        },
        {
            Name = "Developer Console",
            Type = Enums.SettingType.Keybind,
            InputAction = ReplicatedStorage.Inputs.DevConsole,
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