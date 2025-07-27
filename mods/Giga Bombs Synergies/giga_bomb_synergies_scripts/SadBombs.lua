---@param bomb EntityBomb
local function IsActive(bomb)
    return bomb:HasTearFlags(TearFlags.TEAR_SAD_BOMB)
end


TSIL.SaveManager.AddPersistentVariable(
    GigaBombsSynergiesMod,
    "SadBombExplodedFrame",
    -1,
    TSIL.Enums.VariablePersistenceMode.RESET_ROOM
)


---@param bomb EntityBomb
local function OnExplode(bomb)
    GigaBombsSynergiesMod.Helpers.RemoveJustSpawnedEntities(
        EntityType.ENTITY_TEAR
    )

    local rng = TSIL.RNG.NewRNG(bomb.InitSeed)

    local player = TSIL.Players.GetPlayerFromEntity(bomb)
    local tearDamage

    if player then
        tearDamage = player.Damage * 3
    else
        tearDamage = 10
    end

    for angle = 0, 359, 45 do
        local direction = Vector.FromAngle(angle)

        local numTears = TSIL.Random.GetRandomInt(6, 9, rng)

        for _ = 1, numTears, 1 do
            local distanceOffset = TSIL.Random.GetRandomFloat(8, 20, rng)

            local directionPerpendicular = Vector.FromAngle(rng:RandomInt(360))
            local sidesOffset = TSIL.Random.GetRandomFloat(-20, -20, rng)

            local spawningPos = bomb.Position + direction * distanceOffset + directionPerpendicular * sidesOffset
            local spawningVel = direction * TSIL.Random.GetRandomFloat(13, 16, rng)

            local tear = TSIL.EntitySpecific.SpawnTear(
                TearVariant.BLUE,
                0,
                spawningPos,
                spawningVel
            )

            tear.CollisionDamage = tearDamage
            tear.Scale = 1.5
        end
    end

    TSIL.SaveManager.SetPersistentVariable(
        GigaBombsSynergiesMod,
        "SadBombExplodedFrame",
        Game():GetFrameCount()
    )

    if REPENTOGON then
        local room = Game():GetRoom()
        room:SetWaterAmount(1)

        local level = Game():GetLevel()
        local roomDesc = level:GetRoomByIdx(level:GetCurrentRoomIndex())
        roomDesc.Flags = roomDesc.Flags | RoomDescriptor.FLAG_FLOODED
    end
end


GigaBombsSynergiesMod.AddGigaBombSynergy(
    "GigaSadBomb",
    IsActive,
    OnExplode
)


---@param npc EntityNPC
local function OnNPCUpdate(_, npc)
    local sadBombExplodedFrame = TSIL.SaveManager.GetPersistentVariable(
        GigaBombsSynergiesMod,
        "SadBombExplodedFrame"
    )

    local difference = Game():GetFrameCount() - sadBombExplodedFrame

    if sadBombExplodedFrame < 0 or difference > 30 * 10 then return end
    if not npc:IsVulnerableEnemy() then return end
    if npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_FRIENDLY_BALL) then return end

    local rng = npc:GetDropRNG()

    if rng:RandomInt(100) < 2 then return end

    local spawningVel = Vector.FromAngle(rng:RandomInt(360)):Resized(TSIL.Random.GetRandomFloat(0, 1.5, rng))

    local tear = TSIL.EntitySpecific.SpawnTear(
        TearVariant.BLUE,
        0,
        npc.Position,
        spawningVel
    )

    tear.Height = TSIL.Random.GetRandomInt(-600, -500, rng)
    tear.FallingAcceleration = TSIL.Random.GetRandomFloat(2, 4, rng)
    tear.Scale = TSIL.Random.GetRandomFloat(0.7, 1.2, rng)

    tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

    tear.Visible = false

    TSIL.Entities.SetEntityData(
        GigaBombsSynergiesMod,
        tear,
        "IsSadBombFallingTear",
        true
    )
end
GigaBombsSynergiesMod:AddCallback(
    ModCallbacks.MC_NPC_UPDATE,
    OnNPCUpdate
)


---@param tear EntityTear
local function OnTearUpdate(_, tear)
    local isFallingTear = TSIL.Entities.GetEntityData(
        GigaBombsSynergiesMod,
        tear,
        "IsSadBombFallingTear"
    )

    if not isFallingTear then return end

    tear.Visible = true

    if tear.Height >= -60 then
        tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES

        TSIL.Entities.SetEntityData(
            GigaBombsSynergiesMod,
            tear,
            "IsSadBombFallingTear",
            nil
        )
    end
end
GigaBombsSynergiesMod:AddCallback(
    ModCallbacks.MC_POST_TEAR_UPDATE,
    OnTearUpdate
)
