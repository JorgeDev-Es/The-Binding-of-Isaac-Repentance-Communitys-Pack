local BOSSES_THAT_REQUIRE_MULTIPLE_SPAWNS = {
    [EntityType.ENTITY_LARRYJR] = true,
    [EntityType.ENTITY_CHUB] = true,
    [EntityType.ENTITY_LOKI] = true,
    [EntityType.ENTITY_GURGLE] = true,
    [EntityType.ENTITY_TURDLET] = true,
}

local DEFAULT_BOSS_MULTI_SEGMENTS = 4

local function getNumBossSegments(entityType, variant, numSegments)
    if numSegments ~= nil then
        return numSegments
    end

    if entityType == EntityType.ENTITY_CHUB then
        return 3
    elseif entityType == EntityType.ENTITY_LOKI then
        if variant == TSIL.Enums.LokiVariant.LOKII then
            return 2
        else
            return 1
        end
    elseif entityType == EntityType.ENTITY_GURGLING then
        return 2
    else
        return DEFAULT_BOSS_MULTI_SEGMENTS
    end
end


function TSIL.Bosses.SpawnBoss(entityType, variant, subType, position, velocity, spawner, seedOrRNG, numSegments)
    velocity = velocity or Vector.Zero

    local seed

    if seedOrRNG ~= nil and TSIL.IsaacAPIClass.IsRNG(seedOrRNG) then
        seed = seedOrRNG:Next()
    else
        seed = seedOrRNG
    end

    local boss = TSIL.EntitySpecific.SpawnNPC(entityType, variant, subType, position, velocity, spawner, seed)

    if BOSSES_THAT_REQUIRE_MULTIPLE_SPAWNS[boss.Type] then
        if not numSegments then
            numSegments = getNumBossSegments(entityType, variant, subType)
        end

        local remainingSegments = numSegments - 1

        for _ = 1, remainingSegments do
            TSIL.EntitySpecific.SpawnNPC(entityType, variant, subType, position, velocity, spawner, seed)
        end
    end

    return boss
end

