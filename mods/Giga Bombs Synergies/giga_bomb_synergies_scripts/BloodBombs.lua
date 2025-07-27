TSIL.SaveManager.AddPersistentVariable(
    GigaBombsSynergiesMod,
    "BloodFloodedRooms",
    {},
    TSIL.Enums.VariablePersistenceMode.RESET_LEVEL
)

---@param bomb EntityBomb
local function IsActive(bomb)
    return bomb:HasTearFlags(TearFlags.TEAR_BLOOD_BOMB)
end


---@param bomb EntityBomb
local function OnExplode(bomb)
    local rng = TSIL.RNG.NewRNG(bomb.InitSeed)

    local numTears = TSIL.Random.GetRandomInt(60, 90, rng)

    for _ = 1, numTears, 1 do
        local velAngle = TSIL.Random.GetRandomInt(0, 360, rng)
        local speed = TSIL.Random.GetRandomFloat(8, 12, rng)
        local spawnVel = Vector.FromAngle(velAngle):Resized(speed)

        local tear = TSIL.EntitySpecific.SpawnTear(
            TearVariant.BLOOD,
            0,
            bomb.Position,
            spawnVel
        )

        tear.Scale = tear.Scale + TSIL.Random.GetRandomFloat(-0.1, 0.2, rng)
        tear:ResetSpriteScale()

        tear.FallingSpeed = -TSIL.Random.GetRandomFloat(10, 16, rng)
        tear.FallingAcceleration = TSIL.Random.GetRandomFloat(1, 1.2, rng)

        TSIL.Entities.SetEntityData(
            GigaBombsSynergiesMod,
            tear,
            "GigaBloodBombTear",
            true
        )
    end

    local npcs = TSIL.EntitySpecific.GetNPCs()
    local vulnerableEnemies = TSIL.Utils.Tables.Filter(npcs, function (_, npc)
        return npc:IsVulnerableEnemy() and npc:IsActiveEnemy(false) and not
        npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_FRIENDLY_BALL | EntityFlag.FLAG_CHARM)
    end)
    TSIL.Utils.Tables.ForEach(vulnerableEnemies, function (_, npc)
        TSIL.Entities.SetEntityData(
            GigaBombsSynergiesMod,
            npc,
            "IsBleedingOutFromBomb",
            true
        )
        npc:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
    end)

    if REPENTOGON then
        local room = Game():GetRoom()
        local fxParams = room:GetFXParams()
        fxParams.WaterColor = KColor(100/255, 0, 0, 0.7)

        room:SetWaterAmount(1)

        local level = Game():GetLevel()
        local roomDesc = level:GetRoomByIdx(level:GetCurrentRoomIndex())
        roomDesc.Flags = roomDesc.Flags | RoomDescriptor.FLAG_FLOODED

        local bloodFloodedRooms = TSIL.SaveManager.GetPersistentVariable(
            GigaBombsSynergiesMod,
            "BloodFloodedRooms"
        )
        bloodFloodedRooms[roomDesc.ListIndex] = true
    end
end


GigaBombsSynergiesMod.AddGigaBombSynergy(
    "GigaBloodBomb",
    IsActive,
    OnExplode,
    nil,
    "GigaBloodBomb"
)


---@param tear EntityTear
local function OnTearRemove(_, tear)
    if TSIL.Rooms.IsLeavingRoom() then return end

    if TSIL.Entities.GetEntityData(GigaBombsSynergiesMod, tear, "GigaBloodBombTear") then
        TSIL.EntitySpecific.SpawnEffect(
            EffectVariant.PLAYER_CREEP_RED,
            0,
            tear.Position
        )
    end
end
GigaBombsSynergiesMod:AddCallback(
    ModCallbacks.MC_POST_ENTITY_REMOVE,
    OnTearRemove,
    EntityType.ENTITY_TEAR
)


---@param npc EntityNPC
local function OnNPCDeath(_, npc)
    local isBleedingOutFromBomb = TSIL.Entities.GetEntityData(
        GigaBombsSynergiesMod,
        npc,
        "IsBleedingOutFromBomb"
    )

    if npc:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) and isBleedingOutFromBomb then
        TSIL.EntitySpecific.SpawnPickup(
            PickupVariant.PICKUP_HEART,
            HeartSubType.HEART_FULL,
            npc.Position
        )
    end
end
GigaBombsSynergiesMod:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    OnNPCDeath
)


if REPENTOGON then
    local function OnNewRoom()
        local level = Game():GetLevel()
        local roomDesc = level:GetRoomByIdx(level:GetCurrentRoomIndex())

        local bloodFloodedRooms = TSIL.SaveManager.GetPersistentVariable(
            GigaBombsSynergiesMod,
            "BloodFloodedRooms"
        )
        if bloodFloodedRooms[roomDesc.ListIndex] then
            local room = Game():GetRoom()
            local fxParams = room:GetFXParams()
            fxParams.WaterColor = KColor(100/255, 0, 0, 0.7)
        end
    end
    GigaBombsSynergiesMod:AddCallback(
        ModCallbacks.MC_POST_NEW_ROOM,
        OnNewRoom
    )
end