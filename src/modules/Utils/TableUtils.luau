local module = {}

function module.contains(haystack: {any}, needle: any | {any})
	for _, v in pairs(haystack) do
		if type(needle) == "table" then
			if module.contains(needle, v) then
				return true
			end
		else
			if v == needle then
				return true
			end
		end
	end
	return false
end

function module.hasIndex(haystack: {any}, needle: any)
	for i in pairs(haystack) do
		if i == needle then
			return true
		end
	end
	return false
end

function module.merge(...: {any})
	local newTable = {}
	for _, t in {...} do
		for _, v in t do
			table.insert(newTable, v)
		end
	end
	return newTable
end

return module