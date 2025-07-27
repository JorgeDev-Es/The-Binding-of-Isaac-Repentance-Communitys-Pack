---@param bomb EntityBomb
local function IsActive(bomb)
    return bomb:HasTearFlags(TearFlags.TEAR_STICKY)
end


---@param bomb EntityBomb
local function OnExplode(bomb)
    SFXManager():Play(SoundEffect.SOUND_MEGA_INFESTED)

    GigaBombsSynergiesMod.Helpers.RemoveJustSpawnedEntities(
        EntityType.ENTITY_EFFECT,
        EffectVariant.PLAYER_CREEP_WHITE
    )

    local creep = TSIL.EntitySpecific.SpawnEffect(
        EffectVariant.PLAYER_CREEP_WHITE,
        0,
        bomb.Position
    )

    creep:Update()
    creep:SetTimeout(600)

    local chosenAnim = math.random(6)
    creep:GetSprite():Play("BiggestBlood0" .. chosenAnim, true)
    creep.SpriteScale = Vector(0, 0)

    TSIL.Entities.SetEntityData(
        GigaBombsSynergiesMod,
        creep,
        "IsGrowinCreep",
        true
    )
end


GigaBombsSynergiesMod.AddGigaBombSynergy(
    "GigaSackBomb",
    IsActive,
    OnExplode
)


---@param creep EntityEffect
local function OnWhiteCreepUpdate(_, creep)
    local isGrowingCreep = TSIL.Entities.GetEntityData(
        GigaBombsSynergiesMod,
        creep,
        "IsGrowinCreep"
    )

    if not isGrowingCreep then return end

    local xScale = creep.SpriteScale.X

    if xScale >= 50 then
        TSIL.Entities.SetEntityData(
            GigaBombsSynergiesMod,
            creep,
            "IsGrowinCreep",
            nil
        )

        return
    end

    xScale = xScale + 0.2
    creep.SpriteScale = Vector(xScale, xScale)

    if creep.FrameCount % 5 == 0 then
        local enemies = Isaac.FindInRadius(creep.Position, 60 * xScale, EntityPartition.ENEMY)

        TSIL.Utils.Tables.ForEach(enemies, function(_, enemy)
            if enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY_BALL) then return end
            if not enemy:IsVulnerableEnemy() then return end

            enemy:AddFreeze(EntityRef(creep), 600)

            local isAlreadyTakingDamage = TSIL.Entities.GetEntityData(
                GigaBombsSynergiesMod,
                enemy,
                "IsTakingSackDamage"
            )

            if isAlreadyTakingDamage then return end

            TSIL.Entities.SetEntityData(
                GigaBombsSynergiesMod,
                enemy,
                "IsTakingSackDamage",
                true
            )

            TSIL.Entities.SetEntityData(
                GigaBombsSynergiesMod,
                enemy,
                "InitialSackHealth",
                math.floor(enemy.HitPoints)
            )

            TSIL.Entities.SetEntityData(
                GigaBombsSynergiesMod,
                enemy,
                "InitialSackFrame",
                Game():GetFrameCount()
            )
        end)
    end
end
GigaBombsSynergiesMod:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    OnWhiteCreepUpdate,
    EffectVariant.PLAYER_CREEP_WHITE
)


local function OnUpdate()
    local npcs = TSIL.EntitySpecific.GetNPCs()

    TSIL.Utils.Tables.ForEach(npcs, function(_, npc)
        local isTakingDamage = TSIL.Entities.GetEntityData(
            GigaBombsSynergiesMod,
            npc,
            "IsTakingSackDamage"
        )

        if not isTakingDamage then return end

        local initialFrame = TSIL.Entities.GetEntityData(
            GigaBombsSynergiesMod,
            npc,
            "InitialSackFrame"
        )
        local currentFrameCount = Game():GetFrameCount()
        local differenceFrames = currentFrameCount - initialFrame

        if differenceFrames > 10 * 30 then
            TSIL.Entities.SetEntityData(
                GigaBombsSynergiesMod,
                npc,
                "IsTakingSackDamage",
                nil
            )

            TSIL.Entities.SetEntityData(
                GigaBombsSynergiesMod,
                npc,
                "InitialSackFrame",
                nil
            )

            TSIL.Entities.SetEntityData(
                GigaBombsSynergiesMod,
                npc,
                "InitialSackFrame",
                nil
            )
        end

        if differenceFrames % 30 ~= 0 then return end

        npc:TakeDamage(10, 0, EntityRef(npc), 0)
    end)
end
GigaBombsSynergiesMod:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    OnUpdate
)

local function SpawnCharmedSpider(spiderType, npc)
    local spider = TSIL.Entities.Spawn(
        spiderType,
        0,
        0,
        npc.Position
    )

    spider:AddEntityFlags(EntityFlag.FLAG_FRIENDLY_BALL | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM | EntityFlag.FLAG_PERSISTENT)
end


---@param npc EntityNPC
local function OnNPCDeath(_, npc)
    local isTakingDamage = TSIL.Entities.GetEntityData(
        GigaBombsSynergiesMod,
        npc,
        "IsTakingSackDamage"
    )

    if not isTakingDamage then return end

    local initialHealth = TSIL.Entities.GetEntityData(
        GigaBombsSynergiesMod,
        npc,
        "InitialSackHealth"
    )

    if initialHealth > 50 then
        initialHealth = 50
    end

    while initialHealth > 5 do
        SpawnCharmedSpider(EntityType.ENTITY_BIGSPIDER, npc)

        initialHealth = initialHealth - 5
    end

    while initialHealth > 3 do
        SpawnCharmedSpider(EntityType.ENTITY_SPIDER, npc)

        initialHealth = initialHealth - 3
    end

    while initialHealth > 1 do
        SpawnCharmedSpider(EntityType.ENTITY_SWARM_SPIDER, npc)

        initialHealth = initialHealth - 1
    end
end
GigaBombsSynergiesMod:AddCallback(
    ModCallbacks.MC_POST_NPC_DEATH,
    OnNPCDeath
)
