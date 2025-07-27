local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
    inBodyTimer = 460,

    nibsIdleTimer = 40,
    nibsPassiveShotTimer = 60,
    nibsPassiveShotNum = 5,
    nibsChaseLength = 140,
    nibsChaseSpeed = 12,
    nibsFlyLength = 70,
    nibsDragShotSpd = {4,7},
    nibsFlailLength = 240,

    chubsRollLength = 160,
    chubsRollSpeed = 12,
    chubsShotNum = 10,
    chubsShotSpd = 9,
    chubsChargeSpd = 17,
    chubsDragSpd = 12,
}

local params = ProjectileParams()
params.Color = mod.Colors.MortisBloodProj

local function setNextMove(d, timer, func)
    d.stateTimer = d.stateTimer or timer
    if d.stateTimer <= 0 then
        d.stateTimer = nil
        func()
    end
end

local function getBody(rng, d)
    if d.lastChosenBody then
        if d.lastChosenBody == "Nibs" and d.chubs and d.chubs:Exists() then
            d.targetBody = d.chubs
            d.lastChosenBody = "Chubs"
        elseif d.lastChosenBody == "Chubs" and d.nibs and d.nibs:Exists() then
            d.targetBody = d.nibs
            d.lastChosenBody = "Nibs"
        end
    else
        if (rng:RandomFloat() < 0.5 or not d.nibs) and d.chubs and d.chubs:Exists() then
            d.targetBody = d.chubs
            d.lastChosenBody = "Chubs"
        elseif d.nibs and d.nibs:Exists() then
            d.targetBody = d.nibs
            d.lastChosenBody = "Nibs"
        end
    end

    if not d.targetBody then
        if (d.nibs and d.nibs:Exists()) and not (d.chubs and d.chubs:Exists()) then
            d.targetBody = d.nibs
            d.lastChosenBody = "Nibs"
        elseif (d.chubs and d.chubs:Exists()) and not (d.nibs and d.nibs:Exists()) then
            d.targetBody = d.chubs
            d.lastChosenBody = "Chubs"
        end
    end
    
    --d.targetBody = d.chubs
    return d.targetBody
end

local function idleMove(npc, sprite, targetPos, name, animPrefix, speed, lerp)
    if not sprite:IsPlaying(name..animPrefix.."WalkHori") and not sprite:IsPlaying(name..animPrefix.."WalkVert") then
        mod:SpritePlay(sprite, name..animPrefix.."WalkVert")
    end

    if sprite:IsEventTriggered("Step") then
        npc.Velocity = (targetPos-npc.Position):Resized(speed)

        local frame = sprite:GetFrame()
        if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
            mod:SpritePlay(sprite, name..animPrefix.."WalkHori")
            sprite.FlipX = npc.Velocity.X < 0
        else
            mod:SpritePlay(sprite, name..animPrefix.."WalkVert")
            sprite.FlipX = false
        end
        sprite:SetFrame(frame)
    end
    npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, lerp)
end

local function makeNibsCreep(npc, rng, pos, scale, duration, rate)
    pos = pos or npc.Position
    scale = scale or 0.6
    duration = duration or 50
    rate = rate or 11

    local creep
    if npc.FrameCount % rate == 0 or npc.FrameCount % rate+1 == 0 then
        creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, mod:isFriend(npc) and EffectVariant.PLAYER_CREEP_RED or EffectVariant.CREEP_RED, 0, pos, Vector.Zero, npc):ToEffect()
        creep.Color = mod.Colors.MortisBlood
        creep.SpriteScale = Vector(scale, scale)
        creep:SetTimeout(duration)
        creep:Update()
        
        return creep
    else
        return false
    end
end

local function bloodPoof(npc, variant, subtype, offset, scale)
    subtype = subtype or 0
    scale = scale or Vector(1,1)
    offset = offset or Vector.Zero
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, variant, subtype, npc.Position, Vector.Zero, npc)
    poof.Color = mod.Colors.MortisBlood
    poof.DepthOffset = 20
    poof.PositionOffset = offset
    poof.SpriteScale = scale
    poof:Update()
end

