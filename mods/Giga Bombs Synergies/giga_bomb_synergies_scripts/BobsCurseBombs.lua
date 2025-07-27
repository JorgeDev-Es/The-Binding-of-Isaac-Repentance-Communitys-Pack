---@param bomb EntityBomb
local function IsActive(bomb)
    return bomb:HasTearFlags(TearFlags.TEAR_POISON)
end


local function OnExplode()
    GigaBombsSynergiesMod.Helpers.RemoveJustSpawnedEntities(
        EntityType.ENTITY_EFFECT,
        EffectVariant.SMOKE_CLOUD
    )

    local room = Game():GetRoom()
    local centerPos = room:GetCenterPos()

    local smokeCloud = TSIL.EntitySpecific.SpawnEffect(
        GigaBombsSynergiesMod.Constants.EffectVariant.SMOKE_CLOUD,
        0,
        centerPos
    )

    smokeCloud.SpriteScale = Vector(15, 15)
    smokeCloud:SetTimeout(30 * 20)
    smokeCloud.DepthOffset = 6000

    local color = Color(1, 1, 1, 0, 0, 0, 0)
    color:SetColorize(0, 1, 0, 1)
    smokeCloud.Color = color
end


GigaBombsSynergiesMod.AddGigaBombSynergy(
    "GigaBobsCurseBomb",
    IsActive,
    OnExplode
)


---@param effect EntityEffect
local function OnSmokeCloudUpdate(_, effect)
    if effect.Timeout <= 0 then
        if effect.Color.A <= 0 then
            effect:Remove()
            return
        end

        local color = Color(1, 1, 1, effect.Color.A - 0.1, 0, 0, 0)
        color:SetColorize(0, 1, 0, 1)

        effect.Color = color
        return
    end

    if effect.Color.A < 0.8 then
        local color = Color(1, 1, 1, effect.Color.A + 0.1, 0, 0, 0)
        color:SetColorize(0, 1, 0, 1)

        effect.Color = color
    end

    if effect.FrameCount % 6 ~= 0 then return end

    local npcs = TSIL.EntitySpecific.GetNPCs(-1, -1, -1, true)

    local damageableNpcs = TSIL.Utils.Tables.Filter(npcs, function(_, npc)
        return npc:IsVulnerableEnemy() and
        not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_FRIENDLY_BALL)
    end)

    TSIL.Utils.Tables.ForEach(damageableNpcs, function(_, npc)
        npc:TakeDamage(10, 0, EntityRef(effect), -1)
    end)
end
GigaBombsSynergiesMod:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    OnSmokeCloudUpdate,
    GigaBombsSynergiesMod.Constants.EffectVariant.SMOKE_CLOUD
)