local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)		--disables chat
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)	--disables backpack
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)--disables emotes
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)--disables player list
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)	--disables health bar
repeat
    local disabled = pcall(function()
        StarterGui:SetCore("ResetButtonCallback", false) --Disables the reset button
    end)
    task.wait()
until disabled
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
char:WaitForChild("Humanoid"):SetStateEnabled(Enum.HumanoidStateType.Climbing, false)