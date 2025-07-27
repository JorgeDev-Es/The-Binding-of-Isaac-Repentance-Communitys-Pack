local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local params = ProjectileParams()
params.Color = mod.Colors.DankBlack
params.CircleAngle = 20
params.Scale = 1.5

local params2 = ProjectileParams()
params2.Color = mod.Colors.DankBlack
params2.BulletFlags = ProjectileFlags.BOUNCE
params2.Scale = 2
params2.FallingAccelModifier = -0.08

local bal = {
    slideChance = 0.5,
    slideSpeed = 15,
    slideDuration = 30,
}

local function MakeTarPuddle(npc, duration)
    duration = duration or 300
    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_BLACK, 0, npc.Position, Vector.Zero, npc):ToEffect()
    creep.SpriteScale = Vector(3,3)
    creep:SetTimeout(duration)
    creep:Update()
    return creep
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if not ReworkedFoes then
        local sprite = npc:GetSprite()
        local data = npc:GetData()

        if npc.Variant == 0 then
            if npc.State == NpcState.STATE_STOMP then
                if sprite:IsEventTriggered("Shoot") then
                    local suckers = {}
                    for _, sucker in pairs(Isaac.FindByType(EntityType.ENTITY_SUCKER, 0)) do
                        if sucker.FrameCount <= 0 and sucker.SpawnerEntity and sucker.SpawnerEntity.InitSeed == npc.InitSeed then
                            table.insert(suckers, sucker)
                        end
                    end
                    local angle = (npc.SubType == 1) and 180 or 90
                    for i, sucker in pairs(suckers) do
                        sucker.Position = npc.Position + Vector.FromAngle(i * angle):Resized(40)
                    end
                end
            end
        
        elseif npc.Variant == 1 then
            if sprite:IsEventTriggered("Land") then
                for _, sucker in pairs(Isaac.FindByType(EntityType.ENTITY_SUCKER)) do
                    if sucker.FrameCount > 0 and sucker.Position:Distance(npc.Position) < npc.Size + sucker.Size + 10 then
                        sucker:Kill()
                    end
                end
            end

            if npc.State == NpcState.STATE_MOVE then
                if sprite:IsEventTriggered("Land") then
                    if npc.HitPoints < npc.MaxHitPoints * 0.5 then
                        if npc:GetDropRNG():RandomFloat() <= bal.slideChance then
                            sprite:Play("SlideStart", true)
                            data.Sliding = true
                            data.SlideSpeed = bal.slideSpeed
                            npc.Velocity = npc.Velocity:Resized(data.SlideSpeed)
                            npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                            npc.StateFrame = bal.slideDuration
                            npc.State = NpcState.STATE_ATTACK2
                        end
                    end
                    MakeTarPuddle(npc, 120)
                end

            elseif npc.State == NpcState.STATE_ATTACK then
                if sprite:IsEventTriggered("Shoot") then
                    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 5, npc.Position, Vector.Zero, npc)
                    poof.Color = mod.Colors.DankBlack
                    poof.SpriteScale = Vector(0.7,0.7)
                    poof.PositionOffset = Vector(0,-29)
                    poof:Update()
                    mod:PlaySound(SoundEffect.SOUND_HEARTOUT, npc)
                end

            elseif npc.State == NpcState.STATE_ATTACK2 then --SlideStart
                if sprite:IsFinished("SlideStart") then
                    sprite:Play("SlideLoop", true)
                    npc.State = NpcState.STATE_ATTACK3 
                else
                    mod:SpritePlay(sprite, "SlideStart")
                end

            elseif npc.State == NpcState.STATE_ATTACK3 then --SlideLoop 
                mod:SpritePlay(sprite, "SlideLoop")
                npc.StateFrame = npc.StateFrame - 1
                if npc.StateFrame <= 0 or npc.Velocity:Length() < 6 then
                    npc.State = NpcState.STATE_ATTACK4
                end

            elseif npc.State == NpcState.STATE_ATTACK4 then --SlideEnd
                if sprite:IsFinished("SlideEnd") then
                    npc.State = NpcState.STATE_IDLE
                elseif sprite:IsEventTriggered("Shoot") then
                    npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                    npc:FireProjectiles(npc.Position, Vector(10,0), ProjectileMode.CROSS, params2)
                    mod:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH, npc, 0.8, 1.3)
                    mod:PlaySound(SoundEffect.SOUND_BOSS_LITE_ROAR, npc, 0.9, 0.8)
                    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 5, npc.Position, Vector.Zero, npc)
                    poof.Color = mod.Colors.DankBlack
                    poof.SpriteScale = Vector(0.7,0.7)
                    poof.PositionOffset = Vector(0,-29)
                    poof.DepthOffset = -120
                    poof:Update()
                    data.Sliding = false
                elseif sprite:IsEventTriggered("Land") then
                    mod:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, npc, 1, 0.65)
                    MakeTarPuddle(npc, 120)
                    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 2, npc.Position, Vector.Zero, npc)
                    poof.Color = Color(0.8,0.8,0.8,0.7)
                    poof.SpriteOffset = Vector(0,15)
                    poof:Update()
                else
                    mod:SpritePlay(sprite, "SlideEnd")
                end

            elseif npc.State == NpcState.STATE_STOMP then
                if sprite:IsEventTriggered("Land") then
                    if npc.I1 == 0 then
                        npc:FireProjectiles(npc.Position, Vector(12,8), ProjectileMode.CIRCLE_CUSTOM, params)
                    else
                        MakeTarPuddle(npc, 180)
                    end
                elseif sprite:IsEventTriggered("Shoot") then
                    if npc.I1 == 1 then
                        if mod:GetEntityCount(EntityType.ENTITY_SUCKER, 3) < 4 then
                            for i = 90, 360, 90 do
                                Isaac.Spawn(EntityType.ENTITY_SUCKER, 3, 0, npc.Position + Vector.FromAngle(i + 45):Resized(40), Vector.Zero, npc)
                            end
                            sfx:Play(SoundEffect.SOUND_SUMMONSOUND)
                        end
                    end
                end
            end

            if data.Sliding then
                data.SlideSpeed = data.SlideSpeed - 0.15
                npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity:Resized(data.SlideSpeed), 0.1)
                mod:FlipSprite(sprite, npc.Position, npc.Position - npc.Velocity)
                if npc.FrameCount % 15 == 0 then
                    MakeTarPuddle(npc, 90)
                end
            end
        end
    end
end, EntityType.ENTITY_MONSTRO2)

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, type, var, sub, pos, vel, spawner, seed)
    if not ReworkedFoes then
        if type == EntityType.ENTITY_CLOTTY 
        and var == 1 
        and spawner 
        and spawner.Type == EntityType.ENTITY_MONSTRO2
        and spawner.Variant == 1
        and spawner:ToNPC().State == NpcState.STATE_STOMP then
            return {StageAPI.E.DeleteMeNPC.T, StageAPI.E.DeleteMeNPC.V, StageAPI.E.DeleteMeNPC.S, seed}
        end
    end
end)