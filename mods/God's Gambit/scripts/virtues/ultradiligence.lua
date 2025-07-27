local mod = GodsGambit
local game = Game()
local sfx = SFXManager()

local bal = {
    ramblerSpeed = {2,6},
    ramblerIdleTime = {30,300},
    ramblerChaseTime = {30,150},

    rattlerSpeed = 4.5,
    rattlerCooldown = {90,150},
    rattlerProjSpeed = 8,
    rattlerMaxAngle = 15,

    sticklerSpeed = 2,
    sticklerSpeedScaling = 1,
    sticklerMaxSummons = 2,
    sticklerCooldown = {150,210},

    slimerSpeed = {35,50},
    slimerCooldown = {150,210},
    slimerDuration = 180,
}

local function CalculateAgression()
    local agression = 0
    for _, var in pairs({mod.ENT.DiligentRambler.Var, mod.ENT.DiligentRattler.Var, mod.ENT.DiligentStickler.Var, mod.ENT.DiligentSlimer.Var}) do
        if mod:GetEntityCount(mod.ENT.DiligentRambler.ID, var) <= 0 then
            agression = agression + 1
        end
    end
    return agression
end

function mod:DiligentRamblerAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)

    if not data.Init then
        npc.StateFrame = mod:RandomInt(bal.ramblerIdleTime, rng)
        data.State = "Idle"
        data.Init = true
    end

    mod:AnimWalkFrame(npc, sprite, "WalkHori", "WalkVert", true)

    if data.State == "Idle" then
        mod:WanderAbout(npc, data, bal.ramblerSpeed[1], 0.3, 0, 120)
        mod:SpriteOverlayPlay(sprite, "Idle")

        npc.StateFrame = npc.StateFrame - (1 + CalculateAgression())
        if npc.StateFrame <= 0 and npc.Pathfinder:HasPathToPos(targetpos, false) then
            data.State = "ChaseStart"
        end

    elseif data.State == "ChaseStart" then
        npc.Velocity = npc.Velocity * 0.75

        if sprite:IsOverlayFinished("ChaseStart") then
            npc.StateFrame = mod:RandomInt(bal.ramblerChaseTime, rng)
            data.State = "Chasing"
        elseif sprite:IsOverlayEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_CHILD_ANGRY_ROAR, npc)
        else
            mod:SpriteOverlayPlay(sprite, "ChaseStart")
        end

    
    elseif data.State == "Chasing" then
        mod:ChasePlayer(npc, bal.ramblerSpeed[2], 0.3)
        mod:SpriteOverlayPlay(sprite, "Chasing")

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 and CalculateAgression() < 3 then
            data.State = "ChaseStop"
        end

    
    elseif data.State == "ChaseStop" then
        npc.Velocity = npc.Velocity * 0.75

        if sprite:IsOverlayFinished("ChaseStop") then
            npc.StateFrame = mod:RandomInt(bal.ramblerIdleTime, rng)
            data.State = "Idle"
        else
            mod:SpriteOverlayPlay(sprite, "ChaseStop")
        end
    end
end

local params = ProjectileParams()
params.Variant = ProjectileVariant.PROJECTILE_BONE
params.Spread = 0.66

function mod:DiligentRattlerAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)

    if not data.Init then
        npc.SplatColor = mod.Colors.Tar
        npc.StateFrame = mod:RandomInt(bal.rattlerCooldown, rng)
        data.State = "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        mod:WanderGridAligned(npc, data, bal.rattlerSpeed, 0.3)
        mod:AnimWalkFrame(npc, sprite, "WalkHori", {"WalkDown", "WalkUp"}, true)
        
        npc.StateFrame = npc.StateFrame - (1 + CalculateAgression())
        if npc.StateFrame <= 0 then
            if mod:IsAlignedWithPos(npc.Position, targetpos, 40, LineCheckMode.PROJECTILE, 250, -npc.Velocity) then
                data.AnimSuffix, sprite.FlipX = mod:GetMoveString(targetpos - npc.Position, true)
                npc.V1 = mod:MoveStringToVec(data.AnimSuffix, sprite.FlipX)
                data.State = "Shoot"
            end
        end
    elseif data.State == "Shoot" then
        npc.Velocity = npc.Velocity * 0.5

        if sprite:IsFinished("Attack"..data.AnimSuffix) then
            npc.StateFrame = mod:RandomInt(bal.rattlerCooldown, rng)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Shoot") then
            local vel = mod:AngleLimitVector(npc.V1, targetpos - npc.Position, bal.rattlerMaxAngle):Resized(bal.rattlerProjSpeed)
            npc:FireProjectiles(npc.Position, vel, ProjectileMode.SPREAD_THREE, params)
            mod:PlaySound(SoundEffect.SOUND_SCAMPER, npc)
        else
            mod:SpritePlay(sprite, "Attack"..data.AnimSuffix)
        end
    end
