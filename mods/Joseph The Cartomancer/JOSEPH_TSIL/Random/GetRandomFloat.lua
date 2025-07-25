function TSIL.Random.GetRandomFloat(min, max, seedOrRNG)
    if min > max then
        local oldMin = min
        local oldMax = max
        min = oldMax
        max = oldMin
    end

    return min + TSIL.Random.GetRandom(seedOrRNG) * (max - min)
end