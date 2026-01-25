local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Camera = require(script.Parent.CameraService)
local Object = require(ReplicatedStorage.Modules.Classes.Object)
local ScriptSignal = require(ReplicatedStorage.Modules.Classes.ScriptSignal)
local LinkedData = require(script.Parent.LinkedData)
local Settings = require(ReplicatedStorage.Configs.MainConfig)

local updateCharAnchored = ReplicatedStorage.Events.UpdateCharAnchored

local Level = {
	LevelLoadStarted = ScriptSignal.new(),
	LevelLoaded = ScriptSignal.new(),
}

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")

local levelModule
local levelThread

function Level.Start()
	task.spawn(function()
		Level.LoadLevel(Settings.StartLevel)
	end)
	RunService.PreRender:Connect(function()
		if rootPart.Position.Y <= -100 then
			Level.LoadLevel(shared.GameState.CurrentLevel)
		end

		for _, v in workspace.Map.Objects:GetChildren() do
			if v.Position.Y <= -100 then
				LinkedData.Get(v, "ObjectClass"):Fizzle()
			end
		end
	end)
end

function Level.LoadLevel(levelName: string)
    local level = ReplicatedStorage.Levels:FindFirstChild(levelName)
	if level then
		-- cleanup previous level
		for _, element in workspace.Map.Elements:GetChildren() do
			if LinkedData.Get(element) and LinkedData.Get(element, "ElementClass").Cleanup then
				LinkedData.Get(element, "ElementClass"):Cleanup()
			end
		end
		
		for _, object in workspace.Map.Objects:GetChildren() do
			if LinkedData.Get(object, "SpecificObjectClass") and LinkedData.Get(object, "SpecificObjectClass").Cleanup then
				LinkedData.Get(object, "SpecificObjectClass"):Cleanup()
			end
		end

		if levelThread ~= nil then
			task.cancel(levelThread)
			if levelModule.Cleanup then
				levelModule.Cleanup()
			end
		end
		
		-- load new level
		local wasMenuLevel = workspace.Map.LevelSettings.MenuLevel.Value
		
		rootPart.Anchored = true
	
		Level.LevelLoadStarted:Fire(levelName, wasMenuLevel)

		level = level:Clone()
		level.Parent = workspace
		local oldMap = workspace.Map
		level.Name = "Map"
		shared.GameState.CurrentLevel = levelName
		oldMap:Destroy()
		
		-- do levelsettings stuff
		local levelSettings = workspace.Map.LevelSettings
		if levelSettings.MenuLevel.Value then
			--disableCrosshairEvent:Fire()
			Camera.Disable()
		else
			--enableCrosshairEvent:Fire()
			local newPos = workspace:WaitForChild("Map"):WaitForChild("SpawnLocation").CFrame + Vector3.new(0, 3, 0)
			char:PivotTo(newPos)
			workspace.CurrentCamera.CFrame = newPos
			Camera.Enable()
		end

		-- wait for level to fully load
        ContentProvider:PreloadAsync({level})

		Level.LevelLoaded:Fire(levelName, wasMenuLevel)
		
		-- more level settings stuff
		updateCharAnchored:FireServer(levelSettings.MenuLevel.Value)
		rootPart.Anchored = levelSettings.MenuLevel.Value
		if levelSettings.SkyMode.Value == "Day" then
			Lighting.TimeOfDay = 14.5
			Lighting.Brightness = 2
		elseif levelSettings.SkyMode.Value == "Night" then
			Lighting.TimeOfDay = 0
			Lighting.Brightness = 0
		end

		-- give functionality to things in the new level
		for _, element in pairs(level.Elements:GetChildren()) do
			local module = script.Elements:FindFirstChild(element.Name)
			if module and module:IsA("ModuleScript") then
				local requiredElement = require(module).new(element)
				if not requiredElement then continue end
				LinkedData.Set(element, "ElementClass", requiredElement)
			else
				warn('Unknown testing element: "'..element.Name..'"')
			end
		end
		
		for _, object in pairs(level.Objects:GetChildren()) do
			Object.giveFunctionality(object)
		end
		
		local levelModuleScript = script.Levels:FindFirstChild(levelName)
		if levelModuleScript then
			levelModule = require(levelModuleScript)
			levelThread = task.defer(levelModule.Start, player)
		end
	else
		warn('Unknown level: "'..levelName..'"')
	end
end

return Level