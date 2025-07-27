local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
    chaseSpeed = 5.5,
    gooCount = 4,
    gooMin = 2,
    gooSelfDist = 60,
    gooMaxDist = 200,
    gooSpreadDist = 60,
    gooHeight = {50,70},
    gooHeightFactor = 0.8,
    eyeSpeed = 2.5,
    regenDelay = {90,120},
    attractSpeed = 10,
    attractLerp = 0.05,
    regenResist = 0.25,
}

local function GetGooTargets(npc, count)
    local rng = npc:GetDropRNG()
    local targets = {}
    local indexes = {}
    local room = game:GetRoom()
    for i = 1, room:GetGridSize() - 1 do
        local gridPos = room:GetGridPosition(i)
        local selfDist = gridPos:Distance(npc.Position)
        if selfDist > bal.gooSelfDist 
        and selfDist < bal.gooMaxDist
        and room:GetGridPath(i) <= 900 then
            table.insert(indexes, i)
        end
    end
    for i = 1, count do
        local target = room:GetGridPosition(mod:GetRandomElem(indexes, rng))
        for tries = 1, 5 do
            local index = mod:GetRandomElem(indexes, rng)
            local gridPos = room:GetGridPosition(index)
            local isValid = true
            for _, other in pairs(targets) do
                if gridPos:Distance(other) < bal.gooSpreadDist then
                    isValid = false
                    break
                end
            end
            if isValid then
                target = gridPos
                break
            end
        end
        table.insert(targets, target)
    end
    return targets
end

local function GetGoo(npc)
    return mod:GatherChildren(npc, mod.ENT.CyabinGoo.ID, mod.ENT.CyabinGoo.Var)
end

local function AbsorbGoo(npc, goo)
    local data = npc:GetData()
    mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc, 1.1, 0.8)
    if data.IsEye then
        npc.MaxHitPoints = goo.HitPoints
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        data.State = "Regen"
        data.Readjusting = false
        data.IsEye = false
    else
        npc.MaxHitPoints = goo.HitPoints + npc.MaxHitPoints  
    end
    npc.HitPoints = npc.HitPoints + goo.HitPoints
    --print(goo.HitPoints, npc.HitPoints, npc.MaxHitPoints)
    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 1, goo.Position, Vector.Zero, goo)
    effect.Color = goo.SplatColor
    effect:Update()
    goo:Remove()
end

function mod:CyabinAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)

    if not data.Init then
        npc.SplatColor = mod.Colors.CyanBlue
        data.OriginalMaxHitPoints = npc.MaxHitPoints
        data.State = "Chase"
        data.Init = true
    end

    if data.State == "Chase" then
        data.IsEye = false
        mod:ChasePlayer(npc, bal.chaseSpeed)
        mod:AnimWalkFrame(npc, sprite, "WalkHori", "WalkVert", true)

        if npc.FrameCount % 45 == 15 then
            mod:PlaySound(SoundEffect.SOUND_ZOMBIE_WALKER_KID)
        end

    elseif data.State == "EyeAppear" then
        npc.Velocity = npc.Velocity * 0.5

        if sprite:IsFinished("EyeAppear") then
            npc.StateFrame = mod:RandomInt(bal.regenDelay, rng)
            data.State = "EyeIdle"
        else
            mod:SpritePlay(sprite, "EyeAppear")
        end

    elseif data.State == "EyeIdle" then
        npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(bal.eyeSpeed)), 0.1)
        mod:SpritePlay(sprite, "EyeIdle")

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.State = "EyePullStart"
        end

    elseif data.State == "EyePullStart" then
        npc.Velocity = npc.Velocity * 0.5

        if sprite:IsFinished("EyePullStart") then
            data.State = "EyePullLoop"
            mod:SpritePlay(sprite, "EyePullLoop")
        elseif sprite:IsEventTriggered("Shoot") then
            if game:GetRoom():GetGridCollisionAtPos(npc.Position) > GridCollisionClass.COLLISION_NONE then
                data.Readjusting = true
                npc.TargetPosition = mod:FindSafeSpawnSpot(npc.Position, 60, 9999, true)
            end 
            for _, goo in pairs(GetGoo(npc)) do
                goo:GetData().State = "Projectile"
                goo:GetData().Attracting = true
                goo:GetSprite():GetLayer(1):SetCropOffset(Vector.Zero)
                goo.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                goo.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                goo:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            end
        else
            mod:SpritePlay(sprite, "EyePullStart")
        end

    elseif data.State == "EyePullLoop" then
        if not data.Readjusting then
            npc.Velocity = npc.Velocity * 0.5
        end
        mod:SpritePlay(sprite, "EyePullLoop")

    elseif data.State == "Regen" then
        npc.Velocity = npc.Velocity * 0.5

        if sprite:IsFinished("Regen") then
            data.State = "Chase"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, npc)
        else
            mod:SpritePlay(sprite, "Regen")
        end
    end

    if rng:RandomFloat() <= 0.025 then
        local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, npc.Position, Vector.Zero, npc):ToEffect()
        splat.Color = npc.SplatColor
        splat.Scale = data.IsEye and 0.5 or 1
        splat:Update()
    end

    if data.IsEye and #GetGoo(npc) <= 0 then
        npc:Kill()
    end

    if data.Readjusting then
        npc.Velocity = (npc.TargetPosition - npc.Position)/10
        if npc.Position:Distance(npc.TargetPosition) <= 5 then
            data.Readjusting = false
        end
    end
