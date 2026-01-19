local rs = game:GetService("ReplicatedStorage")
local cs = game:GetService("CollectionService")

local events = rs.Events
local levelLoadedEvent = events.Levels.LevelLoaded
local toggletriggersEvent = script.Parent.Parent.DevConsoleCommands.toggletriggers
local levelLoadStartedEvent = events.Levels.LevelLoadStarted

local threads = {}

levelLoadedEvent.Event:Connect(function()
	for _, thread in pairs(threads) do
		task.cancel(thread)
	end
	table.clear(threads)
	
	for _, hitbox in pairs(cs:GetTagged("hitboxVisibility")) do
		if hitbox:IsDescendantOf(workspace) then
			table.insert(threads, task.defer(function()
				hitbox.Transparency = toggletriggersEvent.TriggersVisible.Value and 0.5 or 1

				toggletriggersEvent.Event:Connect(function()
					task.wait()
					hitbox.Transparency = toggletriggersEvent.TriggersVisible.Value and 0.5 or 1
				end)
			end))
		end
	end
end)

toggletriggersEvent.Event:Connect(function()
	toggletriggersEvent.TriggersVisible.Value = not toggletriggersEvent.TriggersVisible.Value
end)