---@param bomb EntityBomb
local function IsActive(bomb)
    return bomb:HasTearFlags(TearFlags.TEAR_GLITTER_BOMB)
end


---@param bomb EntityBomb
---@param rng RNG
local function SpawnRandomPickups(bomb, rng)
    local pickupsToSpawn = TSIL.Random.GetRandomInt(20, 25, rng)

    for _ = 1, pickupsToSpawn, 1 do
        local spawningVel = Vector(1, 0)
        spawningVel = spawningVel:Rotated(rng:RandomInt(360))
        spawningVel = spawningVel:Resized(TSIL.Random.GetRandomFloat(18, 22, rng))

        TSIL.EntitySpecific.SpawnPickup(
            PickupVariant.PICKUP_NULL,
            TSIL.Enums.PickupNullSubType.EXCLUDE_COLLECTIBLES_TRINKETS_CHESTS,
            bomb.Position + spawningVel * 2,
            spawningVel
        )
    end
end


---@param bomb EntityBomb
---@param rng RNG
local function SpawnGreedParticles(bomb, rng)
    local pickupsToSpawn = TSIL.Random.GetRandomInt(40, 60, rng)

    for _ = 1, pickupsToSpawn, 1 do
        local spawningVel = Vector(1, 0)
        spawningVel = spawningVel:Rotated(rng:RandomInt(360))
        spawningVel = spawningVel:Resized(TSIL.Random.GetRandomFloat(10, 15, rng))

        local particle = TSIL.EntitySpecific.SpawnEffect(
            EffectVariant.TOOTH_PARTICLE,
            0,
            bomb.Position,
            spawningVel
        )

        local sprite = particle:GetSprite()
        sprite:ReplaceSpritesheet(0, "gfx/effects/greedy_gibs.png")
        sprite:LoadGraphics()
    end
end

---@param bomb EntityBomb
local function OnExplode(bomb)
    local rng = TSIL.RNG.NewRNG(bomb.InitSeed)

    SpawnRandomPickups(bomb, rng)

    GigaBombsSynergiesMod.Helpers.AddTemporarySchedule(SpawnRandomPickups, 2, bomb, rng)

    local crater = TSIL.EntitySpecific.SpawnEffect(
        EffectVariant.BOMB_CRATER,
        0,
        bomb.Position
    )
    local goldColor = Color(0.9, 0.8, 0, 1, 0.8, 0.7, 0)
    crater:SetColor(goldColor, 150, 1, false, false)
    local craterSprite = crater:GetSprite()
    craterSprite.Scale = (Vector.One * 2.5)

    SpawnGreedParticles(bomb, rng)
end

GigaBombsSynergiesMod.AddGigaBombSynergy(
    "GigaGlitterBomb",
    IsActive,
    OnExplode,
    nil,
    "GigaGlitterBomb"
)
