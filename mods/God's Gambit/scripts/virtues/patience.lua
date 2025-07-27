local mod = GodsGambit
local game = Game()
local sfx = SFXManager()

local bal = {
    moveSpeed = 3,
    moveSpeedScaling = 0.0075,
    explodeTimer = 900,
    attackCooldown = {60,120},
    attackCooldownScaling = 0.1,
    mineTimer = {3,9}, 
}

function mod:PatienceAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local isSuper = (npc.Variant == mod.ENT.SuperPatience.Var)

    if not data.Init then
        npc.I1 = bal.explodeTimer
        npc.StateFrame = mod:RandomInt(bal.attackCooldown, rng) - 20
        data.State = "Idle"
        if isSuper then
            npc.SplatColor = mod.Colors.SuperPatienceSplat
        end
        data.Init = true
    end

    local timeSpent = bal.explodeTimer - npc.I1

    if data.State == "Idle" then
        mod:WanderGridAligned(npc, data, bal.moveSpeed + (timeSpent * bal.moveSpeedScaling), 0.3)
        mod:AnimWalkFrame(npc, sprite, "WalkHori", "WalkVert", true)
        sprite:SetOverlayFrame("HeadIdle", 0)

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            local nearMine = mod:GetNearestThing(npc.Position, mod.ENT.PatienceMine.ID, isSuper and mod.ENT.SuperPatienceMine.Var or mod.ENT.PatienceMine.Var)
            if nearMine == nil or npc.Position:Distance(nearMine.Position) > 80 then
                data.State = "Attack"
                sprite:RemoveOverlay()
                sprite:Play("Attack", true)
            end
        end

    elseif data.State == "Attack" then
        npc.Velocity = npc.Velocity * 0.7

        if sprite:IsFinished("Attack") then
            npc.StateFrame = mod:RandomInt(bal.attackCooldown, rng) - math.floor(timeSpent * bal.attackCooldownScaling) 
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_FETUS_FEET, npc)
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_FETUS_LAND, npc)
            local mine = Isaac.Spawn(mod.ENT.PatienceMine.ID, isSuper and mod.ENT.SuperPatienceMine.Var or mod.ENT.PatienceMine.Var, 0, npc.Position, Vector.Zero, npc)
            mine.DepthOffset = 5
            mine:Update()
        else
            mod:SpritePlay(sprite, "Attack")
        end

    elseif data.State == "Death" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("Explode") then
            npc:Kill()
        elseif sprite:IsEventTriggered("Sound") then
            for i = 90, 360, 90 do
                local tracer = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GENERIC_TRACER, 0, npc.Position + Vector(5, 0):Rotated(i), Vector(0.001,0), npc):ToEffect()
                tracer.Timeout = 20
                tracer.LifeSpan = 15
                tracer.TargetPosition = Vector(1,0):Rotated(i)
                tracer:FollowParent(npc)
                tracer.Color = Color(0.8,0.4,0.05)
                tracer:Update()
            end
        else
            mod:SpritePlay(sprite, "Explode")
        end
    end

    if data.State ~= "Death" then
        npc.I1 = npc.I1 - 1
        if npc.I1 == 0 then
            npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET)
            data.State = "Death"
            sprite:RemoveOverlay()
            sprite:Play("Explode", true)
            mod:PlaySound(SoundEffect.SOUND_THUMBS_DOWN, npc)
            mod:PlaySound(SoundEffect.SOUND_WAR_BOMB_TICK, npc, 1.3, 1.5)
        elseif npc.I1 % 30 == 0 then
            mod:PlaySound(SoundEffect.SOUND_BEEP, npc, 0.5, 0.5)
        end
    end

    if npc:IsDead() then
        if data.State == "Death" then
            game:BombExplosionEffects(npc.Position, isSuper and 300 or 200, isSuper and TearFlags.TEAR_GIGA_BOMB or 0, Color.Default, npc, 1)
            for i = 90, 360, 90 do
                local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.EXPLOSION_WAVE, 0, npc.Position, Vector.Zero, npc):ToEffect()
                wave.TargetPosition = Vector(1,0):Rotated(i)
            end
        else
            game:BombExplosionEffects(npc.Position, isSuper and 200 or 100, isSuper and TearFlags.TEAR_GIGA_BOMB or 0, Color.Default, npc, 1)
        end
    end
end

