function TSIL.Random.GetRandomInt(min, max, seedOrRNG, exceptions)
    exceptions = exceptions or {}

    local rng
    
    if TSIL.IsaacAPIClass.IsRNG(seedOrRNG) then
        rng = seedOrRNG
    else
        rng = TSIL.RNG.NewRNG(seedOrRNG)
    end

    min = math.ceil(min)
    max = math.floor(max)

    if min > max then
        local oldMin = min
        local oldMax = max
        min = oldMax
        max = oldMin
    end

    local exceptionDictionary = TSIL.Utils.Tables.ConstructDictionaryFromTable(exceptions)
    local randomInt
    
    repeat
        randomInt = rng:RandomInt(max - min + 1) + min
    until not exceptionDictionary[randomInt]

    return randomInt
end