function mod:CadavraAI(npc, sprite, data)
    local d = data
    local target = mod:GetPlayerTarget(npc)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()
    
    d.chubs = d.chubs or Isaac.FindByType(mod.ENT.CadavraChubs.ID, mod.ENT.CadavraChubs.Var, 0, false, true)[1]
    d.nibs = d.nibs or Isaac.FindByType(mod.ENT.CadavraNibs.ID, mod.ENT.CadavraNibs.Var, 0, false, true)[1]
    if d.chubs and not d.chubs:Exists() then
        d.chubs = nil
    end
    if d.nibs and not d.nibs:Exists() then
        d.nibs = nil
    end

    if not d.init then
        npc.SplatColor = mod.Colors.MortisBlood
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

        d.mode = 0

        d.state = "Idle"
        d.init = true
    else
        if d.state == "Idle" then
            if not sprite:IsPlaying("Exit") then
                if npc.HitPoints < npc.MaxHitPoints * 0.6 then
                    mod:SpritePlay(sprite, "Idle02")
                else
                    mod:SpritePlay(sprite, "Idle01")
                end
            end

            mod:WanderAboutAir(npc, d, 8, 0.05, 0, 0, 80)

            local time = 50
            if d.mode > 0 then
                time = 100
            end
            setNextMove(d, time, function()
                getBody(rng,d)
                if d.targetBody then
                    d.state = "GetBody"
                end
            end)
        elseif d.state == "GetBody" then
            if d.targetBody and d.targetBody:Exists() then
                if npc.HitPoints > npc.MaxHitPoints * 0.6 then
                    mod:SpritePlay(sprite, "ApproachBody")
                end
                if d.targetBody.Position:Distance(npc.Position) < 50 
                and (d.targetBody:GetData().state == "Idle" or d.targetBody:GetData().state == "Sit") then
                    npc.Position = mod:Lerp(npc.Position, d.targetBody.Position, 0.4)
                    mod:ScheduleForUpdate(function()
                        d.targetBody:GetData().puppet = true
                        d.targetBody:GetData().state = "HeadEnter"
                        d.state = "InBody"
                    end, 2)
                else
                    npc.Velocity = mod:Lerp(npc.Velocity, (d.targetBody.Position-npc.Position):Resized(11), 0.05)
                end
            else
                d.state = "Idle"
            end
        elseif d.state == "InBody" then
            if d.targetBody and d.targetBody:Exists() and d.targetBody:GetData().puppet == true then 
                npc.Visible = false
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                npc.Position = d.targetBody.Position
                npc.Velocity = Vector.Zero

                --[[if d.mode == 0 and npc.HitPoints <= npc.MaxHitPoints * 0.5 then
                    if d.targetBody:GetData().state == "Idle" then
                        d.mode = 1
                        d.targetBody:GetData().state = "Exit"
                    end
                end]]

                --[[if d.mode == 2 and npc.HitPoints <= npc.MaxHitPoints * 0.05 then
                    if d.targetBody:GetData().state == "Idle" then
                        d.targetBody:GetData().state = "Exit"
                    end
                end--]]

                if d.mode < 2 then
                    d.inBodyTimer = d.inBodyTimer or bal.inBodyTimer
                    if d.inBodyTimer and d.inBodyTimer > 0 then
                        d.inBodyTimer = d.inBodyTimer - 1
                    elseif d.inBodyTimer and d.inBodyTimer <= 0 then
                        if d.targetBody:GetData().state == "Idle" then
                            d.mode = 1
                            d.targetBody:GetData().state = "Exit"
                        end
                    end
                end
            else
                d.state = "OutOfBody"
            end
        elseif d.state == "OutOfBody" then
            d.inBodyTimer = nil
            mod:PlaySound(SoundEffect.SOUND_PLOP, npc, 0.8)

            npc.Position = d.targetBody.Position
            d.targetBody = nil
            npc.Visible = true
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            mod:SpritePlay(sprite, "Exit")
            d.state = "Idle"
        elseif d.state == "DeathHead" then
            npc.Visible = true
            mod:SpritePlay(sprite, "Die")
            if sprite:IsFinished("Die") then
                local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, npc.Position, Vector.Zero, npc)
                eff.Color = npc.SplatColor
                eff:Update()

                npc:Kill()
            end
            d.death = true
            npc.Velocity = Vector.Zero
        elseif d.state == "DeathNibs" or d.state == "DeathChubs" then
            if (not d.nibs or d.nibs:IsDead()) and (not d.chubs or d.chubs:IsDead()) then
                local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, npc.Position, Vector.Zero, npc)
                eff.Color = npc.SplatColor
                eff:Update()
                npc:Kill()
            end

            d.death = true
            npc.Velocity = Vector.Zero
        end
    end

    if d.stateTimer and d.stateTimer > 0 then
        d.stateTimer = d.stateTimer - 1
    end
end

