local mod = LastJudgement
local game = Game()

local balance = {
    maxPosition = 25,
    minPosition = 2,
    speed = 9.6,
    slipperiness = 0.07,
    soundRange = 200,

    --projectiles
    ringCount1 = 15,
    ringSpeed1 = 6,
    ringVariance = 3,
    ringLifespan = {30, 70},
    ringCount2 = 11,
    ringSpeed2 = 16,

    lineCount = 5,
    lineSpeed = 20,
    lineDecrement = 4.6,
    lineSegments = 4,
    lineVariance = 6,

    creepSize = 2.2,
    creepDistance = {70,90},
}

function mod:EmbolismAI(npc)
    local sprite = npc:GetSprite()
    local d = npc:GetData()
    local target = mod:GetPlayerTarget(npc)
    local rng = npc:GetDropRNG()

    if not d.init then
        if npc:GetData().isDeathAnim then
            d.state = "Death"
            d.thumping = true
            d.thumpCount = 20
            d.thumpNum = 20
            d.thumpPitch = 0.7
        else
            d.state = "Idle"
        end

        d.playerMovementLog = {}
        d.init = true
    else
        npc.StateFrame = 0
    end

    if d.state == "Idle" then
        if npc.FrameCount % 55 == 0 and rng:RandomInt(6) == 0 then
            local dist = game:GetNearestPlayer(npc.Position).Position:Distance(npc.Position)
            if dist < balance.soundRange then
                npc:PlaySound(mod.Sounds.EmbolismBreath, (balance.soundRange - dist) / balance.soundRange, 0, false, mod:RandomInt(90,110,rng)/100)
            end
        end

        table.insert(d.playerMovementLog, target.Position)
        if #d.playerMovementLog > balance.maxPosition then
            table.remove(d.playerMovementLog, 1)
        end

        if mod:isConfuse(npc) then
            npc.Velocity = mod:Lerp(npc.Velocity, RandomVector():Resized(balance.speed), balance.slipperiness)
        elseif mod:isScare(npc) then
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position-target.Position):Resized(balance.speed), balance.slipperiness)
        elseif #d.playerMovementLog > balance.minPosition then
            local entry = d.playerMovementLog[balance.minPosition] or npc.Position
            npc.Velocity = mod:Lerp(npc.Velocity, (entry-npc.Position):Resized(balance.speed)+Vector(0,3):Rotated(rng:RandomInt(360)), balance.slipperiness)
        else
            npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.35)
        end

        if npc.Velocity.X > 0 then
            sprite.FlipX = true
        else
            sprite.FlipX = false
        end

        if npc.HitPoints < npc.MaxHitPoints/2 then
            mod:spritePlay(sprite, "IdleThrob")
        else
            mod:spritePlay(sprite, "Idle")
        end
    elseif d.state == "Death" then
        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.15)

        if sprite:IsFinished("Explode") then
            --GAMEPLAY

            local params = ProjectileParams()
            local color = Color(1, 0.65, 0.65, 1, 0, 0, 0)
		    color:SetColorize(3, 1.25, 1.25, 1)
            params.Color = color
            local ang = (target.Position-npc.Position):GetAngleDegrees()

            local params2 = ProjectileParams()
            params2.HeightModifier = -20
            params2.FallingAccelModifier = -0.15
            for i=1,balance.lineCount do
                local myAng
                if i > 1 then
                    myAng = ang+mod:RandomInt(-45, 45, rng)+360/balance.lineCount*i
                else
                    myAng = ang+mod:RandomInt(-5, 5, rng)
                end

                params2.FallingSpeedModifier = mod:RandomInt(-20,-10,rng)/10
                for j=1,balance.lineSegments do
                    local speed = balance.lineSpeed-balance.lineDecrement*j
                    mod:ScheduleForUpdate(function()
                        params.Scale = 3-0.35*j+mod:RandomInt(-20,20,rng)/100
                        npc:FireProjectiles(npc.Position, Vector(speed, 0):Rotated(myAng+mod:RandomInt(-balance.lineVariance, balance.lineVariance, rng)), 0, params)
                    end, j*2)
                end
            end

            local ring1Func = function(v, tab)
                tab.speed = tab.speed*0.95
                v.Velocity = mod:Lerp(v.Velocity, v.Velocity:Resized(tab.speed), 0.3)

                v.Scale = 0.6+math.max(0, 1.6*(tab.lifespan-v.FrameCount)/tab.lifespan)

                if v.Velocity:Length() < 2 then
                    if v.FrameCount < tab.lifespan then
                        v.FallingAccel = 0
                        v.FallingSpeed = mod:Lerp(v.FallingSpeed, 0, 0.2)
                    else
                        v.FallingAccel = 1
                    end
                end
            end
            for i=1,balance.ringCount1 do
                params.FallingAccelModifier = mod:RandomInt(30, 60, rng)/100
                params.FallingSpeedModifier = mod:RandomInt(-15, -5, rng)
                params.Scale = mod:RandomInt(80, 140, rng)/100
                for _, proj in pairs(npc:FireProjectilesEx(npc.Position, Vector(0,balance.ringSpeed1):Rotated(i*360/balance.ringCount1), 0, params)) do
                    local d1 = proj:GetData()
                    d1.projType = "customProjectileBehavior"
                    d1.customProjectileBehaviorLJ = {customFunc = ring1Func, speed = balance.ringSpeed1+mod:RandomInt(-balance.ringVariance, balance.ringVariance, rng),
                        lifespan = mod:RandomInt(balance.ringLifespan[1], balance.ringLifespan[2], rng), scale = 1.7}
                    proj:Update()
                end
            end

            local adjustedAngle = (target.Position-npc.Position):GetAngleDegrees()
            params.FallingAccelModifier = 0
            params.FallingSpeedModifier = 0
            local wavyFunc = function(v, tab)
                tab.frames = tab.frames+1
                local offset = math.sin(tab.frames/4)*tab.offset
                local targetpos = v.Position+tab.original:Resized(30)+tab.original:Rotated(90):Resized(offset)
                if tab.offset > 0 then
                    tab.offset = tab.offset-2
                end
                v.Velocity = (targetpos-v.Position):Resized(tab.speed)
            end
            local dir = -2*rng:RandomInt(2)+1
            for i=1,balance.ringCount2 do
                params.Scale = mod:RandomInt(120, 160, rng)/100
                for _, proj in pairs(npc:FireProjectilesEx(npc.Position, Vector(balance.ringSpeed2, 0):Rotated(adjustedAngle+180/balance.ringCount2+i*360/balance.ringCount2), 0, params)) do
                    local d1 = proj:GetData()
                    d1.projType = "customProjectileBehavior"
                    d1.customProjectileBehaviorLJ = {customFunc = wavyFunc, frames = 2*math.pi, angle = 6, offset = 20*dir*-1, original = proj.Velocity, speed = balance.ringSpeed2}
                end
            end
            for i=1,balance.ringCount2 do
                params.Scale = mod:RandomInt(120, 160, rng)/100
                for _, proj in pairs(npc:FireProjectilesEx(npc.Position, Vector(balance.ringSpeed2*0.75, 0):Rotated(adjustedAngle+i*360/balance.ringCount2), 0, params)) do
                    local d1 = proj:GetData()
                    d1.projType = "customProjectileBehavior"
                    d1.customProjectileBehaviorLJ = {customFunc = wavyFunc, frames = 2*math.pi, angle = 6, offset = 30*dir, original = proj.Velocity, speed = balance.ringSpeed2*0.75}
                end
            end

            local creep = Isaac.Spawn(1000, mod:isFriend(npc) and EffectVariant.PLAYER_CREEP_RED or EffectVariant.CREEP_RED, 0, npc.Position, Vector.Zero, npc):ToEffect()
            creep.SpriteScale = Vector(balance.creepSize,balance.creepSize)
            creep:SetTimeout(240)
            creep:Update()
            for i=1,4 do
                local creep2 = Isaac.Spawn(1000, mod:isFriend(npc) and EffectVariant.PLAYER_CREEP_RED or EffectVariant.CREEP_RED, 0, npc.Position+Vector(0,mod:RandomInt(balance.creepDistance[1],balance.creepDistance[2],rng)):Rotated(rng:RandomInt(360)), Vector.Zero, npc):ToEffect()
                creep2:Update()
            end

            --VFX
            for i=1,8 do
                mod:ScheduleForUpdate(function()
                    local line = Isaac.Spawn(1000, 151, 11, npc.Position, Vector.Zero, npc):ToEffect()
                    line:SetTimeout(10)
                    line.Color = Color(1, 0.2, 0.2, 1, 0, 0, 0)
                    line:GetData().embolismEffect = {scale = 1, frames = 0, maxScale = 0.5, speed = 0.025}
                    line.SpriteScale = Vector(1,1)
                    line.MaxRadius = mod:RandomFloat(10, 20, line:GetDropRNG())
                    line.SpriteOffset = Vector(0,-30)
                    line:GetSprite().Rotation = line:GetDropRNG():RandomInt(360)
                    line:Update()
                end, 3+i)
            end
    
            for i=0,2 do
                mod:ScheduleForUpdate(function()
                    local burst = Isaac.Spawn(1000, EffectVariant.BIG_ATTRACT, 10, npc.Position, Vector.Zero, npc):ToEffect()
                    burst:SetTimeout(30)
                    burst.Color = Color(1, 0.2, 0.2, 1, 0, 0, 0)
                    burst:GetData().embolismEffect = {scale = 0.01, frames = 0, maxScale = 0.25, speed = 0.04}
                    burst.SpriteScale = Vector.Zero
                    burst.SpriteOffset = Vector(0,-30)
                    burst:GetSprite().Rotation = burst:GetDropRNG():RandomInt(360)
                    burst:Update()
                end, 3*i)
            end
            game:MakeShockwave(npc.Position, 0.01, 0.05, 10)

            local ground = Isaac.Spawn(1000, EffectVariant.POOF02, 3, npc.Position, Vector.Zero, npc):ToEffect()
            ground.DepthOffset = -100

            for i=1,5 do
                local splat = Isaac.Spawn(1000, EffectVariant.BLOOD_SPLAT, 0, npc.Position+mod:RandomizedPosition(70, 70, rng), Vector.Zero, npc):ToEffect()
                local rand = mod:RandomInt(120,160,rng)/100
                splat.SpriteScale = Vector(rand, rand)
                splat:Update()
            end
            local splat = Isaac.Spawn(1000, EffectVariant.BLOOD_SPLAT, 0, npc.Position, Vector.Zero, npc):ToEffect()
            splat.SpriteScale = Vector(2, 2)
            splat:Update()

            for i=1,10 do
                local gib = Isaac.Spawn(1000, EffectVariant.BLOOD_PARTICLE, 0, npc.Position, Vector(mod:RandomInt(-5,5,rng), 0):Rotated(rng:RandomInt(360)), npc):ToEffect()
            end

            game:ButterBeanFart(npc.Position, 160, npc, false, true)

            npc:PlaySound(SoundEffect.SOUND_FLOATY_BABY_ROAR, 1, 0, false, 1.6)

            npc:PlaySound(SoundEffect.SOUND_DEATH_BURST_LARGE, 1, 0, false, 1)
            npc:PlaySound(SoundEffect.SOUND_MOTHER_WRIST_EXPLODE, 1, 0, false, 1)
            npc:PlaySound(SoundEffect.SOUND_PESTILENCE_HEAD_EXPLODE, 0.7, 0, false, 1.3)

            npc:Kill()
        elseif sprite:IsEventTriggered("sound") then
            
        else
            mod:SpritePlay(sprite, "Explode")
        end

        if d.thumping then
            d.thumpCount = d.thumpCount+1

            if d.thumpCount > d.thumpNum then
                npc:PlaySound(SoundEffect.SOUND_HEARTBEAT_FASTEST, 0.5, 0, false, d.thumpPitch)

                d.thumpNum = math.max(d.thumpNum-3, 8)
                d.thumpPitch = math.min(2, d.thumpPitch+0.45)
                d.thumpCount = 0
            end
        end
    end
end

function mod:EmbolismHurt(npc)
    if npc:GetData().isDeathAnim then
        return false
    end
end

function mod.EmbolismDeathAnim(npc)
    local func = function(ent, death)
        death:ToNPC():PlaySound(SoundEffect.SOUND_MULTI_SCREAM, 1, 0, false, 1)
        death:GetData().isDeathAnim = true
    end
    mod:MakeEnemyDeathAnim(npc, "Explode", func, true, true, true)
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, e)
    local d = e:GetData()
    if d.embolismEffect then
        local entry = d.embolismEffect
        if e.SubType == 11 then
            e.SpriteScale = Vector(2, 0.5)
        else
            e.SpriteScale = Vector(entry.scale, entry.scale)
        end
        entry.scale = entry.scale+entry.speed
        entry.speed = entry.speed*0.92
    end
end, EffectVariant.BIG_ATTRACT)