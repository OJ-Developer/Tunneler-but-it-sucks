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

function module.merge(table1: {any}, table2: {any})
	local newTable = table.clone(table1)
	for _, v in pairs(table2) do
		table.insert(newTable, v)
	end
	return newTable
end

return module