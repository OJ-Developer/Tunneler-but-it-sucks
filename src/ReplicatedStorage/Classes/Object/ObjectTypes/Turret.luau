local ReplicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local Sounds = require(ReplicatedStorage.Data.Sounds)
local AudioService = require(ReplicatedStorage.Services.AudioService)

local module = {}
module.__index = module

function module.new(turretModel)
	local newTurret = setmetatable({connections = {}}, module)
	
	local body = turretModel.Body
	local left = body.Left
	local right = body.Right
	local leftArm = left.Arm
	local rightArm = right.Arm
	local leftBarrel = left.Barrel
	local rightBarrel = right.Barrel
	local stand = body.Stand
	
	local leftPos: Attachment = body.LeftPos
	local rightPos: Attachment = body.RightPos
	
	local visionHitbox: Part = turretModel.VisionHitbox:Clone()
	turretModel.VisionHitbox:Destroy()
	visionHitbox.Parent = workspace.Map.Other
	
	local player = game.Players.LocalPlayer
	local char = player.Character
	local targetPart = char.Head
	
	local timeInTurretVision = 0
	local alarmCounter = 0
	local fireCounter = 0
	
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {char}
	
	table.insert(newTurret.connections, runService.PreRender:Connect(function(dtime)
		body:PivotTo(turretModel.CFrame * turretModel.PivotOffset)
		visionHitbox:PivotTo(turretModel.CFrame * turretModel.PivotOffset)
		stand:PivotTo(turretModel.CFrame * turretModel.PivotOffset)
		
		local partsInVisionHitbox = workspace:GetPartsInPart(visionHitbox, params)
		
		if #partsInVisionHitbox > 0 then 
			timeInTurretVision += dtime
			alarmCounter += dtime
			if timeInTurretVision > 1 then
				fireCounter += dtime
			end
			
			left:PivotTo(CFrame.lookAt(leftPos.WorldPosition, targetPart.Position))
			right:PivotTo(CFrame.lookAt(rightPos.WorldPosition, targetPart.Position))
			
			if alarmCounter > 0.4 then
				AudioService.PlaySoundEffect(Sounds.SoundEffects.PlaceHolder)
				alarmCounter -= 0.4
			end
			if fireCounter > 0.1 then
				AudioService.PlaySoundEffect(Sounds.SoundEffects.GunFire)
				fireCounter -= 0.1
			end
		else
			timeInTurretVision = 0
			left:PivotTo(leftPos.WorldCFrame)
			right:PivotTo(rightPos.WorldCFrame)
		end
	end))
	
	return newTurret
end

function module:Cleanup()
	for _, v in self.connections do
		v:Disconnect()
	end
end

return module