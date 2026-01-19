local HttpService = game:GetService("HttpService")

local LinkedData = {}
LinkedData._Data = {}

function LinkedData.Set(object: Instance, key: string, value: any)
	if not object:GetAttribute("UniqueId") then
		object:SetAttribute("UniqueId", HttpService:GenerateGUID(false))
		LinkedData._Data[object:GetAttribute("UniqueId")] = {[key] = value}
	else
		LinkedData._Data[object:GetAttribute("UniqueId")][key] = value
	end
end

function LinkedData.Remove(object: Instance, key: string)
	LinkedData._Data[object:GetAttribute("UniqueId")][key] = nil
end

function LinkedData.Clear(object: Instance)
	LinkedData._Data[object:GetAttribute("UniqueId")] = nil
end

function LinkedData.Get(object: Instance, key: string?)
	if key then
		return LinkedData._Data[object:GetAttribute("UniqueId")][key]
	else
		return LinkedData._Data[object:GetAttribute("UniqueId")]
	end
end

return LinkedData
