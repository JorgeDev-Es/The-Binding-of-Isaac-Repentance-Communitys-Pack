local mod = GodsGambit
local game = Game()
local sfx = SFXManager()

local bal = {
    moveSpeed = {11,0.9},
    attackCooldown = {45,135},
    creepSpread = 40,
    creepDuration = 90,
    creepRange = 8,
    superSpreadSpeed = 7,
    projSpeed1 = 11,
    projSpeed2 = 5.5,
}

local params1 = ProjectileParams()
params1.FallingAccelModifier = 1
params1.Damage = 1

local params2 = ProjectileParams()
params2.FallingAccelModifier = -0.1
params2.Damage = 1

function mod:DiligenceAI(npc, sprite, data)
    local targetpos = mod:GetPlayerTargetPos(npc)
    local rng = npc:GetDropRNG()
    local isSuper = (npc.Variant == mod.ENT.SuperDiligence.Var)

    if not data.Init then
        npc.StateFrame = mod:RandomInt(bal.attackCooldown, rng)
        data.State = "Chase"
        data.Init = true
    end

    if data.State == "Chase" then
        mod:ChasePlayer(npc, bal.moveSpeed, 0.075)
        if npc.Velocity:Length() >= 0.05 then
            mod:SpritePlay(sprite, "WalkBody")
        else
            sprite:SetFrame("WalkBody", 0)
        end
        sprite:SetOverlayFrame("HeadIdle", rng:RandomFloat() <= 0.1 and 1 or 0)
        mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if targetpos:Distance(npc.Position) <= 200 and game:GetRoom():CheckLine(npc.Position, targetpos, LineCheckMode.PROJECTILE) then
                local attack = mod:RandomInt(1,2)
                data.State = "Attack0"..attack
                sprite:RemoveOverlay()
                sprite:Play("Attack0"..attack, true)
            else
                npc.StateFrame = mod:RandomInt(5,20,rng)
            end
        end

    elseif data.State == "Attack01" then
        npc.Velocity = npc.Velocity * 0.7

        if sprite:IsFinished("Attack01") then
            npc.StateFrame = mod:RandomInt(bal.attackCooldown, rng) + 30
            data.State = "Chase"
        elseif sprite:IsEventTriggered("Shoot") then
            local room = game:GetRoom()
            local vec = targetpos - npc.Position
            for angle = -bal.creepSpread, bal.creepSpread, bal.creepSpread * 2 do
                for i = 1, bal.creepRange do
                    local pos = npc.Position + vec:Rotated(angle):Resized(i * 35)
                    if room:IsPositionInRoom(pos, -20) then
                        mod:ScheduleForUpdate(function()
                            params1.Scale = mod:RandomInt(5,15,rng) * 0.1
                            params1.FallingSpeedModifier = mod:RandomInt(-15,-5,rng)
                            npc:FireProjectiles(pos + (RandomVector() * mod:RandomInt(0,10,rng)), vec:Rotated(angle + mod:RandomInRange(-20,rng)):Resized(mod:RandomInt(4,8,rng)), 0, params1)
                            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, pos, Vector.Zero, npc):ToEffect()
                            creep:SetTimeout(bal.creepDuration)
                            creep:Update()
                            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, pos, Vector.Zero, npc)
                            poof.DepthOffset = -40
                            poof:Update()
                        end, i)
                    end
                end
            end
            if isSuper then
                params2.Scale = 1.5
                npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(bal.superSpreadSpeed), ProjectileMode.SPREAD_THREE, params2)
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 5, npc.Position, Vector.Zero, npc)
                poof.SpriteOffset = npc:GetNullOffset("EffectPos") + Vector(0,5)
                poof.DepthOffset = 40
                poof.Color = Color(1,1,1,0.3)
                poof:Update()
            end
            mod:PlaySound(SoundEffect.SOUND_BOSS_LITE_SLOPPY_ROAR, npc, 1.1)
            mod:PlaySound(SoundEffect.SOUND_HEARTOUT, npc)
            mod:FlipSprite(sprite, npc.Position, targetpos)
        else
            mod:SpritePlay(sprite, "Attack01")
        end

    elseif data.State == "Attack02" then
        npc.Velocity = npc.Velocity * 0.7

        if sprite:IsFinished("Attack02") then
            npc.StateFrame = mod:RandomInt(bal.attackCooldown, rng)
            data.State = "Chase"
        elseif sprite:IsEventTriggered("Shoot") then
            params2.Scale = 1
            npc:FireProjectiles(npc.Position, Vector(bal.projSpeed1,0), ProjectileMode.CIRCLE_EIGHT, params2)
            if isSuper then
                params2.Scale = 1.5
                npc:FireProjectiles(npc.Position, Vector(bal.projSpeed2,0), ProjectileMode.CIRCLE_EIGHT, params2)
            end
            mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, npc, 1.1)
            mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 0.9)
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, npc.Position, Vector.Zero, npc)
            poof.SpriteOffset = npc:GetNullOffset("EffectPos") + Vector(0,5)
            poof.DepthOffset = -40
            poof:Update()
        else
            mod:SpritePlay(sprite, "Attack02")
        end
    end
end