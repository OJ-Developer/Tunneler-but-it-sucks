local rs = game:GetService("ReplicatedStorage")
local lighting = game:GetService("Lighting")

local events = rs.Events
local loadLevelEvent = events.Levels.LoadLevel
local levelLoadedEvent = events.Levels.LevelLoaded
local levelLoadStartedEvent = events.Levels.LevelLoadStarted
local updateCharAnchored = events.Other.UpdateCharAnchored
local enableCrosshairEvent = events.UI.EnableCrosshair
local disableCrosshairEvent = events.UI.DisableCrosshair

local levels = rs.Levels

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")

local cameraModule = require(script.Parent.Parent.CameraScript.CameraModule)
local objectClass = require(script.Parent.Parent.Classes.Object)
local vectorUtils = require(script.Parent.Parent.Utils.VectorUtils)
local linkedData = require(script.Parent.Parent.Services.LinkedData)

local levelModule
local levelThread

loadLevelEvent.Event:Connect(function(levelName)
	local level = levels:FindFirstChild(levelName)
	if level then
		for _, element in workspace.Map.Elements:GetChildren() do
			if linkedData.Get(element) then
				linkedData.Get(element, "ElementModule"):Cleanup()
			end
		end
		
		for _, object in workspace.Map.Objects:GetChildren() do
			if linkedData.Get(object) then
				linkedData.Get(object, "ObjectClass"):Cleanup()
			end
		end

		if levelThread ~= nil then
			task.cancel(levelThread)
			if levelModule.Cleanup then
				levelModule.Cleanup()
			end
		end
		
		local wasLevelMenu = workspace.Map.LevelSettings.MenuLevel.Value
		
		rootPart.Anchored = true
	
		levelLoadStartedEvent:Fire()

		level = level:Clone()
		level.Parent = workspace
		local oldMap = workspace.Map
		level.Name = "Map"
		level:SetAttribute("LevelName", levelName)
		oldMap:Destroy()

		levelLoadedEvent:Fire(levelName, wasLevelMenu)
		
		local levelSettings = workspace.Map.LevelSettings
		updateCharAnchored:FireServer(levelSettings.MenuLevel.Value)
		rootPart.Anchored = levelSettings.MenuLevel.Value
		if levelSettings.SkyMode.Value == "Day" then
			lighting.TimeOfDay = 14.5
			lighting.Brightness = 2
		elseif levelSettings.SkyMode.Value == "Night" then
			lighting.TimeOfDay = 0
			lighting.Brightness = 0
		end
		
		if levelSettings.MenuLevel.Value then
			disableCrosshairEvent:Fire()
			cameraModule.Stop()
		else
			enableCrosshairEvent:Fire()
			local newPos = workspace:WaitForChild("Map"):WaitForChild("SpawnLocation").CFrame + Vector3.new(0, 3, 0)
			char:PivotTo(workspace:WaitForChild("Map"):WaitForChild("SpawnLocation").CFrame + Vector3.new(0, 3, 0))
			workspace.CurrentCamera.CFrame = newPos
			cameraModule.Start()			
		end
		for _, element in pairs(level.Elements:GetChildren()) do
			local module = script.Elements:FindFirstChild(element.Name)
			if module and module:IsA("ModuleScript") then
				local requiredElement = require(module).new(element)
				if not requiredElement then continue end
				linkedData.Set(element, "ElementModule", requiredElement)
			else
				warn('Unknown testing element: "'..element.Name..'"')
			end
		end
		
		for _, object in pairs(level.Objects:GetChildren()) do
			objectClass.giveFunctionality(object)
		end
		
		local levelModuleScript = script.Levels:FindFirstChild(levelName)
		if levelModuleScript then
			levelModule = require(levelModuleScript)
			levelThread = task.defer(levelModule.Start, player, player.PlayerScripts)
		end
	else
		wait('Unknown level: "'..levelName..'"')
	end
end)