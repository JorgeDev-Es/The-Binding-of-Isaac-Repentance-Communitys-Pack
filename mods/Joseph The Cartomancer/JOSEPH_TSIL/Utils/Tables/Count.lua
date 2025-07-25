function TSIL.Utils.Tables.Count(toCount, predicate)
	if predicate == nil then
		predicate = function() return true end
   end

	local filtered = TSIL.Utils.Tables.Filter(toCount, predicate)

	local count = 0
	for _, _ in pairs(filtered) do
		count = count + 1
	end

	return count
end