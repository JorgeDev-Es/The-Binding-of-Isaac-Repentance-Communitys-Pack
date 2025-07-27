function TSIL.Entities.Spawn(entityType, variant, subType, position, velocity, spawner, seedOrRNG)
    velocity = velocity or Vector.Zero

    if seedOrRNG == nil then
        return Isaac.Spawn(entityType, variant, subType, position, velocity, spawner)
    end

    local seed

    if TSIL.IsaacAPIClass.IsRNG(seedOrRNG) then
        seed = seedOrRNG:Next()
    else
        seed = seedOrRNG
    end

    return Game():Spawn(entityType, variant, position, velocity, spawner, subType, seed)
end