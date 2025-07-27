---@param bomb EntityBomb
local function IsActive(bomb)
    return bomb:HasTearFlags(TearFlags.TEAR_GHOST_BOMB)
end

---@param bomb EntityBomb
local function OnExplode(bomb)
    local player = TSIL.Players.GetPlayerFromEntity(bomb)

    GigaBombsSynergiesMod.Helpers.RemoveJustSpawnedEntities(
        EntityType.ENTITY_EFFECT,
        EffectVariant.HUNGRY_SOUL,
        1
    )

    local haunt = TSIL.Bosses.SpawnBoss(
        EntityType.ENTITY_THE_HAUNT,
        0,
        0,
        bomb.Position,
        nil,
        player
    )

    haunt:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_PERSISTENT)
end

GigaBombsSynergiesMod.AddGigaBombSynergy(
    "GigaGhostBomb",
    IsActive,
    OnExplode
)