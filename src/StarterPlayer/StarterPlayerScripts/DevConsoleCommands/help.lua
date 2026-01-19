return function()
	local list = {}

	for _, item in pairs(script.Parent:GetChildren()) do
		table.insert(list, item.Name)
	end

	return list
end