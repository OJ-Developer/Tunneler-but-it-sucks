local replicatedStorage = game:GetService("ReplicatedStorage")

local events = replicatedStorage.Events
local createDebugObject = events.Effects.CreateDebugObject


local module = {}

function module.visualiseBlockcast(cframe: CFrame, size: Vector3, direction: Vector3, params: RaycastParams, disable: boolean)	
	createDebugObject:Fire(cframe, size, Enum.PartType.Block, Color3.new(0,0,1), 0)
	createDebugObject:Fire(cframe + direction, size, Enum.PartType.Block, Color3.new(1,0,0), 0)
	
	local blockcast = workspace:Blockcast(cframe, size, direction, params)
	if blockcast then
		createDebugObject:Fire(CFrame.new(direction.Unit * blockcast.Distance + cframe.Position) * cframe.Rotation, size, Enum.PartType.Block, Color3.new(1,1,0), 0)
	end
	
	return blockcast
end

return module
