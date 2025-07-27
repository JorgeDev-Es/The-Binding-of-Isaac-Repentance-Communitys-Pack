local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local params = ProjectileParams()
params.Variant = ProjectileVariant.PROJECTILE_PUKE
params.Color = mod.Colors.CageProj
params.FallingSpeedModifier = -5
params.FallingAccelModifier = 1

local params2 = ProjectileParams()
params2.Variant = ProjectileVariant.PROJECTILE_PUKE
params2.Color = mod.Colors.CageProj

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    local sprite = npc:GetSprite()
    local rng = npc:GetDropRNG()

    if sprite:GetFrame() == 0 
    and npc.SubType ~= 1 
    and (sprite:GetAnimation() == "Jumping" or sprite:GetAnimation() == "RollStart")
    and rng:RandomFloat() <= 0.4 
    and mod:GetEntityCount(mod.ENT.CageVis.ID, mod.ENT.CageVis.Var) <= 0 then
        npc.State = NpcState.STATE_SUMMON
    end
end, EntityType.ENTITY_CAGE)

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant == mod.ENT.CageVis.Var then
        local sprite = npc:GetSprite()
        local data = npc:GetData()
        local rng = npc:GetDropRNG()

        if not data.Init then
            if npc.SpawnerEntity and npc.SpawnerEntity.Type == EntityType.ENTITY_CAGE and npc.SpawnerEntity.SubType == 2 then
                for i = 0, 1 do
                    mod:ReplaceEnemySpritesheet(npc, "gfx/monsters/classic/monster_176_cagevis_pink.png", i)
                end
            end
            data.Creeping = -1
            data.Shooting = -1
            npc.SplatColor = mod.Colors.CageSplat
            data.Init = true
        end

        if npc.State == NpcState.STATE_ATTACK2 then
            npc.State = NpcState.STATE_ATTACK
            if npc.V1.X ~= 0 then
                data.AnimSuffix = "Horiz"
            else
                data.AnimSuffix = (npc.V1.Y < 0) and "Up" or "Down"
            end

        elseif npc.State == NpcState.STATE_ATTACK then
            if sprite:IsFinished("Attack03"..data.AnimSuffix) then
                npc.State = NpcState.STATE_IDLE
            elseif sprite:IsEventTriggered("Spew") then
                data.Creeping = 6
                data.Shooting = 16
                mod:PlaySound(SoundEffect.SOUND_HEARTIN, npc)
                mod:PlaySound(SoundEffect.SOUND_HEARTOUT, npc)
            else
                mod:SpritePlay(sprite, "Attack03"..data.AnimSuffix)
            end
        end

        if data.Creeping and data.Creeping >= 0 then
            local pos = npc.Position + npc.V1:Resized(20 + (30 * (6 - data.Creeping)))
            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, pos, Vector.Zero, npc)
            creep.Color = mod.Colors.CageCreep
            creep:Update()
            local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, pos, Vector.Zero, npc)
            splat.Color = mod.Colors.CageCreep
            splat:Update()
            data.Creeping = data.Creeping - 1
        end

        if data.Shooting and data.Shooting >= 0 then
            if data.Shooting % 2 == 0 then
                params.Scale = mod:RandomInt(7,13,rng) * 0.1
                npc:FireProjectiles(npc.Position, npc.V1:Resized(mod:RandomInt(11,14,rng)):Rotated(mod:RandomInt(-12,12,rng)), 0, params)
                mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 1, 0.75)
            end
            data.Shooting = data.Shooting - 1
        end
    end
end, EntityType.ENTITY_VIS)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, npc)
    if npc.Variant == mod.ENT.CageVis.Var then
        for _, cage in pairs(Isaac.FindByType(EntityType.ENTITY_CAGE)) do
            cage = cage:ToNPC()
            if cage.Position:Distance(npc.Position) <= cage.Size + npc.Size + 10 and cage.State == NpcState.STATE_ATTACK then
                npc:ToNPC():FireProjectiles(npc.Position, Vector(10,0), ProjectileMode.CIRCLE_EIGHT, params2)
                local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, npc.Position, Vector.Zero, npc):ToEffect()
                creep.Color = mod.Colors.CageCreep
                creep.SpriteScale = Vector(3,3)
                creep:SetTimeout(300)
                creep:Update()
                npc:Kill()
                break
            end
        end
    end
end, EntityType.ENTITY_VIS)

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, type, var, sub, pos, vel, spawner, seed)
    if type == EntityType.ENTITY_VIS
    and spawner 
    and spawner.Type == EntityType.ENTITY_CAGE then
        return {mod.ENT.CageVis.ID, mod.ENT.CageVis.Var, mod.ENT.CageVis.Sub, seed}
    --[[elseif type == EntityType.ENTITY_EFFECT
    and var == EffectVariant.CRACKWAVE
    and sub == 0 
    and spawner 
    and spawner.Type == EntityType.ENTITY_CAGE then
        return {EntityType.ENTITY_EFFECT, EffectVariant.CRACKWAVE, 2, seed}]]
    end
end)