end

local function GetSticklerSummon(rng)
    local summons = FiendFolio and {
        {FiendFolio.FF.Drumstick.ID, FiendFolio.FF.Drumstick.Var},
        {FiendFolio.FF.Litling.ID, FiendFolio.FF.Litling.Var},
        {FiendFolio.FF.Mayfly.ID, FiendFolio.FF.Mayfly.Var},
    } or {
        {EntityType.ENTITY_WILLO},
        {EntityType.ENTITY_ROCK_SPIDER},
        {EntityType.ENTITY_DIP, 3},
    }
    return mod:GetRandomElem(summons, rng)
end

local function CountSticklerSummons(npc)
    local summons = 0
    for _, enemy in pairs(Isaac.FindInRadius(npc.Position, 600, EntityPartition.ENEMY)) do
        if enemy.SpawnerType == mod.ENT.DiligentStickler.ID and enemy.SpawnerVariant == mod.ENT.DiligentStickler.Var then
            summons = summons + 1
        end
    end
    return summons
end

function mod:DiligentSticklerAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)

    if not data.Init then
        npc.SplatColor = mod.Colors.PurpleGuts
        npc.StateFrame = mod:RandomInt(bal.sticklerCooldown, rng)
        data.State = "Idle"
        data.Init = true
    end
    
    if data.State == "Idle" then
        mod:SpritePlay(sprite, "Idle")

        local agression = CalculateAgression()
        local speed = bal.sticklerSpeed + (bal.sticklerSpeedScaling * agression)
        if agression >= 2 or mod:isCharm(npc) then
            npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, targetpos - npc.Position):Resized(speed), 0.1)
        else
            mod:WanderAboutAir(npc, data, speed, 0.1, 0, 0)
        end

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if CountSticklerSummons(npc) < (bal.sticklerMaxSummons + math.ceil(agression/2)) then
                data.State = "Attack"
            else
                npc.StateFrame = 60
            end
        end

    elseif data.State == "Attack" then
        npc.Velocity = npc.Velocity * 0.75

        if sprite:IsFinished("Attack") then
            npc.StateFrame = mod:RandomInt(bal.sticklerCooldown, rng)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Shoot") then
            local spawn = GetSticklerSummon(rng)
            Isaac.Spawn(spawn[1], spawn[2] or 0, spawn[3] or 0, npc.Position + Vector(0,40), Vector.Zero, npc)
            mod:PlaySound(SoundEffect.SOUND_SUMMONSOUND, npc)
        else
            mod:SpritePlay(sprite, "Attack")
        end
    end
end

local function GetNewWanderOffset(npc)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()
    for tries = 0, 10 do
        local trypos = npc.TargetPosition + rng:RandomVector():Resized(mod:RandomInt({30,100}, rng))
        if room:IsPositionInRoom(trypos, 15) then
            return trypos
        end
    end
    return npc.TargetPosition
end

local function GetNewWanderTarget(npc)
    local agression = CalculateAgression()
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()
    local fires = Isaac.FindByType(EntityType.ENTITY_FIREPLACE)
    local valids1 = {}
    local valids2 = {}
    for i = 0, room:GetGridSize() - 1 do
        local gridpos = room:GetGridPosition(i)
        if room:GetGridCollision(i) < GridCollisionClass.COLLISION_WALL and mod:IsPosSafeForFlying(gridpos, fires) then
            if gridpos:Distance(game:GetNearestPlayer(gridpos).Position) < 200 - (agression * 40)
            and gridpos:Distance(npc.Position) > 60 then
                table.insert(valids1, gridpos)
            else
                table.insert(valids2, gridpos)
            end
        end
    end
    npc.TargetPosition = mod:GetRandomElem(valids1, rng) or mod:GetRandomElem(valids2, rng) or npc.Position
    npc.V1 = GetNewWanderOffset(npc)
    npc.StateFrame = mod:RandomInt({30,90}, rng)
end

