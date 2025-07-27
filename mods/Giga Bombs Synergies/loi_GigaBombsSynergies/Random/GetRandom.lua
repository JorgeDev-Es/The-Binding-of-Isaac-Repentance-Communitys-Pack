function TSIL.Random.GetRandom(seedOrRNG)
    local rng

    if TSIL.IsaacAPIClass.IsRNG(seedOrRNG) then
        rng = seedOrRNG
    else
        rng = TSIL.RNG.NewRNG(seedOrRNG)
    end

    return rng:RandomFloat()
end