local patienceNumbers = Sprite()
patienceNumbers:Load("gfx/bosses/virtues/patience/patience_numbers.anm2", true)
function mod:PatienceRender(npc, sprite, data)
    if npc.FrameCount > 3 and mod:IsNormalRender() then
        local offset = npc:GetNullOffset("nums")
        if offset and offset:Length() > 0.1 then
            local anim = npc.Variant == mod.ENT.SuperPatience.Var and "Super" or "Regular"
            local scale = sprite.Scale
            local animData = sprite:GetCurrentAnimationData()
            if animData then
                local animFrame = animData:GetLayer(1):GetFrame(sprite:GetFrame())
                if animFrame then
                    scale = scale * animData:GetLayer(1):GetFrame(sprite:GetFrame()):GetScale()
                end
            end
            patienceNumbers.Scale = scale
            patienceNumbers.Color = sprite.Color
            local numVal = npc.I1 + 30
            patienceNumbers:SetFrame(anim, 0)
            patienceNumbers:Render(Isaac.WorldToScreen(npc.Position + offset) + Vector(-7,0))
            patienceNumbers:SetFrame(anim, 10)
            patienceNumbers:Render(Isaac.WorldToScreen(npc.Position + offset) + Vector(-3,0))
            patienceNumbers:SetFrame(anim, math.floor(numVal / 300) % 10)
            patienceNumbers:Render(Isaac.WorldToScreen(npc.Position + offset) + Vector(2,0))
            patienceNumbers:SetFrame(anim, math.floor(numVal / 30) % 10)
            patienceNumbers:Render(Isaac.WorldToScreen(npc.Position + offset) + Vector(7,0))
        end
    end
end

function mod:PatienceHurt(npc, sprite, data, amount, flags, source)
    if data.State == "Death" then
        return false
    elseif source.Type == EntityType.ENTITY_BOMB and mod:HasDamageFlag(flags, DamageFlag.DAMAGE_EXPLOSION) then
        npc:Kill()
    elseif mod:HasDamageFlag(flags, DamageFlag.DAMAGE_FIRE) and not mod:IsPlayerDamage(source) then
        return {Damage = amount * 0.25} 
    end
end

function mod:PatienceMineAI(npc, sprite, data)
    if not data.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        npc.StateFrame = mod:RandomInt(bal.mineTimer,npc:GetDropRNG()) * 30
        data.State = "Appear"
        data.Init = true
    end
    
    npc.Velocity = npc.Velocity * 0.5
    npc.StateFrame = npc.StateFrame - 1

    if data.State == "Appear" then
        if sprite:IsFinished("Appear") then
            data.State = "Idle"
        else
            mod:SpritePlay(sprite, "Appear")
        end

    elseif data.State == "Idle" then
        mod:SpritePlay(sprite, "Idle")

        if npc.StateFrame <= 0 then
            data.State = "Explode"
            mod:PlaySound(SoundEffect.SOUND_BEEP, npc, 0.25, 1)
        elseif npc.StateFrame % 30 == 0 then
            mod:PlaySound(SoundEffect.SOUND_BEEP, npc, 1, 0.2)
        end

    elseif data.State == "Explode" then
        if sprite:IsFinished("Explode") then
            npc:Kill()
        else
            mod:SpritePlay(sprite, "Explode")
        end
    end

    if npc:IsDead() then
        game:BombExplosionEffects(npc.Position, 3, 0, Color.Default, npc, 1)
        for i = 90, 360, 90 do
            if npc.Variant == mod.ENT.SuperPatienceMine.Var then
                local laser = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.THICK_RED, 0, npc.Position, Vector.Zero, npc):ToLaser()
                laser.Angle = i
                laser.CollisionDamage = 0.1
                laser.Mass = 0.25
                laser.Timeout = 15
                laser:SetScale(0.75)
                laser:Update()
            else
                local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FIRE_WAVE, 0, npc.Position, Vector.Zero, npc):ToEffect()
                wave.Rotation = i
            end
        end
    end
end

local mineNumbers = Sprite()
mineNumbers:Load("gfx/bosses/virtues/patience/patience_mine.anm2", true)
function mod:PatienceMineRender(npc, sprite, data)
    local offset = npc:GetNullOffset("nums")
    if offset and offset:Length() > 0.1 and mod:IsNormalRender() then
        local anim = npc.Variant == mod.ENT.SuperPatienceMine.Var and "SuperNumbers" or "Numbers"
        mineNumbers.Scale = sprite.Scale
        mineNumbers.Color = sprite.Color
        mineNumbers:GetLayer(0):SetColor(Color.Default)
        local numVal = npc.StateFrame + 30
        mineNumbers:SetFrame(anim, math.floor(numVal / 30) % 10)
        mineNumbers:Render(Isaac.WorldToScreen(npc.Position + offset))
    end
end

function mod:PatienceMineHurt(npc, sprite, data, amount, flags, source)
    if mod:HasDamageFlag(flags, DamageFlag.DAMAGE_EXPLOSION) then
        npc:Kill()
    else
        return false
    end
end