local DataStoreService = game:GetService("DataStoreService")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local MainConfig = require(ReplicatedStorage.Configs.MainConfig)
local Utils = require(ReplicatedStorage.Modules.Utils)

PhysicsService:RegisterCollisionGroup("InBluePortal")
PhysicsService:RegisterCollisionGroup("InRedPortal")
PhysicsService:RegisterCollisionGroup("InBothPortals")
PhysicsService:RegisterCollisionGroup("BehindBluePortal")
PhysicsService:RegisterCollisionGroup("BehindRedPortal")
PhysicsService:RegisterCollisionGroup("BehindBothPortals")
PhysicsService:CollisionGroupSetCollidable("InBluePortal", "BehindBluePortal", false)
PhysicsService:CollisionGroupSetCollidable("InBluePortal", "BehindBothPortals", false)
PhysicsService:CollisionGroupSetCollidable("InRedPortal", "BehindRedPortal", false)
PhysicsService:CollisionGroupSetCollidable("InRedPortal", "BehindBothPortals", false)
PhysicsService:CollisionGroupSetCollidable("InBothPortals", "BehindBluePortal", false)
PhysicsService:CollisionGroupSetCollidable("InBothPortals", "BehindRedPortal", false)
PhysicsService:CollisionGroupSetCollidable("InBothPortals", "BehindBothPortals", false)

local events = ReplicatedStorage.Events

events.UpdateCharAnchored.OnServerEvent:Connect(function(plr, val)
	plr.Character.HumanoidRootPart.Anchored = val
end)

events.TeleportPlayer.OnServerEvent:Connect(function(plr, placeid)
	TeleportService:TeleportAsync(placeid, {plr})
end)

local BASE_RETRY_WAIT_TIME = 1

local function printMaybe(...)
    if MainConfig.MakeTheModuleLoaderSHUTUP then return end
    print(...)
end

events.GetPlayerDatastore.OnServerInvoke = function(player)
	if game.PlaceId == 0 then
		return {
			SettingsControlsCrouch = 304,
			["SettingsGameplayDeveloper Console"] = true,
			["SettingsGameplayFPS Counter"] = true
		}
	end

	local datastoreData = {}
	local datastore = DataStoreService:GetDataStore(tostring(player.UserId))

	local success = {}

	for _, v in datastore:ListKeysAsync():GetCurrentPage() do
		success[v.KeyName] = false
 
		task.spawn(function()
			local key = v.KeyName
			printMaybe("getting datastore:", key)
			local data
			local waitTime = BASE_RETRY_WAIT_TIME
			while true do
				local s = pcall(function()
					data = datastore:GetAsync(key)
				end)

				if s then break end

				warn(`error while getting datastore "{key}". retrying in {waitTime}s`)
				task.wait(waitTime)
				waitTime *= 2
			end

			printMaybe("Got datastore:", key)
			datastoreData[key] = data
			success[v.KeyName] = true
			printMaybe(datastoreData)
		end)
	end

	repeat task.wait() until Utils.AllValuesAreTrue(success)

	return datastoreData
end

local playerDatastoreData = {}

events.SetPlayerDatastore.OnServerEvent:Connect(function(player, key, data)
	if not playerDatastoreData[player.UserId] then
		playerDatastoreData[player.UserId] = {}
	end

	playerDatastoreData[player.UserId][key] = data
end)

Players.PlayerRemoving:Connect(function(player)
	if game.PlaceId == 0 then return end

	printMaybe(playerDatastoreData)

	local datastore = DataStoreService:GetDataStore(tostring(player.UserId))

	for key, data in playerDatastoreData[player.UserId] do
		task.spawn(function()

			local waitTime = BASE_RETRY_WAIT_TIME
			while true do
				local s = pcall(function()
					datastore:SetAsync(key, data)
				end)
				if s then break end

				warn(`error while saving datastore "{key}". retrying in {waitTime}s`)
				task.wait(waitTime)
				waitTime *= 2
			end

			printMaybe("Saved datastore:", key)

		end)
	end
end)
