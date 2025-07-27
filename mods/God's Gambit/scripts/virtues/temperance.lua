local mod = GodsGambit
local game = Game()
local sfx = SFXManager()

local bal = {
    moveSpeed = 3,
    creepTrailDuration = 180,
    attackCooldown = {60,120},

    projCreepDuration = 90,
    leechSpawnNum = {1,3},
    leechCap = 6,
    longCreepDuration = 300,

    directionalProjNum = {9,12},
    directionalProjSpeed = {5,15},
    directionalProjSpread = 20,
    superLeechCap = 1,

    ringProjNum = {8,11},
    ringProjSpeed = {4,10},
    --superRingSpeed = 9,
    --superRingNum = 10,

    slideChance = 0.5,
    slideSpeed = 15,
    slideProjSpeed = {2,4},
    slideTrailDuration = 150,
    --superSlideProjSpeed = 10,

    superClusterSpeed = 11,
}

local params = ProjectileParams()
params.Color = mod.Colors.TemperanceProj
params.Variant = ProjectileVariant.PROJECTILE_PUKE
params.FallingAccelModifier = 1

local params2 = ProjectileParams()
params2.FallingAccelModifier = 1

local function MakeVomitCreep(npc, pos, scale, duration, scale2)
    pos = pos or npc.Position
    scale = scale or 1
    scale2 = scale2 or 1
    duration = duration or 150

    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, (npc and mod:isFriend(npc)) and EffectVariant.PLAYER_CREEP_RED or EffectVariant.CREEP_RED, 0, pos, Vector.Zero, npc):ToEffect()
    creep.Color = mod.Colors.TemperanceCreep
    creep:GetSprite().Color = mod.Colors.TemperanceCreep
    creep.SpriteScale = Vector(scale, scale)
    creep.Scale = scale2
    creep:SetTimeout(game:GetRoom():HasWater() and 1 or duration)
    creep:Update()

    local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, pos, Vector.Zero, npc)
    local splatScale = scale * 0.75
    splat.SpriteScale = Vector(splatScale, splatScale)
    splat.Color = mod:CloneColor(mod.Colors.TemperanceSplat, 0.75)
    splat:Update()

    return creep
end

local function FireVomitProj(npc, vel, fallSpeed)
    local rng = npc:GetDropRNG()
    fallSpeed = fallSpeed or {-20,-5}
    params2.Scale = mod:RandomInt(6,14,rng) * 0.1
    params2.FallingSpeedModifier = mod:RandomInt(fallSpeed, rng)
    local proj = npc:FireProjectilesEx(npc.Position, vel, 0, params)[1]
    proj:GetData().projType = "Temperance"
    return proj
end

local function FireCluster(npc, vel, num, fallSpeed)
    local rng = npc:GetDropRNG()
    fallSpeed = fallSpeed or {-20,-5}
    for i = 1, mod:RandomInt(num,rng) do
        params2.Scale = mod:RandomInt(8,16,rng) * 0.1
        params2.FallingSpeedModifier = mod:RandomInt(fallSpeed, rng)
        npc:FireProjectiles(npc.Position, vel:Rotated(mod:RandomInRange(-15,rng)) * (mod:RandomInt(80,120,rng) * 0.01), 0, params2)
    end
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, npc.Position, Vector.Zero, npc)
    poof.DepthOffset = -40
    poof.SpriteOffset = Vector(0,-8)
    poof:Update()
end

local function DoSlide(npc, data)
    npc.Velocity = mod:Lerp(npc.Velocity, npc.V1:Resized(bal.slideSpeed), 0.3)
    if npc.FrameCount % 3 == 0 then
        local rng = npc:GetDropRNG()
        MakeVomitCreep(npc, npc.Position, 1, bal.slideTrailDuration)
        FireVomitProj(npc, npc.V1:Rotated((rng:RandomFloat() <= 0.5 and 90 or -90) + mod:RandomInRange(45,rng)):Resized(mod:RandomInt(bal.slideProjSpeed,rng)), {-5,-15})
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, npc.Position, Vector.Zero, npc)
        poof.Color = mod.Colors.TemperanceSplat
        poof.DepthOffset = -40
        poof.SpriteScale = Vector(1,0.75)
        poof:Update()
        if npc.Variant == mod.ENT.SuperTemperance.Var then
            --[[params2.Scale = 1
            npc:FireProjectiles(npc.Position, (mod:GetPlayerTargetPos(npc) - npc.Position):Resized(bal.superSlideProjSpeed), 0, params2)
            mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 1, 0.75)]]
        end
    end
    if npc.FrameCount % 4 == 0 then
        mod:PlaySound(SoundEffect.SOUND_HEARTIN, npc, 1.5, 0.4)
    end

    if game:GetRoom():GetGridCollisionAtPos(npc.Position + npc.V1:Resized(25)) > GridCollisionClass.COLLISION_NONE then
        mod:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, npc, 1.2, 0.6)
        mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc, 2, 0.5)
        MakeVomitCreep(npc, npc.Position, 2, bal.longCreepDuration)
        npc.Velocity = -npc.V1:Resized(10)
        data.State = "SlideStop"
        npc:GetSprite():Play("SlideEnd"..data.AnimSuffix, true)
        data.IsSliding = false
    end
