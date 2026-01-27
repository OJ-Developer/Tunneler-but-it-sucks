local radio = {}
radio.__index = radio

function radio.new(radioObject)
	local radioTable = setmetatable({Instance = radioObject}, radio)
	
	radioTable.mainThread = task.spawn(function()
		local found = false
		local started = false
		
		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances = {workspace.Map.Elements}
		
		while task.wait(0.5) do
			found = false
			for _, part in pairs(workspace:GetPartsInPart(radioObject, params)) do
				if part.Name == "RadioSignal" then
					found = true
					radioObject.ParticalAttachment.ParticleEmitter.Color = ColorSequence.new(Color3.new(0, 1, 0))
					if radioObject:FindFirstChild("Sound") then
						radioObject.Sound.Volume = 2
					end
					if started then continue end
					started = true
					local sound = part.Sound:Clone()
					sound.Parent = radioObject
					sound:Play()
					if sound.Looped then continue end
					task.spawn(radioTable:EndRadioSignal())
				end
			end
			if found then continue end
			radioObject.ParticalAttachment.ParticleEmitter.Color = ColorSequence.new(Color3.new(1, 0, 0))
			if radioObject:FindFirstChild("Sound") then
				radioObject.Sound.Volume = 0
			end
		end
	end)
	
	return radioTable
end

function radio:EndRadioSignal()
	task.wait(self.Instance.Sound.TimeLength)
	self.Instance.ParticalAttachment:Destroy()
	self:Cleanup()
end

function radio:Cleanup()
	task.cancel(self.mainThread)
end

return radio