local slimerCreeps = {
    {EffectVariant.CREEP_RED, mod:ColorFrom255(183,21,0)},
    {EffectVariant.CREEP_GREEN, mod:ColorFrom255(26,158,0)},
    {EffectVariant.CREEP_YELLOW, mod:ColorFrom255(255,242,0)},
    {EffectVariant.CREEP_BLACK, mod:ColorFrom255(30,30,30)},
    {EffectVariant.CREEP_WHITE, mod:ColorFrom255(255,255,255)},
    {EffectVariant.CREEP_SLIPPERY_BROWN, mod:ColorFrom255(188,119,0)},
}

local function SelectSlimerCreep(npc, sprite, rng)
    local creepData = mod:GetRandomElem(slimerCreeps, rng)
    npc.I1 = creepData[1]
    sprite:GetLayer("slime"):SetColor(creepData[2])
end

function mod:DiligentSlimerAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)

    if not data.Init then
        npc.SplatColor = mod.Colors.Tar
        npc.ProjectileCooldown = mod:RandomInt(bal.slimerCooldown, rng)
        GetNewWanderTarget(npc)
        data.State = "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        mod:SpritePlay(sprite, "Idle")

        if npc.FrameCount > 0 and not data.BloodDripped then
            sprite:SetOverlayRenderPriority(true)
            sprite:PlayOverlay("BloodDrip", true)
            sprite:SetOverlayFrame(mod:RandomInt(0,12,rng))
            sprite:Continue()
            data.BloodDripped = true
        end

        if npc.Position:Distance(npc.TargetPosition) <= 100 or npc:CollidesWithGrid() then
            npc.StateFrame = npc.StateFrame - ((npc:CollidesWithGrid() and 20 or 1) + CalculateAgression())
            if npc.StateFrame <= 0 then
                GetNewWanderTarget(npc)
            end
        end
        if npc.Position:Distance(npc.V1) <= 8 then
            npc.V1 = GetNewWanderOffset(npc)
        else
            if mod:isScareOrConfuse(npc) then
                npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position - targetpos):Resized(mod:RandomInt(bal.slimerSpeed,rng) * 0.1), mod:RandomInt(5,25,rng) * 0.01)
                npc.StateFrame = npc.StateFrame - 20
            else
                npc.Velocity = mod:Lerp(npc.Velocity, (npc.V1 - npc.Position):Resized(mod:RandomInt(bal.slimerSpeed,rng) * 0.1), mod:RandomInt(5,25,rng) * 0.01)
            end
        end

        npc.ProjectileCooldown = npc.ProjectileCooldown - (1 + CalculateAgression())
        if npc.ProjectileCooldown <= 0 then
            SelectSlimerCreep(npc, sprite, rng)
            data.State = "Attack"
        end

    elseif data.State == "Attack" then
        npc.Velocity = npc.Velocity * 0.75

        if sprite:IsFinished("Attack") then
            npc.ProjectileCooldown = mod:RandomInt(bal.slimerCooldown, rng)
            GetNewWanderTarget(npc)
            data.State = "Idle"
            data.BloodDripped = false
        elseif sprite:IsEventTriggered("Shoot") then
            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, npc.I1, 0, npc.Position, Vector.Zero, npc):ToEffect()
            creep.SpriteScale = Vector(3, 3)
            creep:SetTimeout(bal.slimerDuration)
            local growDuration = 10
            creep.Scale = 0
            creep.Size = 0
            local growRate = 1/growDuration
            for i = 1, growDuration do
                mod:ScheduleForUpdate(function() 
                    creep.Scale = creep.Scale + growRate
                    creep.Size = creep.Scale * (2 * 20)
                    creep:GetSprite().Scale = Vector(creep.Scale, creep.Scale)
                end, i)
                mod:ScheduleForUpdate(function() 
                    creep.Scale = 1
                    creep.Size = creep.Scale * (2 * 20)
                    creep:GetSprite().Scale = Vector.One
                end, growDuration)
            end
            creep:Update()
            mod:PlaySound(SoundEffect.SOUND_GASCAN_POUR, npc)
        else
            mod:SpritePlay(sprite, "Attack")
        end
    end

    if sprite:IsOverlayEventTriggered("Shoot") then
        local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, npc.Position, Vector.Zero, npc):ToEffect()
        splat.Scale = 0.25
        splat.Color = mod.Colors.Tar
        splat:Update()
    end
end