end

function mod:CyabinHurt(npc, sprite, data, amount, damageFlags, source)
    if data.IsEye then
        return false
    elseif data.Init then
        local dmgAmount = amount * (data.State == "Regen" and bal.regenResist or 1)
        if npc.HitPoints - dmgAmount <= 0 and npc.MaxHitPoints > 1 then
            npc:BloodExplode()
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
            data.State = "EyeAppear"
            data.IsEye = true
            local gooCount = math.max(math.ceil(npc.MaxHitPoints / (data.OriginalMaxHitPoints / bal.gooCount)), bal.gooMin)
            for _, target in pairs(GetGooTargets(npc, gooCount)) do
                local height = mod:RandomInt(bal.gooHeight,rng)
                local expectedAirTime = math.ceil((1/(math.pi / (height * bal.gooHeightFactor))) * 1.2)
                local vel = (target - npc.Position)/expectedAirTime
                local goo = Isaac.Spawn(mod.ENT.CyabinGoo.ID, mod.ENT.CyabinGoo.Var, 0, npc.Position, vel, npc)
                goo:GetData().MaxHeight = height
                goo.Parent = npc
                goo.HitPoints = npc.MaxHitPoints / bal.gooCount
                goo:Update()
            end
            npc.HitPoints = 0.1
            npc.MaxHitPoints = 1
            return false
        elseif data.State == "Regen" then
            return {Damage = dmgAmount}
        end
    end
end

function mod:CyabinGooAI(npc, sprite, data)
    local rng = npc:GetDropRNG()

    if not data.Init then
        data.LaunchFrame = 0
        data.MaxHeight = data.MaxHeight or mod:RandomInt(bal.gooHeight,rng)
        data.AirTime = math.pi / (data.MaxHeight * bal.gooHeightFactor)
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET)
        npc.SplatColor = mod.Colors.CyanBlue
        data.State = "Projectile"
        data.Init = true
    end

    if npc.Parent and not mod:IsReallyDead(npc.Parent) then
        if data.State == "Projectile" then
            mod:SpritePlay(sprite, "Projectile")
    
            if data.Attracting then
                npc.SpriteOffset = Vector(0, mod:Lerp(npc.SpriteOffset.Y, -5, 0.05))
                npc.Velocity = mod:Lerp(npc.Velocity, (npc.Parent.Position - npc.Position):Resized(bal.attractSpeed), bal.attractLerp)

                if npc.Position:Distance(npc.Parent.Position) < npc.Parent.Size + npc.Size then
                    AbsorbGoo(npc.Parent, npc)
                end

            elseif data.LaunchFrame > 0 and npc.SpriteOffset.Y >= 0 then
                npc.SpriteOffset = Vector.Zero
                npc.Velocity = npc.Velocity * 0.25
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                data.State = "Land"
                data.LaunchFrame = nil
                sprite:GetLayer(1):SetCropOffset(Vector(24*mod:RandomInt(0,2,rng),0))
                mod:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, npc, 1)
                mod:PlaySound(SoundEffect.SOUND_GOOATTACH0, npc, 1.2, 0.75)
                npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET)
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, npc.Position, Vector.Zero, npc)
                effect.DepthOffset = -120
                effect.SpriteScale = Vector(1,0.65)
                effect.Color = npc.SplatColor
                effect:Update()
            end
    
            if npc.FrameCount % 4 == 0 then
                local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, npc.Position, -npc.Velocity:Rotated(mod:RandomInt(-10,10,rng)) * 0.5, npc)
                trail.SpriteOffset = npc.SpriteOffset
                trail.DepthOffset = -40
                trail.Color = npc.SplatColor
                trail.SpriteScale = Vector(0.3,0.3)
                trail:Update()
            end
    
        elseif data.State == "Land" then
            npc.Velocity = npc.Velocity * 0.75
            mod:SpritePlay(sprite, "Land")
    
            if rng:RandomFloat() <= 0.025 then
                local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, npc.Position, Vector.Zero, npc):ToEffect()
                splat.Color = npc.SplatColor
                splat.Scale = 0.75
                splat:Update()
            end
        end
    else
        npc:Kill()
    end
end

function mod:CyabinGooRender(npc, sprite, data)
    if data.Init and mod:IsNormalRender() then
        if data.State == "Projectile" then
            if data.LaunchFrame then
                local curve = math.sin(data.LaunchFrame)
                local height = 0 - (curve * data.MaxHeight)
                npc.SpriteOffset = Vector(0, height)
                data.LaunchFrame = data.LaunchFrame + data.AirTime
            end
            npc.EntityCollisionClass = (npc.SpriteOffset.Y > -10) and EntityCollisionClass.ENTCOLL_PLAYEROBJECTS or EntityCollisionClass.ENTCOLL_NONE
        end
    end
end

function mod:CyabinGooDevolve(npc)
    local brain = Isaac.Spawn(EntityType.ENTITY_BRAIN, 0, 0, npc.Position, Vector.Zero, npc):ToNPC()
    brain.Scale = 0.65
    brain.MaxHitPoints = brain.MaxHitPoints * 0.5
    brain.HitPoints = brain.MaxHitPoints
    brain:Update()
    return mod:D10Cleanup(npc, true)
end