function mod:CadavraNibsAI(npc, sprite, data)
    local d = data
    local target = mod:GetPlayerTarget(npc)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()

    d.head = d.head or Isaac.FindByType(mod.ENT.Cadavra.ID, mod.ENT.Cadavra.Var, 0, false, true)[1]
    d.chubs = d.chubs or Isaac.FindByType(mod.ENT.CadavraChubs.ID, mod.ENT.CadavraChubs.Var, 0, false, true)[1]
    d.phageCount = mod:CountPhages()
    
    if d.head and not d.head:Exists() then
        d.head = nil
    end
    if d.chubs and not d.chubs:Exists() then
        d.chubs = nil
    end

    if not d.init then
        npc.SplatColor = mod.Colors.MortisBlood
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
        mod:SpritePlay(sprite, "NibsBodyIdle")

        d.attacksMade = mod:RandomInt(0,1,rng)

        d.state = "Idle"
        d.puppet = false
        d.init = true
    else
        local animPrefix = "Body"
        if d.puppet then animPrefix = "" end

        if not d.puppet and d.chubs and d.chubs:GetData().puppet then
            if d.state == "Idle" then
                d.targetpos = d.targetpos or room:GetRandomPosition(30)
                if npc.Position:Distance(d.targetpos) < 50 then
                    d.targetpos = room:GetRandomPosition(30)
                end
                idleMove(npc, sprite, d.targetpos, "Nibs", animPrefix, 6, 0.1)
                makeNibsCreep(npc, rng)
                
                setNextMove(d, bal.nibsPassiveShotTimer, function()
                    mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc)
                    params.FallingAccelModifier = -0.1
                    local vec = (target.Position-npc.Position):Resized(5)
                    local num = bal.nibsPassiveShotNum
                    for j=1,num do
                        local proj = npc:FireProjectilesEx(npc.Position, vec, 0, params)[1]
                        vec = vec:Rotated(360/num)
                    end
                    bloodPoof(npc, EffectVariant.BLOOD_EXPLOSION, 2, Vector(0,-25), Vector(1,1))
                end)
            end
        else
            if d.state == "Idle" then
                idleMove(npc, sprite, target.Position, "Nibs", animPrefix, 4, 0.1)
                makeNibsCreep(npc, rng)

                if d.puppet and not d.stateHold then
                    setNextMove(d, bal.nibsIdleTimer, function()
                        if d.chubs and d.attacksMade >= 1 and npc.Position:Distance(room:GetCenterPos()) < 120 then
                            if d.chubs:GetData().state ~= "Sit" then
                                d.stateTimer = 2
                            else
                                d.state = "Flail"
                                d.attacksMade = 0
                            end
                        else
                            mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_2, npc)
                            d.state = "Chase"
                            d.attacksMade = d.attacksMade + 1
                        end
                    end)
                end
            elseif d.state == "HeadEnter" then
                mod:SpritePlay(sprite, "NibsEnter")
                if sprite:IsEventTriggered("Shoot") then
                    mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc)
                    d.spinShotVec = (target.Position-npc.Position):Resized(8)
                end
                if sprite:IsEventTriggered("Sound") then
                    for j=1,5 do
                        local params = ProjectileParams()
                        params.Color = mod.Colors.MortisBloodProj
                        params.Scale = mod:RandomInt(6,13,rng) * 0.1
                        params.FallingSpeedModifier = mod:RandomInt(-25,-10,rng)
                        params.FallingAccelModifier = 0.7
                        npc:FireProjectilesEx(npc.Position, RandomVector() * 3, 0, params)
                    end
                    for i=1,2 do
                        local vec = RandomVector() * mod:RandomInt(2,4, rng)
                        if d.phageCount < 4 then
                            local phage = Isaac.Spawn(mod.ENT.Phage.ID, mod.ENT.Phage.Var, 0, npc.Position + vec, vec, npc)
                            phage:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                            phage:GetData().State = "Idle"
                            
                            d.phageCount = mod:CountPhages()
                        end
                    end
                    mod:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, npc)
                    bloodPoof(npc, EffectVariant.BLOOD_EXPLOSION, 2, Vector(0,-40), Vector(1,1))
                    d.spinShotVec = nil
                end
                if d.spinShotVec then
                    mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc)
                    params.FallingAccelModifier = -0.1
                    local vec = d.spinShotVec:Rotated(-sprite:GetFrame()*40)
                    local proj = npc:FireProjectilesEx(npc.Position, vec, 0, params)
                end
                if sprite:IsFinished("NibsEnter") then
                    d.puppet = true
                    d.attacksMade = mod:RandomInt(0,1,rng)
                    d.stateTimer = nil
                    d.state = "Idle"
                end
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.5)
            elseif d.state == "Exit" then
                mod:SpritePlay(sprite, "NibsExit")
                if sprite:IsEventTriggered("Shoot") then
                    mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc)
                    bloodPoof(npc, EffectVariant.BLOOD_EXPLOSION, 2, Vector(0,-40), Vector(1,1))
                    d.head:GetData().state = "OutOfBody"
                    d.puppet = false
                end
                if sprite:IsFinished("NibsExit") then
                    d.puppet = false
                    d.state = "Idle"
                end
                npc.Velocity = npc.Velocity * 0.2
            end
        end

        if d.state == "Chase" then
            if not sprite:IsPlaying("NibsRunVert") and not sprite:IsPlaying("NibsRunHori") then
                mod:SpritePlay(sprite, "NibsRunVert")
            end
        
            local frame = sprite:GetFrame()
            if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
                mod:SpritePlay(sprite, "NibsRunHori")
                sprite.FlipX = npc.Velocity.X < 0
            else
                mod:SpritePlay(sprite, "NibsRunVert")
                sprite.FlipX = false
            end
            if sprite:GetFrame() ~= frame then
                sprite:SetFrame(frame)
            end

            if not d.fullChase and d.chubs and d.chubs:GetData().state == "Sit" then
                if d.chubs.Position:Distance(npc.Position) < 50 then
                    d.state = "Kick"
                end
                npc.Velocity = mod:Lerp(npc.Velocity, (d.chubs.Position-npc.Position):Resized(bal.nibsChaseSpeed), 0.05)
            elseif d.chubs and d.stateTimer and d.stateTimer <= 30 then
                npc.Velocity = mod:Lerp(npc.Velocity, (room:GetCenterPos()-npc.Position):Resized(bal.nibsChaseSpeed), 0.05)
            else
                npc.Velocity = mod:Lerp(npc.Velocity, (target.Position-npc.Position):Resized(bal.nibsChaseSpeed), 0.05)
            end
            makeNibsCreep(npc, rng)

            if npc.FrameCount % 12 == 0 or npc.FrameCount % 15 == 0 then
                local params = ProjectileParams()
                params.Color = mod.Colors.MortisBloodProj
                params.Scale = mod:RandomInt(6,13,rng) * 0.1
                params.FallingSpeedModifier = mod:RandomInt(-25,-10,rng)
                params.FallingAccelModifier = 1.4
                npc:FireProjectilesEx(npc.Position, RandomVector() * 3, 0, params)
            end

            setNextMove(d, bal.nibsChaseLength, function()
                if npc.Position:Distance(room:GetCenterPos()) < 100 or (d.chubs and d.chubs:GetData().state == "Sit") or not d.chubs then
                    d.fullChase = nil
                    d.state = "Idle"
                else
                    d.stateTimer = 2
                end
            end)
        elseif d.state == "Kick" then
            if d.chubs then
                if not d.nibKick then
                    npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.8)
                else
                    npc.Velocity = mod:Lerp(npc.Velocity, d.nibKick:Resized(5), 0.5)
                end
                if sprite:IsFinished("NibsKickLeft") or sprite:IsFinished("NibsKickRight") then
                    d.fullChase = true
                    d.nibKick = nil
                    d.stateTimer = nil
                    d.state = "Chase"
                elseif not sprite:IsPlaying("NibsKickRight") and not sprite:IsPlaying("NibsKickLeft") then
                    sprite.FlipX = false
                    if d.chubs.Position.X^2 < npc.Position.X^2 then
                        mod:SpritePlay(sprite, "NibsKickLeft")
                    else
                        mod:SpritePlay(sprite, "NibsKickRight")
                    end
                end
                if sprite:IsEventTriggered("Shoot") then
                    mod:PlaySound(mod.Sounds.ChubsKick, npc, 0.9, 0.7)
                    mod:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, npc, rng:RandomFloat()*0.3+0.7, 0.5)
                    d.nibKick = (d.chubs.Position-npc.Position)
                    d.chubs:GetData().stateTimer = nil
                    d.chubs.Velocity = (d.chubs.Position-npc.Position):Resized(10)
                    d.chubs:GetData().state = "Roll"
                end
            else
                d.state = "Chase"
            end
            makeNibsCreep(npc, rng)
        elseif d.state == "Fly" then
            if not d.substate then
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                mod:SpritePlay(sprite, "NibsBodyFly")
                if sprite:IsFinished("NibsBodyFly") then
                    d.stateTimer = nil
                    d.substate = 1
                end
            elseif d.substate == 1 then
                if npc.FrameCount % 3 == 0 then
                    local params = ProjectileParams()
                    params.Color = mod.Colors.MortisBloodProj
                    params.Scale = mod:RandomInt(6,13,rng) * 0.1
                    params.HeightModifier = -360
                    params.FallingAccelModifier = 3
                    npc:FireProjectilesEx(npc.Position, RandomVector(), 0, params)
                end
                setNextMove(d, bal.nibsFlyLength, function()
                    if d.chubs and d.chubs:GetData().state ~= "Idle" and d.chubs:GetData().state ~= "Sit" then
                        d.stateTimer = 2
                    else
                        d.substate = 2
                    end
                end)
                if d.stateTimer and d.stateTimer < 40 then
                    npc.Velocity = mod:Lerp(npc.Velocity,(target.Position-npc.Position):Resized(4),0.01)
                end
            elseif d.substate == 2 then
                mod:SpritePlay(sprite, "NibsBodyFall")
                if sprite:IsEventTriggered("Shoot") then
                    mod:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, npc)
                    mod:PlaySound(SoundEffect.SOUND_HEARTOUT, npc)
                    game:ShakeScreen(10)
                    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                    for i=1,3 do
                        local vec = RandomVector() * mod:RandomInt(4,7, rng)
                        if d.phageCount < 4 then
                            local phage = Isaac.Spawn(mod.ENT.Phage.ID, mod.ENT.Phage.Var, 0, npc.Position + vec, vec, npc)
                            phage:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                            phage:GetData().State = "Idle"

                            d.phageCount = mod:CountPhages()
                        end
                    end
                    local params = ProjectileParams()
                    params.Color = mod.Colors.MortisBloodProj
                    params.FallingAccelModifier = -0.2
                    local vec = Vector(1,0):Resized(7)
                    for j=1,8 do
                        local proj = npc:FireProjectilesEx(npc.Position, vec, 0, params)[1]
                        vec = vec:Rotated(360/8)
                        proj:AddProjectileFlags(ProjectileFlags.CURVE_LEFT)
                    end
                    vec = Vector(1,0):Resized(5)
                    for j=1,11 do
                        local proj = npc:FireProjectilesEx(npc.Position, vec, 0, params)[1]
                        vec = vec:Rotated(360/11)
                        proj:AddProjectileFlags(ProjectileFlags.CURVE_RIGHT)
                    end
                    vec = Vector(1,0):Resized(3)
                    for j=1,14 do
                        local proj = npc:FireProjectilesEx(npc.Position, vec, 0, params)[1]
                        vec = vec:Rotated(360/14)
                        proj:AddProjectileFlags(ProjectileFlags.CURVE_LEFT)
                    end
                    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, mod:isFriend(npc) and EffectVariant.PLAYER_CREEP_RED or EffectVariant.CREEP_RED, 0, npc.Position, Vector.Zero, npc):ToEffect()
                    creep.Color = mod.Colors.MortisBlood
                    creep.SpriteScale = Vector(3, 3)
                    creep:SetTimeout(100)
                    creep:Update()
                    bloodPoof(npc, EffectVariant.POOF02, 3, Vector(0,0), Vector(1,1))
                end
                if sprite:WasEventTriggered("Shoot") then
                    npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.8)
                    makeNibsCreep(npc, rng)
                end
                if sprite:IsFinished("NibsBodyFall") then
                    d.substate = nil
                    d.state = "Idle"
                end 
            end
        elseif d.state == "Flail" then
            if not d.substate then
                sprite.FlipX = false
                mod:SpritePlay(sprite, "NibsCord")
                if sprite:IsEventTriggered("Shoot") then
                    if d.chubs then
                        bloodPoof(npc, EffectVariant.POOF02, 5, Vector(0,-10), Vector(0.3,0.3))
                        d.nibsCord = mod:AttachCord(npc, d.chubs, mod.ENT.CadavraGut.Sub, nil, mod.Colors.MortisBlood, nil, mod:GetCordOffset(d.chubs))

                        mod:PlaySound(SoundEffect.SOUND_HEARTOUT, npc)
                        d.chubs:GetData().state = "Flail"
                        d.chubs.Velocity = (d.chubs.Position-npc.Position):Resized(10)
                    end
                end
                if sprite:IsFinished("NibsCord") then
                    d.substate = 1
                end
            elseif d.substate == 1 then
                mod:SpritePlay(sprite, "NibsFlailStart")
                if sprite:IsFinished("NibsFlailStart") then
                    d.substate = 2
                end
            elseif d.substate == 2 then
                mod:SpritePlay(sprite, "NibsFlail")

                if npc.FrameCount % math.floor(bal.nibsFlailLength/4) == 0 then
                    local vec = RandomVector() * mod:RandomInt(2,4, rng)
                    if d.phageCount < 4 then
                        local phage = Isaac.Spawn(mod.ENT.Phage.ID, mod.ENT.Phage.Var, 0, npc.Position + vec, vec, npc)
                        phage:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        phage:GetData().State = "Idle"
                    end
                end

                if npc.FrameCount % 16 == 0 or npc.FrameCount % 20 == 0 then
                    mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 1.2, 0.7)
                    local params = ProjectileParams()
                    params.Color = mod.Colors.MortisBloodProj
                    params.FallingAccelModifier = -0.2
                    local vec = RandomVector():Resized(mod:RandomInt(3,6))
                    local proj = npc:FireProjectilesEx(npc.Position, vec, 0, params)[1]
                end

                if npc.FrameCount % 60 == 0 then
                    mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 1.2, 0.7)
                    local params = ProjectileParams()
                    params.Color = mod.Colors.MortisBloodProj
                    params.FallingAccelModifier = -0.2
                    local vec = (target.Position-npc.Position):Resized(mod:RandomInt(3,6))
                    local proj = npc:FireProjectilesEx(npc.Position, vec, 0, params)[1]
                end

                if not d.chubs then
                    d.substate = nil
                    d.state = "Idle"
                end
                setNextMove(d, bal.nibsFlailLength, function()
                    local angle = math.floor((npc.Position-target.Position):GetAngleDegrees()/20)
                    if (math.floor((d.chubs.Position-npc.Position):GetAngleDegrees()/20) == angle) then
                        d.chubs:GetData().state = "Launch"
                        d.substate = 3
                    else
                        d.stateTimer = 2
                    end
                end)
            elseif d.substate == 3 then
                mod:SpritePlay(sprite, "NibsFlailStop")
                if sprite:IsFinished("NibsFlailStop") then
                    d.substate = nil
                    d.stateHold = 50
                    d.state = "Idle"
                end
            end
            makeNibsCreep(npc, rng)
            npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.5)
        elseif d.state == "Drag" then
            local makeCreepPosX = npc.Position.X > room:GetCenterPos().X + 100 or npc.Position.X < room:GetCenterPos().X - 100 
            
                if d.chubs then
                if d.chubs:GetData().substate and d.chubs:GetData().substate < 4 then
                    mod:SpritePlay(sprite, "NibsBodyRightDrag")
                    if npc.Velocity.X > 0 then
                        sprite.FlipX = true
                    else
                        sprite.FlipX = false
                    end

                    if npc.Velocity:Length() > 4 and npc.FrameCount % 12 == 0 then
                        mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 1.2, 0.7)
                        local params = ProjectileParams()
                        params.Color = mod.Colors.MortisBloodProj
                        params.FallingAccelModifier = -0.2
                        --local vec = (target.Position-npc.Position):Resized(mod:RandomInt(4,8))
                        local vec = Vector(-npc.Velocity.X,(target.Position-npc.Position).Y):Resized(mod:RandomInt(bal.nibsDragShotSpd[1],bal.nibsDragShotSpd[2]))
                        local proj = npc:FireProjectilesEx(npc.Position, vec, 0, params)[1]
                        proj:AddProjectileFlags(ProjectileFlags.MEGA_WIGGLE)
                    end

                    npc.Velocity = mod:Lerp(npc.Velocity, (d.chubs.Position-npc.Position)*0.1, 0.05)
                elseif (d.chubs:GetData().substate and d.chubs:GetData().substate >= 4) or d.chubs:GetData().state == "Idle" then
                    mod:SpritePlay(sprite, "NibsBodyDragEnd")
                    if sprite:IsFinished("NibsBodyDragEnd") then
                        d.state = "Idle"
                    end
                    npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)
                elseif not d.chubs:GetData().substate then
                    npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.1)
                end
            else
                d.state = "Idle"
            end

            if makeCreepPosX then
                makeNibsCreep(npc, rng, nil, nil, 70, 7)
            end
        elseif d.state == "DeathHead" or d.state == "DeathChubs" then
            mod:SpritePlay(sprite, "NibsDie02")
            if sprite:IsFinished("NibsDie02") then
                npc:Kill()
            end
            npc.Velocity = Vector.Zero
        elseif d.state == "DeathNibs" then
            mod:SpritePlay(sprite, "NibsDie01")
            if sprite:IsFinished("NibsDie01") then
                npc:Kill()
            end
            npc.Velocity = Vector.Zero
        end
    end

    if d.head and (d.head:IsDead() or d.head:GetData().death) and not d.death then
        if d.puppet then
            d.state = "DeathNibs"
        else
            d.state = "DeathHead"
        end
        d.death = true
    end

    if sprite:IsEventTriggered("Step") then
        mod:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, npc, 1.5, 0.3)
    end

    if d.stateHold and d.stateHold > 0 then
        d.stateHold = d.stateHold - 1
    else
        d.stateHold = nil
    end
    if d.stateTimer and d.stateTimer > 0 then
        d.stateTimer = d.stateTimer - 1
    end