end

local function TryThrowLeech(npc, targetpos)
    if mod:GetEntityCount(EntityType.ENTITY_SMALL_LEECH) < bal.leechCap then
        local spawnPos = mod:FindSafeSpawnSpot(targetpos, 80) or npc.Position 
        local leech = EntityNPC.ThrowLeech(npc.Position, npc, spawnPos + RandomVector():Resized(mod:RandomInt(0,20)), mod:RandomInt(-15,-5), false)
        leech:GetSprite():ReplaceSpritesheet(0, "gfx/bosses/virtues/temperance/810.000_small_leech_temperance.png", true)
        leech:GetData().TemperanceLeech = true
        leech:Update()
        return leech
    end
end

function mod:TemperanceAI(npc, sprite, data)
    local targetpos = mod:GetPlayerTargetPos(npc)
    local rng = npc:GetDropRNG()
    local isSuper = (npc.Variant == mod.ENT.SuperTemperance.Var)

    if not data.Init then
        npc.SplatColor = mod.Colors.TemperanceSplat
        npc.StateFrame = mod:RandomInt(bal.attackCooldown, rng)
        data.State = "Idle"
        data.Init = true
    end

    if npc.FrameCount % 8 == 0 and not data.IsSliding then
        MakeVomitCreep(npc, npc.Position, 1, bal.creepTrailDuration)
    end

    if data.State == "Idle" then
        mod:WanderGridAligned(npc, data, bal.moveSpeed, 0.3)
        if npc.Velocity:Length() >= 0.05 then
            mod:SpritePlay(sprite, "WalkHori")
        else
            sprite:SetFrame("WalkHori", 0)
        end
        mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            local isAligned = mod:IsAlignedWithPos(npc.Position, targetpos, 80, nil, 400)
            data.AnimSuffix, sprite.FlipX = mod:GetMoveString(targetpos - npc.Position, true)
            npc.V1 = mod:MoveStringToVec(data.AnimSuffix, sprite.FlipX)
            if isAligned and rng:RandomFloat() <= bal.slideChance and game:GetRoom():CheckLine(npc.Position, targetpos, LineCheckMode.ENTITY) and not mod:isScare(npc) then
                data.State = "SlideStart"
            elseif isAligned then
                data.State = "DirectionalShoot"
            else
                data.State = "RingShoot"
            end
        end

    elseif data.State == "DirectionalShoot" then
        npc.Velocity = npc.Velocity * 0.7

        if sprite:IsFinished("Attack"..data.AnimSuffix) then
            npc.StateFrame = mod:RandomInt(bal.attackCooldown, rng)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Shoot") then 
            for i = 1, mod:RandomInt(bal.directionalProjNum,rng) do
                FireVomitProj(npc, npc.V1:Resized(mod:RandomInt(bal.directionalProjSpeed,rng)):Rotated(mod:RandomInRange(bal.directionalProjSpread, rng)))
            end
            for i = 1, mod:RandomInt(bal.leechSpawnNum, rng) do
                TryThrowLeech(npc, npc.Position + npc.V1:Resized(80) + RandomVector():Resized(mod:RandomInt(30,80,rng)))
            end
            mod:PlaySound(SoundEffect.SOUND_HEARTOUT, npc)
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, npc.Position, Vector.Zero, npc)
            poof.Color = mod.Colors.TemperanceSplat
            poof.SpriteOffset = npc:GetNullOffset("EffectPos")
            poof.DepthOffset = data.AnimSuffix == "Up" and -40 or 40
            poof:Update()
            MakeVomitCreep(npc, npc.Position, 3, bal.longCreepDuration)
            if isSuper and mod:GetEntityCount(EntityType.ENTITY_LEECH) < bal.superLeechCap then
                local leech = Isaac.Spawn(EntityType.ENTITY_LEECH, 0, 0, npc.Position + npc.V1:Resized(15), npc.V1:Resized(5), npc):ToNPC()
                leech.State = 8
                leech.V1 = npc.V1:Resized(1.55)
                leech:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                leech:Update()
                mod:PlaySound(SoundEffect.SOUND_LEECH, leech)
                mod:PlaySound(SoundEffect.SOUND_SUMMONSOUND, npc)
            end
        else
            mod:SpritePlay(sprite, "Attack"..data.AnimSuffix)
        end

    elseif data.State == "RingShoot" then
        npc.Velocity = npc.Velocity * 0.7

        if sprite:IsFinished("FatAttack") then
            npc.StateFrame = mod:RandomInt(bal.attackCooldown, rng)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Shoot") then
            for i = 1, mod:RandomInt(bal.ringProjNum,rng) do
                FireVomitProj(npc, RandomVector() * mod:RandomInt(bal.ringProjSpeed,rng))
            end
            for i = 1, mod:RandomInt(bal.leechSpawnNum, rng) do
                TryThrowLeech(npc, npc.Position + RandomVector():Resized(mod:RandomInt(30,80,rng)))
            end
            mod:PlaySound(SoundEffect.SOUND_HEARTOUT, npc)
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 4, npc.Position, Vector.Zero, npc)
            poof.Color = mod.Colors.TemperanceSplat
            poof:Update()
            MakeVomitCreep(npc, npc.Position, 3, bal.longCreepDuration)
            if isSuper then
                FireCluster(npc, (targetpos - npc.Position):Resized(bal.superClusterSpeed), {6,9})
                --[[params2.Scale = 1.25
                params2.CircleAngle = mod:RandomAngle(rng)
                npc:FireProjectiles(npc.Position, Vector(bal.superRingSpeed, bal.superRingNum), ProjectileMode.CIRCLE_CUSTOM, params2)]]
            end
        else
            mod:SpritePlay(sprite, "FatAttack")
        end

    elseif data.State == "SlideStart" then
        if sprite:WasEventTriggered("Shoot") then
            DoSlide(npc, data)
        else
            npc.Velocity = npc.Velocity * 0.7
        end

        if sprite:IsFinished("SlideStart"..data.AnimSuffix) then
            sprite:Play("SlideLoop"..data.AnimSuffix, true)
            data.State = "Sliding"
        elseif sprite:IsEventTriggered("Shoot") then
            npc.Velocity = npc.V1:Resized(bal.slideSpeed)
            data.IsSliding = true
            DoSlide(npc, data)
            MakeVomitCreep(npc, npc.Position, 2, bal.longCreepDuration)
            mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc)
            mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc)
            if isSuper then
                FireCluster(npc, (targetpos - npc.Position):Resized(bal.superClusterSpeed), {6,9})
                mod:PlaySound(SoundEffect.SOUND_HEARTOUT, npc)
            end
        else
            mod:SpritePlay(sprite, "SlideStart"..data.AnimSuffix)
        end

    elseif data.State == "Sliding" then
        mod:SpritePlay(sprite, "SlideLoop"..data.AnimSuffix)
        DoSlide(npc, data)

    elseif data.State == "SlideStop" then
        npc.Velocity = npc.Velocity * 0.5

        if sprite:IsFinished("SlideEnd"..data.AnimSuffix) then
            npc.StateFrame = mod:RandomInt(bal.attackCooldown, rng)
            data.State = "Idle"
        else
            mod:SpritePlay(sprite, "SlideEnd"..data.AnimSuffix)
        end
    end
