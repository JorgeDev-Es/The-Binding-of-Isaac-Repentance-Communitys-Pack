function TSIL.Random.GetRandomElementFromWeightedList(seedOrRNG, possibles)
	local rng

	if type(seedOrRNG) == "number" then
		rng = RNG()
		rng:SetSeed(seedOrRNG, 35)
	else
		rng = seedOrRNG
	end

	local totalChance = 0
	for _, possibility in ipairs(possibles) do
		totalChance = totalChance + possibility.chance
	end

	local randomChance = TSIL.Random.GetRandomFloat(0, totalChance, rng)
	local cumulativeChance = 0
	local result = nil

	for _, possibility in ipairs(possibles) do
		cumulativeChance = cumulativeChance + possibility.chance

		if cumulativeChance > randomChance then
			result = possibility.value
			break
		end
	end

	return result
end