end

function mod:CadavraChubsAI(npc, sprite, data)
    local d = data
    local target = mod:GetPlayerTarget(npc)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()

    d.head = d.head or Isaac.FindByType(mod.ENT.Cadavra.ID, mod.ENT.Cadavra.Var, 0, false, true)[1]
    d.nibs = d.nibs or Isaac.FindByType(mod.ENT.CadavraNibs.ID, mod.ENT.CadavraNibs.Var, 0, false, true)[1]
    if d.head and not d.head:Exists() then
        d.head = nil
    end
    if d.nibs and not d.nibs:Exists() then
        d.nibs = nil
    end

    if not d.init then
        npc.SplatColor = mod.Colors.MortisBlood
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
        mod:SpritePlay(sprite, "ChubsBodyIdle")

        d.attacksMade = mod:RandomInt(0,1,rng)

        d.startSize = npc.Size
        d.hopSuffix = "Down"
        d.state = "Idle"
        d.puppet = false
        d.init = true
    else
        local animPrefix = "Body"
        if d.puppet then animPrefix = "" end

        if not d.puppet and d.nibs and d.nibs:GetData().puppet then
            if d.state == "Idle" then
                mod:SpritePlay(sprite, "ChubsBodySit")
                if sprite:IsFinished("ChubsBodySit") then
                    d.state = "Sit"
                end
                npc.Velocity = Vector.Zero  
            end
        else
            if d.state == "Idle" then
                idleMove(npc, sprite, target.Position, "Chubs", animPrefix, 10, 0.2)
                npc.Velocity = npc.Velocity*Vector(1,1.1)

                if d.puppet and not d.stateHold then
                    if target.Position.Y > npc.Position.Y-30 and target.Position.Y < npc.Position.Y+30 then
                        if d.nibs and d.nibs:GetData().state == "Idle" and d.attacksMade >= 1 and (rng:RandomFloat() < 0.3 + d.attacksMade*0.2) then
                            d.state = "Drag"
                            d.attacksMade = 0
                        else
                            mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, npc)
                            d.state = "Charge"
                            d.attacksMade = d.attacksMade + 1
                        end
                    end
                end
            elseif d.state == "HeadEnter" then
                mod:SpritePlay(sprite, "ChubsEnter")
                if sprite:IsEventTriggered("Shoot") then
                    d.enterShotNum = d.enterShotNum or 4
                    local params = ProjectileParams()
                    params.Color = mod.Colors.MortisBloodProj
                    params.FallingAccelModifier = 0.2
                    local vec = (target.Position-npc.Position):Resized(bal.chubsShotSpd)
                    local num = d.enterShotNum

                    if d.enterShotNum < 8 then 
                        mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc, 0.8)
                    else 
                        mod:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, npc, 0.8) 
                        for j=1,bal.chubsShotNum do
                            local proj = npc:FireProjectilesEx(npc.Position, vec, 0, params)[1]
                            vec = vec:Rotated(360/bal.chubsShotNum)
                        end
                    end

                    for j=1,math.floor(num/2) do
                        params.Scale = mod:RandomInt(6,13,rng) * 0.1
                        params.FallingSpeedModifier = mod:RandomInt(-25,-10,rng)
                        params.FallingAccelModifier = 1
                        npc:FireProjectilesEx(npc.Position, RandomVector() * 3, 0, params)
                    end
                    bloodPoof(npc, EffectVariant.BLOOD_EXPLOSION, 2, Vector(0,-40), Vector(1,1))
                    d.enterShotNum = d.enterShotNum + 2
                end
                if sprite:IsFinished("ChubsEnter") then
                    d.enterShotNum = nil
                    d.puppet = true
                    d.stateTimer = nil
                    d.state = "Idle"
                end
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.5)
            elseif d.state == "Exit" then
                mod:SpritePlay(sprite, "ChubsExit")
                if sprite:IsEventTriggered("Shoot") then
                    mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc)
                    bloodPoof(npc, EffectVariant.BLOOD_EXPLOSION, 2, Vector(0,-40), Vector(1,1))
                    d.head:GetData().state = "OutOfBody"
                    d.puppet = false
                end
                if sprite:IsFinished("ChubsExit") then
                    d.puppet = false
                    d.state = "Sit"
                end
                npc.Velocity = npc.Velocity * 0.2
            end
        end

        if d.state == "Sit" then
            mod:SpritePlay(sprite, "ChubsBodyIdleSit")
            npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
            setNextMove(d, 35, function()
                if not d.nibs or (d.nibs and d.nibs:GetData().state == "Idle") then
                    d.targetpos = npc.Position+RandomVector()*120
                    if d.nibs then
                        local rev = 1
                        if rng:RandomFloat() > 0.5 then rev = -1 end
                        d.targetpos = npc.Position+(d.nibs.Position-npc.Position):Resized(160):Rotated(30*rev)
                    end
                    d.targetpos = room:FindFreeTilePosition(d.targetpos, 30)
                    if d.targetpos then
                        d.hopSuffix = "Down"
                        if math.abs((d.targetpos - npc.Position).X) > math.abs((d.targetpos - npc.Position).Y) then
                            d.hopSuffix = "Hori"
                        elseif (d.targetpos - npc.Position).Y < 0 then
                            d.hopSuffix = "Up"
                        end
                        d.state = "Hop"
                    end
                end
            end)
        elseif d.state == "Hop" then
            mod:SpritePlay(sprite, "ChubsBodyHop" .. d.hopSuffix)
            if sprite:IsFinished("ChubsBodyHop" .. d.hopSuffix) then
                d.state = "Sit"
            end
            if sprite:IsEventTriggered("Jump") then
                mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc)
                sprite.FlipX = (d.targetpos - npc.Position).X < 0
                d.startpos = npc.Position
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            end
            if sprite:IsEventTriggered("Land") then
                mod:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, npc)
                local params = ProjectileParams()
                params.Color = mod.Colors.MortisBloodProj
                params.FallingAccelModifier = 0.4
                local vec = (target.Position-npc.Position):Resized(bal.chubsShotSpd)
                local num = bal.chubsShotNum
                for j=1,num do
                    local proj = npc:FireProjectilesEx(npc.Position, vec, 0, params)[1]
                    vec = vec:Rotated(360/num)
                end
                bloodPoof(npc, EffectVariant.POOF02, 3, Vector(0,0), Vector(0.5,0.5))
                d.startpos = nil
                d.targetpos = nil
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            end
            if d.startpos and d.targetpos then
                npc.Velocity = (d.targetpos - d.startpos)/15
            else
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.4)
            end
        elseif d.state == "Roll" then
            mod:SpritePlay(sprite, "ChubsBodyRoll")

            local speed = bal.chubsRollSpeed
            local xvel = speed
            local yvel = speed * 0.5
            if npc.Velocity.X < 0 then
                xvel = xvel * -1
            end
            if npc.Velocity.Y < 0 then
                yvel = yvel * -1
            end
            if npc:CollidesWithGrid() then
                mod:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, npc, rng:RandomFloat()*0.3+0.4, 0.8)
            end
            npc.Velocity = mod:Lerp(npc.Velocity, Vector(xvel, yvel), 0.2)

            setNextMove(d, bal.chubsRollLength, function()
                if npc.Position.X > room:GetCenterPos().X - 70 and npc.Position.X < room:GetCenterPos().X + 70 then
                    d.targetpos = npc.Position + npc.Velocity * 15
                    d.state = "RollEnd"
                else
                    d.stateTimer = 2
                end
            end)
        elseif d.state == "RollEnd" then
            mod:SpritePlay(sprite, "ChubsBodyRollEnd")
            if sprite:IsFinished("ChubsBodyRollEnd") then
                d.state = "Sit"
            end
            if sprite:IsEventTriggered("Jump") then
                mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc)
                d.startpos = npc.Position
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            end
            if sprite:IsEventTriggered("Land") then
                mod:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, npc)
                game:ShakeScreen(8)
                local params = ProjectileParams()
                params.Color = mod.Colors.MortisBloodProj
                params.FallingAccelModifier = 0.4
                local vec = (target.Position-npc.Position):Resized(9)
                local num = bal.chubsShotNum
                for j=1,num do
                    local proj = npc:FireProjectilesEx(npc.Position, vec, 0, params)[1]
                    vec = vec:Rotated(360/num)
                end
                bloodPoof(npc, EffectVariant.POOF02, 3, Vector(0,0), Vector(0.5,0.5))
                d.startpos = nil
                d.targetpos = nil
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            end
            if d.startpos and d.targetpos then
                npc.Velocity = (d.targetpos - d.startpos)/15
            elseif sprite:WasEventTriggered("Land") then
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.4)
            else
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.05)
            end
        elseif d.state == "Charge" then
            if not d.substate then
                mod:SpritePlay(sprite, "ChubsChargeStart")
                if target.Position.X > npc.Position.X then
                    d.chargeSuffix = "Right"
                    d.chargeDir = 1
                    sprite.FlipX = true
                else
                    d.chargeSuffix = "Left"
                    d.chargeDir = -1
                    sprite.FlipX = false
                end
                if sprite:IsFinished("ChubsChargeStart") then
                    d.substate = 1
                    sprite.FlipX = false
                    mod:SpritePlay(sprite, "ChubsCharge" .. d.chargeSuffix)
                end
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
            elseif d.substate == 1 then
                if d.chargeDir == 1 then
                    if npc.Position.X > room:GetCenterPos().X or (d.nibs and d.nibs:GetData().state ~= "Idle") or not d.nibs then
                        d.substate = 10 
                    elseif npc.Position.X < room:GetCenterPos().X and (d.nibs and d.nibs.Position.X > room:GetCenterPos().X) then
                        d.substate = 11
                    elseif npc.Position.X < room:GetCenterPos().X and (d.nibs and d.nibs.Position.X < room:GetCenterPos().X) then
                        d.substate = 12
                    end
                else
                    if npc.Position.X < room:GetCenterPos().X or (d.nibs and d.nibs:GetData().state ~= "Idle") or not d.nibs then
                        d.substate = 10 
                    elseif npc.Position.X > room:GetCenterPos().X and (d.nibs and d.nibs.Position.X < room:GetCenterPos().X) then
                        d.substate = 11
                    elseif npc.Position.X > room:GetCenterPos().X and (d.nibs and d.nibs.Position.X > room:GetCenterPos().X) then
                        d.substate = 12
                    end
                end
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
            elseif d.substate == 10 then
                mod:SpritePlay(sprite, "ChubsCharge" .. d.chargeSuffix)
                npc.Velocity = mod:Lerp(npc.Velocity, Vector(bal.chubsChargeSpd*d.chargeDir,(target.Position.Y-npc.Position.Y)*0.1), 0.15)
            elseif d.substate == 11 then
                mod:SpritePlay(sprite, "ChubsCharge" .. d.chargeSuffix)
                if npc.Position:Distance(d.nibs.Position) < 30 then
                    mod:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, npc)
                    d.nibs.Velocity = npc.Velocity*0.5
                    d.nibs:GetData().state = "Fly"
                    game:ShakeScreen(10)
                    d.substate = 20
                end
                if npc.Position:Distance(d.nibs.Position) < 130 then
                    npc.Velocity = mod:Lerp(npc.Velocity, Vector(bal.chubsChargeSpd*d.chargeDir,(d.nibs.Position.Y-npc.Position.Y)*0.4), 0.1)
                else
                    npc.Velocity = mod:Lerp(npc.Velocity, Vector(bal.chubsChargeSpd*d.chargeDir,(d.nibs.Position.Y-npc.Position.Y)*0.1), 0.15)
                end
            elseif d.substate == 12 then
                mod:SpritePlay(sprite, "ChubsCharge" .. d.chargeSuffix)
                npc.Velocity = mod:Lerp(npc.Velocity, Vector(bal.chubsChargeSpd*d.chargeDir,(d.nibs.Position.Y-npc.Position.Y)*0.05), 0.15)
                if d.chargeDir > 0 and npc.Position.X > room:GetCenterPos().X + 50 then
                    d.chargeSuffix = "Left"
                    d.chargeDir = -1
                    d.substate = 13
                    mod:PlaySound(mod.Sounds.ChubsSkrrt, npc, rng:RandomFloat()*0.3+0.6)
                elseif d.chargeDir < 0 and npc.Position.X < room:GetCenterPos().X - 50 then
                    d.chargeSuffix = "Right"
                    d.chargeDir = 1
                    d.substate = 13
                    mod:PlaySound(mod.Sounds.ChubsSkrrt, npc, rng:RandomFloat()*0.3+0.6)
                end
            elseif d.substate == 13 then
                mod:SpritePlay(sprite, "ChangeDirection" .. d.chargeSuffix)
                if sprite:IsFinished( "ChangeDirection" .. d.chargeSuffix) then
                    if d.nibs and d.nibs:GetData().state == "Idle" then
                        d.substate = 11
                    else
                        d.substate = 10
                    end
                end
                npc.Velocity = mod:Lerp(npc.Velocity, Vector(bal.chubsChargeSpd*d.chargeDir,(target.Position.Y-npc.Position.Y)*0.05), 0.04)
            elseif d.substate == 20 then
                mod:SpritePlay(sprite, "Collide" .. d.chargeSuffix)
                if sprite:IsFinished("Collide" .. d.chargeSuffix) then
                    d.substate = nil
                    d.stateHold = 30
                    d.state = "Idle"
                end
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
            end

            if d.substate and d.substate >= 10 and d.substate < 13 then
                if room:GetGridCollisionAtPos(npc.Position + npc.Velocity*4) >= 4 then
                    mod:PlaySound(mod.Sounds.ChubsBump, npc, rng:RandomFloat()*0.3+0.8)
                    game:ShakeScreen(5)
                    d.substate = 20
                end
            end
        elseif d.state == "Flail" then
            mod:SpritePlay(sprite, "ChubsBodyRoll")
            if not d.nibs then
                d.orbitAngle = nil
                d.orbitAccel = nil
                d.orbitDist = nil
                d.state = "Roll"
            end

            npc.Size = d.startSize/2

            if d.nibs:GetData().substate and d.nibs:GetData().substate > 1 then
                npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

                d.orbitAngle = d.orbitAngle or (npc.Position-d.nibs.Position):GetAngleDegrees()
                d.orbitAccel = d.orbitAccel or 0
                d.orbitDist = d.orbitDist or d.nibs.Position:Distance(npc.Position)
                npc.Velocity = (d.nibs.Position + mod:GetOrbitOffset(d.orbitAngle * (math.pi / 180), d.orbitDist)) - npc.Position

                if d.orbitAccel < 9.5 then d.orbitAccel = d.orbitAccel + 0.075 end
                d.orbitDist = mod:Lerp(d.orbitDist, d.nibs.Position:Distance(target.Position), 0.025)
                d.orbitAngle = d.orbitAngle + math.min(0.5,4-(d.orbitDist*0.02)) + d.orbitAccel
            else
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.03)
            end
        elseif d.state == "Launch" then    
            npc.Size = d.startSize

            mod:SpritePlay(sprite, "ChubsBodyRollLand")
            if not sprite:WasEventTriggered("Jump") then
                d.orbitAngle = nil
                d.orbitAccel = nil
                d.orbitDist = nil

                d.startpos = d.startpos or npc.Position
                d.targetpos = d.targetpos or target.Position

                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.6)
            end

            if sprite:IsEventTriggered("Jump") then
                mod:PlaySound(SoundEffect.SOUND_SWORD_SPIN, npc)
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            end

            if sprite:WasEventTriggered("Jump") and not sprite:WasEventTriggered("Land") then
                if d.startpos and d.targetpos then
                    local ypos = -sprite:GetCurrentAnimationData():GetLayer(1):GetFrame(sprite:GetFrame()):GetPos().Y
                    npc.Velocity = (d.targetpos - d.startpos)/((200-ypos)*0.26)
                else
                    npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.8)
                end
            end

            if sprite:WasEventTriggered("Land") then
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.8)
            end

            if sprite:IsEventTriggered("Land") then
                if d.nibs and d.nibs:GetData().nibsCord then
                    d.nibs:GetData().nibsCord:Kill()
                    mod:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, npc)
                end
                game:ShakeScreen(20)
                for i=0,3 do
                    mod:ScheduleForUpdate(function()
                        local wave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, npc.Position, Vector.Zero, npc):ToEffect()
                        wave.Parent = npc
                        wave.MinRadius = 20
                        wave.MaxRadius = 30+(30*i)
                        wave.Timeout = 2
                    end, 8*i)
                end
                mod:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, npc)
                npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                d.startpos = nil
                d.targetpos = nil
            end
            if sprite:IsFinished("ChubsBodyRollLand") then
                npc.Velocity = Vector.Zero
                d.state = "Sit"
            end

        elseif d.state == "Drag" then
            if not d.substate then
                sprite.FlipX = false
                mod:SpritePlay(sprite, "ChubsCord")
                if sprite:IsEventTriggered("Shoot") then
                    if d.nibs then
                        bloodPoof(npc, EffectVariant.POOF02, 5, Vector(0,-10), Vector(0.3,0.3))
                        d.chubsCord = mod:AttachCord(npc, d.nibs, mod.ENT.CadavraGut.Sub, nil, mod.MortisBlood)

                        mod:PlaySound(SoundEffect.SOUND_HEARTOUT, npc)
                        d.nibs:GetData().state = "Drag"
                        d.nibs.Velocity = (d.nibs.Position-npc.Position):Resized(10)
                    end
                end
                if sprite:IsFinished("ChubsCord") then
                    d.substate = 1
                end
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
            elseif d.substate == 1 then
                mod:SpritePlay(sprite, "ChubsChargeStart")
                if target.Position.X > npc.Position.X then
                    d.chargeSuffix = "Right"
                    d.chargeDir = 1
                    sprite.FlipX = true
                else
                    d.chargeSuffix = "Left"
                    d.chargeDir = -1
                    sprite.FlipX = false
                end
                if sprite:IsFinished("ChubsChargeStart") then
                    d.substate = 2
                    sprite.FlipX = false
                    mod:SpritePlay(sprite, "ChubsCharge" .. d.chargeSuffix)
                end
            elseif d.substate == 2 then
                mod:SpritePlay(sprite, "ChubsCharge" .. d.chargeSuffix)
                if not d.endDrag then
                    if d.chargeDir > 0 and npc.Position.X > room:GetCenterPos().X + 140 then
                        d.chargeSuffix = "Left"
                        d.chargeDir = -1
                        d.substate = 3
                        mod:PlaySound(mod.Sounds.ChubsSkrrt, npc, rng:RandomFloat()*0.3+0.6)
                    elseif d.chargeDir < 0 and npc.Position.X < room:GetCenterPos().X - 140 then
                        d.chargeSuffix = "Right"
                        d.chargeDir = 1
                        d.substate = 3
                        mod:PlaySound(mod.Sounds.ChubsSkrrt, npc, rng:RandomFloat()*0.3+0.6)
                    end
                else
                    if room:GetGridCollisionAtPos(npc.Position + npc.Velocity*4) >= 4 then
                        mod:PlaySound(mod.Sounds.ChubsBump, npc, rng:RandomFloat()*0.3+0.8)
                        game:ShakeScreen(5)
                        if d.chubsCord then
                            d.chubsCord:Kill()
                        end
                        d.substate = 4
                    end
                end
                npc.Velocity = mod:Lerp(npc.Velocity, Vector(bal.chubsDragSpd*d.chargeDir,(target.Position.Y-npc.Position.Y)*0.1), 0.1)
            elseif d.substate == 3 then
                mod:SpritePlay(sprite, "ChangeDirection" .. d.chargeSuffix)
                if sprite:IsFinished( "ChangeDirection" .. d.chargeSuffix) then
                    d.substate = 2
                end
                npc.Velocity = mod:Lerp(npc.Velocity, Vector(bal.chubsDragSpd*d.chargeDir,(target.Position.Y-npc.Position.Y)*0.05), 0.04)
            elseif d.substate == 4 then
                mod:SpritePlay(sprite, "Collide" .. d.chargeSuffix)
                if sprite:IsFinished("Collide" .. d.chargeSuffix) then
                    d.substate = nil
                    d.endDrag = nil
                    d.stateHold = 30
                    d.state = "Idle"
                end
                npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, 0.2)
            end

            if d.substate and d.substate > 1 and d.substate < 4 and not d.endDrag then
                setNextMove(d, 200, function()
                    d.endDrag = true
                end)
            end
        elseif d.state == "DeathHead" or d.state == "DeathNibs" then
            mod:SpritePlay(sprite, "ChubsDie02")
            if sprite:IsFinished("ChubsDie02") then
                npc:Kill()
            end
            npc.Velocity = Vector.Zero
        elseif d.state == "DeathChubs" then
            mod:SpritePlay(sprite, "ChubsDie01")
            if sprite:IsFinished("ChubsDie01") then
                npc:Kill()
            end
            npc.Velocity = Vector.Zero
        end
    end

    if d.head and (d.head:IsDead() or d.head:GetData().death) and not d.death then
        if d.puppet then
            d.state = "DeathChubs"
        else
            d.state = "DeathHead"
        end
        d.death = true
    end

    if sprite:IsEventTriggered("Step") then
        mod:PlaySound(SoundEffect.SOUND_ANIMAL_SQUISH, npc, 1.3, 0.6)
    end

    if d.stateHold and d.stateHold > 0 then
        d.stateHold = d.stateHold - 1
    else
        d.stateHold = nil
    end
    if d.stateTimer and d.stateTimer > 0 then
        d.stateTimer = d.stateTimer - 1
    end
