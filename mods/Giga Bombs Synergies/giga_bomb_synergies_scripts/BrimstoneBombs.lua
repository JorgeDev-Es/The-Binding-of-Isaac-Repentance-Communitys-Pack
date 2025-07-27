---@param bomb EntityBomb
local function IsActive(bomb)
    return bomb:HasTearFlags(TearFlags.TEAR_BRIMSTONE_BOMB)
end


---@param bomb EntityBomb
local function OnExplode(bomb)
    local player = TSIL.Players.GetPlayerFromEntity(bomb)

    if not player then return end

    GigaBombsSynergiesMod.Helpers.RemoveJustSpawnedEntities(EntityType.ENTITY_LASER)

    for i = 0, 359, 90 do
        local laser = TSIL.EntitySpecific.SpawnLaser(
            LaserVariant.THICKER_RED,
            0,
            bomb.Position,
            Vector.Zero,
            player
        )

        laser.AngleDegrees = i
        laser.Timeout = 60
    end
end

GigaBombsSynergiesMod.AddGigaBombSynergy(
    "GigaBrimstoneBomb",
    IsActive,
    OnExplode
)