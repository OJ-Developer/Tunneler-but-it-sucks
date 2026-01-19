
return function()
	local list = {}

	for _, item in pairs(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("Music"):WaitForChild("Songs"):GetChildren()) do
		table.insert(list, item.Name)
	end

	return list
end