end

function mod:CadavraHurt(npc, sprite, data, amount, damageFlags, source)
    local preventDeath
    if npc.HitPoints - amount <= 0 then
        preventDeath = true
        if data.state ~= "InBody" and not data.death then
            data.state = "DeathHead"
            data.death = true
        end
    end
    if preventDeath then 
        --npc:SetColor(Color(0.5, 0.5, 0.5, 1.0, 200/255, 0/255, 0/255), 2, 0, false, false)
        return false 
    end
end

function mod:CadavraNibsHurt(npc, sprite, data, amount, damageFlags, source)
    if data.head and data.head:ToNPC() and data.head:Exists() then
        local preventDeath = false
        if npc.HitPoints - amount <= 0 then
            preventDeath = true
            data.head:GetData().state = "DeathNibs"
            data.head:GetData().death = true
        end

        local mult = 0.25
        if data.puppet then mult = 1 end
        data.head.HitPoints = data.head.HitPoints - (amount * mult)
        npc.HitPoints = data.head.HitPoints

        if preventDeath then 
            --npc:SetColor(Color(0.5, 0.5, 0.5, 1.0, 200/255, 0/255, 0/255), 2, 0, false, false)
            return false 
        end
    end
end

function mod:CadavraChubsHurt(npc, sprite, data, amount, damageFlags, source)
    if data.head and data.head:ToNPC() and data.head:Exists() then
        local preventDeath = false
        if npc.HitPoints - amount <= 0 then
            preventDeath = true
            data.head:GetData().state = "DeathChubs"
            data.head:GetData().death = true
        end

        local mult = 0.25
        if data.puppet then mult = 1 end
        data.head.HitPoints = data.head.HitPoints - (amount * mult)
        npc.HitPoints = data.head.HitPoints

        if preventDeath then 
            --npc:SetColor(Color(0.5, 0.5, 0.5, 1.0, 200/255, 0/255, 0/255), 2, 0, false, false)
            return false 
        end
    end
end