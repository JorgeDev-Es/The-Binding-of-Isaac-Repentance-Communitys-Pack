function TSIL.Random.GetRandomElementsFromTable(toChoose, numberOfElements, seedOrRNG)
    local rng
    
    if TSIL.IsaacAPIClass.IsRNG(seedOrRNG) then
        rng = seedOrRNG
    else
        rng = TSIL.RNG.NewRNG(seedOrRNG)
    end

	if numberOfElements == nil then
		numberOfElements = 1
	end

	local tableSize = TSIL.Utils.Tables.Count(toChoose, function (_, _)
		return true
	end)

	local leftInTable = tableSize
	local leftToChoose = numberOfElements

	local choices = {}

	for index, value in pairs(toChoose) do
		if rng:RandomFloat() < leftToChoose/leftInTable then
			table.insert(choices, value)
			leftToChoose = leftToChoose - 1
		end

		leftInTable = leftInTable - 1
	end

	return choices
end