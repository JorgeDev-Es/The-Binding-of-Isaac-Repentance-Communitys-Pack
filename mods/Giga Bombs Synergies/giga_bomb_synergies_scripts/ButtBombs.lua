local FART_SOUND_DURATION = 5.5 * 30

---@param bomb EntityBomb
local function IsActive(bomb)
    return bomb:HasTearFlags(TearFlags.TEAR_BUTT_BOMB)
end


---@param bomb EntityBomb
local function OnExplode(bomb)
    local npcs = TSIL.EntitySpecific.GetNPCs()
    local filteredNpcs = TSIL.Utils.Tables.Filter(npcs, function(_, npc)
        return npc:IsVulnerableEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
    end)
    TSIL.Utils.Tables.ForEach(filteredNpcs, function(_, npc)
        npc:ClearEntityFlags(EntityFlag.FLAG_CONFUSION)

        TSIL.Entities.SetEntityData(
            GigaBombsSynergiesMod,
            npc,
            "ButtInfiniteWeakness",
            true
        )

        if npc:IsBoss() then
            npc:AddFreeze(EntityRef(bomb), 9999)
        else
            npc:AddFreeze(EntityRef(bomb), 10)
            TSIL.Entities.SetEntityData(
                GigaBombsSynergiesMod,
                npc,
                "ButtInfiniteFreeze",
                true
            )
        end
    end)

    local fart = TSIL.EntitySpecific.SpawnEffect(
        EffectVariant.FART,
        0,
        bomb.Position
    )
    fart.SpriteScale = Vector.One * 2
    fart.Color = Color(1.8, 0.7, 1.5, 1)
    SFXManager():Play(SoundEffect.SOUND_FART_MEGA)

    local butterFart = TSIL.EntitySpecific.SpawnEffect(
        EffectVariant.FART,
        0,
        bomb.Position
    )
    butterFart.Color = Color(1.8, 0.7, 1.5, 1)
    TSIL.Entities.SetEntityData(
        GigaBombsSynergiesMod,
        butterFart,
        "ButterFartStartingFrame",
        Game():GetFrameCount()
    )
    SFXManager():Stop(SoundEffect.SOUND_FART)
end


GigaBombsSynergiesMod.AddGigaBombSynergy(
    "GigaButtBomb",
    IsActive,
    OnExplode,
    nil,
    "GigaButtBomb"
)


---@param npc EntityNPC
local function OnNPCUpdate(_, npc)
    local infinteWeakness = TSIL.Entities.GetEntityData(
        GigaBombsSynergiesMod,
        npc,
        "ButtInfiniteWeakness"
    )
    local infinteFreeze = TSIL.Entities.GetEntityData(
        GigaBombsSynergiesMod,
        npc,
        "ButtInfiniteFreeze"
    )

    if infinteWeakness then
        npc:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
    end

    if infinteFreeze then
        npc:AddFreeze(EntityRef(npc), 10)
    end
end
GigaBombsSynergiesMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, OnNPCUpdate)


---@param fart EntityEffect
local function OnFartUpdate(_, fart)
    local startingFrame = TSIL.Entities.GetEntityData(
        GigaBombsSynergiesMod,
        fart,
        "ButterFartStartingFrame"
    )

    if not startingFrame then return end

    if fart.FrameCount ~= 10 then return end

    local duration = Game():GetFrameCount() - startingFrame

    if duration < FART_SOUND_DURATION then
        local butterFart = TSIL.EntitySpecific.SpawnEffect(
            EffectVariant.FART,
            0,
            fart.Position
        )
        butterFart.Color = Color(1.8, 0.7, 1.5, 1)
        TSIL.Entities.SetEntityData(
            GigaBombsSynergiesMod,
            butterFart,
            "ButterFartStartingFrame",
            startingFrame
        )
        butterFart.SpriteScale = fart.SpriteScale * 0.9
        SFXManager():Stop(SoundEffect.SOUND_FART)
    end
end
GigaBombsSynergiesMod:AddCallback(
    ModCallbacks.MC_POST_EFFECT_UPDATE,
    OnFartUpdate,
    EffectVariant.FART
)