end

function mod:TemperanceProjectiledeath(proj, data)
    MakeVomitCreep(proj.SpawnerEntity, proj.Position, 1, bal.projCreepDuration)
end

mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_UPDATE, CallbackPriority.LATE, function(_, npc)
    local data = npc:GetData()
    if npc:GetData().TemperanceLeech then
        local sprite = npc:GetSprite()
        npc:GetSprite():GetLayer(0):SetColor(Color.Default)

        if npc.State ~= 6 and not game:GetRoom():HasWater() then
            for _, creep in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED)) do
                if creep.Position:Distance(npc.Position) < creep.Size + npc.Size then
                    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
                    npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(10)), 0.05)
                    local anim = "Swim"..mod:GetMoveString(targetpos - npc.Position)
                    if npc.State ~= 3 or not sprite:IsPlaying() then
                        sprite:Play(anim, true)
                    else
                        sprite:SetAnimation(anim, false)
                    end
                    npc.State = 3
                    if npc.FrameCount % 5 == 0 and npc.Velocity:Length() > 3 then
                        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 1, npc.Position, Vector.Zero, npc)
                        poof.Color = mod.Colors.TemperanceSplat
                        poof.DepthOffset = -40
                        poof.SpriteScale = Vector(1,0.75)
                        poof:Update()
                    end
                    return true
                end
            end
        end
    end
end, EntityType.ENTITY_SMALL_LEECH)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, npc)
    if npc:GetData().TemperanceLeech then
        for _, poof in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.LEECH_EXPLOSION)) do
            if poof.FrameCount <= 1 and poof.Position:Distance(npc.Position) <= 5 then
                poof:GetSprite():ReplaceSpritesheet(0, "gfx/bosses/virtues/temperance/810.000_small_leech_temperance.png", true)
                break
            end
        end
    end
end, EntityType.ENTITY_SMALL_LEECH)