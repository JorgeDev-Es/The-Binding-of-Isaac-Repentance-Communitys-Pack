---@param bomb EntityBomb
local function IsActive(bomb)
    return bomb:HasTearFlags(TearFlags.TEAR_SCATTER_BOMB)
end


---@param bomb EntityBomb
local function OnExplode(bomb)
    GigaBombsSynergiesMod.Helpers.RemoveJustSpawnedEntities(
        EntityType.ENTITY_BOMB
    )

    local rng = TSIL.RNG.NewRNG(bomb.InitSeed)

    local numBombs = TSIL.Random.GetRandomInt(3, 4, rng)

    for _ = 1, numBombs, 1 do
        local velAngle = TSIL.Random.GetRandomInt(0, 360, rng)
        local spawnVel = Vector.FromAngle(velAngle):Resized(5)

        local megaBomb = TSIL.EntitySpecific.SpawnBomb(
            BombVariant.BOMB_MR_MEGA,
            0,
            bomb.Position,
            spawnVel
        )

        TSIL.Entities.SetEntityData(
            GigaBombsSynergiesMod,
            megaBomb,
            "IsMegaScatterBomb",
            true
        )
    end
end

GigaBombsSynergiesMod.AddGigaBombSynergy(
    "GigaScatterBomb",
    IsActive,
    OnExplode
)


---@param bomb EntityBomb
local function OnBombExplode(_, bomb)
    local isMegaScatterBomb = TSIL.Entities.GetEntityData(
        GigaBombsSynergiesMod,
        bomb,
        "IsMegaScatterBomb"
    )

    if not isMegaScatterBomb then return end

    local rng = TSIL.RNG.NewRNG(bomb.InitSeed)

    for _ = 1, 2, 1 do
        local velAngle = TSIL.Random.GetRandomInt(0, 360, rng)
        local speed = TSIL.Random.GetRandomFloat(12, 16, rng)
        local spawnVel = Vector.FromAngle(velAngle):Resized(speed)

        local scatterBomb = TSIL.EntitySpecific.SpawnBomb(
            BombVariant.BOMB_NORMAL,
            0,
            bomb.Position,
            spawnVel
        )

        scatterBomb:AddTearFlags(TearFlags.TEAR_SCATTER_BOMB)
    end
end
GigaBombsSynergiesMod:AddCallback(
    TSIL.Enums.CustomCallback.POST_BOMB_EXPLODED,
    OnBombExplode,
    BombVariant.BOMB_MR_MEGA
)