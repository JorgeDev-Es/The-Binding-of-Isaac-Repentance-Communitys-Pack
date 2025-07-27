local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local params = ProjectileParams()
params.Variant = ProjectileVariant.PROJECTILE_FIRE
--params.Color = Color(1.5,0.75,0.5,1,0)
params.HeightModifier = 17
params.FallingAccelModifier = -0.099
params.Acceleration = 1.025
params.CurvingStrength = 0.0085

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if not ReworkedFoes then
        local sprite = npc:GetSprite()
        local data = npc:GetData()
        local rng = npc:GetDropRNG()

        if npc.FrameCount <= 1 then
            for i = 1, 10 do
                local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, npc.Position + Vector(mod:RandomInt(-60,60,rng), mod:RandomInt(0,10,rng)), Vector.Zero, npc)
                splat.SpriteScale = Vector.One * (mod:RandomInt(5,15,rng) * 0.1)
                splat:Update()
            end
        end

        if sprite:IsFinished("Spawn") or sprite:IsFinished("Attack") or sprite:IsFinished("Shooting") then
            npc.StateFrame = 20
        end

        npc.StateFrame = npc.StateFrame - 1
        if npc.State ~= NpcState.STATE_IDLE and npc.StateFrame > 0 then
            sfx:Stop(SoundEffect.SOUND_MONSTER_GRUNT_4)
            sfx:Stop(SoundEffect.SOUND_LOW_INHALE)
            npc.State = NpcState.STATE_IDLE
        end

        if npc.State == NpcState.STATE_ATTACK2 and npc.SubType ~= 1 then --Reimplement the projectiles
            --mod:PlaySound(SoundEffect.SOUND_LOW_INHALE, npc)
            npc.State = NpcState.STATE_ATTACK3 
        
        elseif npc.State == NpcState.STATE_ATTACK3 then
            if sprite:IsFinished("Attack") then
                npc.State = NpcState.STATE_IDLE
            elseif sprite:IsEventTriggered("Sound") then
                --mod:PlaySound(SoundEffect.SOUND_LOW_INHALE, npc)
            elseif sprite:IsEventTriggered("Shoot") then
                params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE 
                local roll = rng:RandomInt(3)

                if roll == 0 then --Swirl pattern
                    params.BulletFlags = params.BulletFlags | ProjectileFlags.ACCELERATE
                    local angle = rng:RandomInt(360)
                    for i = 0, 8, 4 do
                        mod:ScheduleForUpdate(function()
                            params.CircleAngle = angle + (6.5 * i)
                            for _, proj in pairs(npc:FireProjectilesEx(npc.Position, Vector(2,6), ProjectileMode.CIRCLE_CUSTOM, params)) do
                                proj.FallingSpeed = 0
                            end
                        end, i) 
                    end

                elseif roll == 1 then --Curving pattern
                    params.BulletFlags = params.BulletFlags | (rng:RandomFloat() <= 0.5 and ProjectileFlags.CURVE_RIGHT or ProjectileFlags.CURVE_LEFT)
                    for _, proj in pairs(npc:FireProjectilesEx(npc.Position, Vector(7,6), ProjectileMode.CIRCLE_CUSTOM, params)) do
                        proj.FallingSpeed = 0.01
                    end

                elseif roll == 2 then --Wiggle pattern
                    params.BulletFlags = params.BulletFlags | ProjectileFlags.MEGA_WIGGLE
                    for i = 0, 16, 4 do
                        mod:ScheduleForUpdate(function()
                            for _, proj in pairs(npc:FireProjectilesEx(npc.Position, Vector(5,6), ProjectileMode.CIRCLE_CUSTOM, params)) do
                                proj.FallingSpeed = 0
                            end
                        end, i)
                    end
                end

                mod:PlaySound(SoundEffect.SOUND_FIRE_RUSH, npc)
                mod:PlaySound(SoundEffect.SOUND_FLAME_BURST, npc, 1.5, 0.75)
            else
                mod:SpritePlay(sprite, "Attack")
            end

        elseif npc.State == NpcState.STATE_SUMMON then --Chance to shoot projectiles instead of summon Leapers to reduce spam
            if sprite:GetFrame() == 0 then
                if rng:RandomFloat() <= 0.33 then
                    sfx:Stop(SoundEffect.SOUND_MONSTER_GRUNT_4)
                    --mod:PlaySound(SoundEffect.SOUND_LOW_INHALE, npc)
                    npc.State = NpcState.STATE_ATTACK3 
                end
            end
        end
    end
end, EntityType.ENTITY_GATE)