
return function()
	local list = {}

	for _, item in pairs(game:GetService("ReplicatedStorage"):WaitForChild("Objects"):GetChildren()) do
		table.insert(list, item.Name)
	end

	return list
end

