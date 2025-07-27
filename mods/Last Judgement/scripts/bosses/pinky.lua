local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
    idleTime = {30,45},

    --Roid Rage
    numRoidJumps = 3,
    roidAirTime = 15,
    roidProjSpeed = {4,6},
    roidShockwaveRadius = 80,

    --Speed Ball
    rollDuration = 150,
    rollSpeed = 11,
    rollSpeedAdrenaline = 12.5,
    rollAngleVar = 15,
    rollProjSpeed = 8.5,

    --Experimental Treatment
    randomRingNum = 20,
    randomRingSpeed = {5,11},

    staggerRingNum = 24,
    staggerRingSpeed = 3,
    staggerRingDelay = 10,

    orbitRingNum = 10,
    orbitRingSpeed = 5,

    sawRingNum = 16,
    sawRingSpeed = 5,

    --The Virus
    cloudDuration = 390,

    --Synthoil
    numSpins = 4,
    spinSpeed = 18,
    spinDuration = 10,
    spinRadius = 60,

    --Growth Hormones
    numHops = 5,
    hopSpeed = 4.5,
    hopSpeedAdrenaline = 6,
    growthSizeMult = Vector(3,1.5),
    numRainProjs = 13,

    --Adrenaline
    adrenalineThresh = 0.5,
    adrenalineSpeedup = 1.25,

    --Euthanasia
    deathProjSpeed = 12,
    deathProjNum = 12,
}

local roidParams = ProjectileParams()
roidParams.Color = mod.Colors.RoidRageProj
roidParams.FallingAccelModifier = 1
roidParams.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE

local rollParams = ProjectileParams()
rollParams.Color = mod.Colors.SpeedBallProj
rollParams.Scale = 1.5

local expParams = ProjectileParams()

local vomitParams = ProjectileParams()
vomitParams.Color = mod.Colors.IpecacProj
vomitParams.FallingSpeedModifier = 10
vomitParams.FallingAccelModifier = 1.5
vomitParams.HeightModifier = -600

local rainParams = ProjectileParams()
rainParams.Color = mod.Colors.GrowthHormonesProj
rainParams.FallingSpeedModifier = 10
rainParams.FallingAccelModifier = 1.5
rainParams.HeightModifier = -600

local deathParams = ProjectileParams()
deathParams.Color = mod.Colors.Euthanasia
deathParams.Scale = 2

local function ShouldBuff(npc)
    return (npc.HitPoints <= npc.MaxHitPoints * bal.adrenalineThresh and not npc:GetData().Adrenalized)
end

local function ShouldDie(npc)
    return npc.HitPoints <= 0 
end

local forceAttack = nil
local function SelectAttack(npc)
    local data = npc:GetData()
    if ShouldBuff(npc) then
        data.CurrentAttack = "Adrenaline"
    elseif forceAttack then
        data.CurrentAttack = forceAttack
    else
        if not (data.AttackPool and #data.AttackPool > 0) then
            data.AttackPool = {"Exp", "Roid", "Speed", "Red", "Synth", "Growth"}
        end
        local index = mod:GetRandomIndex(data.AttackPool, npc:GetDropRNG())
        data.CurrentAttack = data.AttackPool[index]
        table.remove(data.AttackPool, index)
    end
end

local function ToggleCollision(npc)
    if mod:ToggleCollision(npc) then
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
    else
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
    end
end

local function DestroyInRadius(npc, radius)
    mod:DestroyGridsInRadius(npc.Position, radius)
    for _, ent in pairs(Isaac.FindInRadius(npc.Position, radius, EntityPartition.ENEMY)) do
        if ent:IsEnemy() then
            if not ((ent.Type == npc.Type and ent.Variant == npc.Variant) or (mod:isFriend(npc) and mod:isFriend(ent))) then
                ent:TakeDamage(40, 0, EntityRef(npc), 0)
            end
        end
    end
end

local function RollAround(npc)
    local data = npc:GetData()
    npc.Velocity = npc.Velocity:Resized(data.Adrenalized and bal.rollSpeedAdrenaline or bal.rollSpeed)
    DestroyInRadius(npc, 65)

    if npc:CollidesWithGrid() then
        local rng = npc:GetDropRNG()
        data.RollBounceSpeed = -10
        npc.Velocity = npc.Velocity:Rotated(mod:RandomInRange(bal.rollAngleVar, rng))
        mod:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, npc, mod:RandomInt(100,120,rng) * 0.01, 0.5)
        if data.RollBounceHeight >= 0 then
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 2, npc.Position, Vector.Zero, npc)
            effect.Color = mod.Colors.SpeedBall
            effect:Update()
        end
    end
end

function mod:PinkyAI(npc, sprite, data)
    local targetpos = mod:GetPlayerTargetPos(npc)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()

    if not data.Init then
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc.SplatColor = mod.Colors.MortisBlood
        npc.StateFrame = mod:RandomInt(bal.idleTime, rng)
        data.State = "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        npc.Velocity = Vector.Zero
        mod:SpritePlay(sprite, "Idle")

        if ShouldDie(npc) then
            sprite.PlaybackSpeed = 1
            npc:Kill()
        else
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 or data.Adrenalized or ShouldBuff(npc) or forceAttack then
                SelectAttack(npc)
                data.State = "Inject"
            end
        end

    elseif data.State == "Inject" then
        if not sprite:WasEventTriggered("Coll") then
            npc.Velocity = Vector.Zero
        end

        if sprite:IsFinished(data.CurrentAttack.."Transform") then
            if data.CurrentAttack == "Adrenaline" then
                sprite:GetLayer("Body"):SetCropOffset(Vector(0,112))
                data.State = "Idle"
            elseif data.CurrentAttack == "Growth" then    
                data.State = "GrowthLand"
                if data.Adrenalized then
                    sprite:GetLayer("Body"):SetCropOffset(Vector(0,176))
                end
                npc.I1 = bal.numHops
                npc.Velocity = Vector.Zero
            elseif ShouldDie(npc) then
                data.State = "Revert"
            elseif data.CurrentAttack == "Roid" then
                data.State = "RoidJump"
                npc.I1 = bal.numRoidJumps
            elseif data.CurrentAttack == "Speed" then
                data.State = "RollStart"
            elseif data.CurrentAttack == "Exp" then
                data.State = "ExpAttack"
            elseif data.CurrentAttack == "Red" then
                data.State = "Puking"
            elseif data.CurrentAttack == "Synth" then
                data.State = "SpinStart"
                npc.I1 = bal.numSpins
            else
                data.State = "Revert" --Fallback
            end
        elseif sprite:IsEventTriggered("ItemGet") then
            mod:PlaySound(SoundEffect.SOUND_POWERUP1, npc)
        elseif sprite:IsEventTriggered("Inject") then
            mod:PlaySound(SoundEffect.SOUND_GOOATTACH0, npc)
            mod:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, npc)
            if data.CurrentAttack == "Adrenaline" then
                sprite.PlaybackSpeed = bal.adrenalineSpeedup
                data.Adrenalized = true
            end
        elseif sprite:IsEventTriggered("Break") then
            mod:PlaySound(SoundEffect.SOUND_GLASS_BREAK, npc)
        elseif sprite:IsEventTriggered("Sound") then
            if data.CurrentAttack == "Synth" then
                mod:PlaySound(mod.Sounds.MuscleGrow, npc, 1, 1.5)
                mod:PlaySound(SoundEffect.SOUND_INFLATE, npc, 1.5, 0.35)
            elseif data.CurrentAttack == "Growth" then
                mod:PlaySound(SoundEffect.SOUND_FAT_GRUNT, npc)
            end
        elseif sprite:IsEventTriggered("Coll") then
            npc.Velocity = (room:GetCenterPos() - npc.Position)/(data.Adrenalized and 12 or 15)
            ToggleCollision(npc)
            mod:PlaySound(SoundEffect.SOUND_FAT_WIGGLE, npc)
        else
            mod:SpritePlay(sprite, data.CurrentAttack.."Transform")
        end

    elseif data.State == "Revert" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished(data.CurrentAttack.."Revert") then
            npc.StateFrame = mod:RandomInt(bal.idleTime, rng)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_GASCAN_POUR, npc, 2, 0.3)
            mod:PlaySound(SoundEffect.SOUND_DEATH_REVERSE, npc, 1, 0.5)
        elseif sprite:IsEventTriggered("Sound2") then
            mod:PlaySound(mod.Sounds.MuscleDeflate, npc, 1.5)
        else
            mod:SpritePlay(sprite, data.CurrentAttack.."Revert")
        end

    --Roid Rage
    elseif data.State == "RoidJump" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("RoidJump") then
            npc.TargetPosition = targetpos
            npc.V1 = (npc.TargetPosition - npc.Position)/bal.roidAirTime
            npc.StateFrame = bal.roidAirTime
            data.State = "RoidInAir"
        elseif sprite:IsEventTriggered("Coll") then
            ToggleCollision(npc)
            mod:PlaySound(SoundEffect.SOUND_FAT_WIGGLE, npc)
        else
            mod:SpritePlay(sprite, "RoidJump")
        end

    elseif data.State == "RoidInAir" then
        npc.Velocity = npc.V1
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.State = "RoidLand"
        end

    elseif data.State == "RoidLand" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("RoidLand") then
            if npc.I1 <= 0 or ShouldDie(npc) then
                data.State = "Revert"
            else
                data.State = "RoidJump"
            end
        elseif sprite:IsEventTriggered("Coll") then
            ToggleCollision(npc)
            mod:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, npc)
            game:ShakeScreen(15)
            game:MakeShockwave(npc.Position, 0.05, 0.025, 10)
            DestroyInRadius(npc, 65)
            local shockwave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, npc.Position, Vector.Zero, npc):ToEffect()
            shockwave.Parent = npc
            shockwave.MaxRadius = bal.roidShockwaveRadius
            for i = 1, 2 do
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, i, npc.Position, Vector.Zero, npc)
                effect.Color = mod.Colors.RoidRage
                effect:Update()
            end
            for i = 1, room:GetGridSize() - 1 do
                local grid = room:GetGridEntity(i)
                if grid and grid:GetType() == GridEntityType.GRID_WALL then
                    local pos = room:GetGridPosition(i) + (RandomVector() * mod:RandomInt(0,25,rng))
                    local vec = (room:GetCenterPos() - room:GetGridPosition(i)):Resized(mod:RandomInt(bal.roidProjSpeed)):Rotated(mod:RandomInRange(15,rng))
                    local delay = mod:RandomInt(10,15,rng)
                    mod:ScheduleForUpdate(function()
                        roidParams.Scale = mod:RandomInt(5,15,rng) * 0.1
                        roidParams.FallingSpeedModifier = mod:RandomInt(-7,-3,rng)
                        local proj = npc:FireProjectilesEx(pos, vec, 0, roidParams)[1]
                        mod:FadeIn(proj, 4)
                        proj:Update()
                    end, delay)
                    for i = 1, 3 do
                        mod:ScheduleForUpdate(function()
                            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 1, pos + RandomVector():Resized(mod:RandomInt(0,10,rng)) - vec:Resized(10), vec:Resized(mod:RandomInt(2,5)):Rotated(mod:RandomInRange(22,rng)), npc)
                            poof.Color = mod.Colors.RoidRageProj
                            poof:Update()
                        end, (delay/3 * i) + mod:RandomInt(-2,2,rng))
                    end
                end
            end
            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_GREEN, 0, npc.Position, Vector.Zero, npc):ToEffect()
            creep:SetTimeout(210)
            creep.SpriteScale = Vector(3,3)
            creep:Update()
            npc.I1 = npc.I1 - 1
        else
            mod:SpritePlay(sprite, "RoidLand")
        end

    --Speed Ball
    elseif data.State == "RollStart" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("RollStart") then
            mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc, 0.8, 1.3)
            npc.Velocity = mod:SnapVecToDiagonal(npc.Position - targetpos):Resized(data.Adrenalized and bal.rollSpeedAdrenaline or bal.rollSpeed)
            npc.StateFrame = bal.rollDuration
            data.RollBounceHeight = 0
            data.State = "RollLoop"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_BROWNIE_LAUGH, npc, 0.8)
        else
            mod:SpritePlay(sprite, "RollStart")
        end

    elseif data.State == "RollLoop" then
        RollAround(npc)
        mod:SpritePlay(sprite, "RollLoop")

        npc.StateFrame = npc.StateFrame - 1
        if (npc.StateFrame <= 0 or ShouldDie(npc)) and not data.RollBounceSpeed then
            data.State = "RollStop"
        end

    elseif data.State == "RollStop" then
        npc.Velocity = npc.Velocity * 0.8
        
        if sprite:IsFinished("RollEnd") then
            data.State = "Revert"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_BLOBBY_WIGGLE, npc)
        else
            mod:SpritePlay(sprite, "RollEnd")
        end

    --Experimental Treatment
    elseif data.State == "ExpAttack" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("ExpAttack") then
            data.State = "Revert"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_FAT_GRUNT, npc)
        elseif sprite:IsEventTriggered("Shoot") then
            local fart = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FART, 0, npc.Position, Vector.Zero, npc)
            fart.SpriteScale = Vector(1.3,1.3)
            fart.Color = mod:CloneColor(mod.Colors.OrganYellow, 0.5)
            fart.DepthOffset = -20
            fart:Update()
            game:ButterBeanFart(npc.Position, 200, npc, false, true)
            mod:PlaySound(SoundEffect.SOUND_HEARTOUT, npc)
            
            local fastPattern = mod:RandomInt(1,3,rng)
            local slowPattern = mod:RandomInt(1,3,rng)

            expParams.CircleAngle = mod:RandomAngle(rng)
            expParams.Color = mod.Colors.ExperimentalTreatment
            expParams.FallingAccelModifier = -0.09
            expParams.BulletFlags = 0
            expParams.Scale = 1

            if fastPattern == 1 then
                npc:FireProjectilesEx(npc.Position, Vector(11,10), ProjectileMode.CIRCLE_CUSTOM, expParams)
                expParams.CircleAngle = expParams.CircleAngle + (360/20)
                npc:FireProjectilesEx(npc.Position, Vector(8,10), ProjectileMode.CIRCLE_CUSTOM, expParams)
            elseif fastPattern == 2 then
                for i = 5, 11, 3 do
                    expParams.Scale = expParams.Scale + 0.25
                    npc:FireProjectilesEx(npc.Position, Vector(i,0), ProjectileMode.CIRCLE_EIGHT, expParams)
                end
            elseif fastPattern == 3 then
                local step = 360/bal.randomRingNum
                for i = step, 360, step do
                    expParams.Scale = mod:RandomInt(5,15,rng) * 0.1
                    npc:FireProjectiles(npc.Position, Vector(mod:RandomInt(bal.randomRingSpeed,rng),0):Rotated(i + expParams.CircleAngle), 0, expParams)
                end
            end

            expParams.CircleAngle = mod:RandomAngle(rng)
            expParams.Color = mod.Colors.OrganYellow
            expParams.Scale = 1.5

            if slowPattern == 1 then
                expParams.FallingAccelModifier = -0.2
                expParams.BulletFlags = ProjectileFlags.SINE_VELOCITY
                local step = 360/bal.staggerRingNum
                for i = step, 360, step do
                    mod:ScheduleForUpdate(function()
                        npc:FireProjectiles(npc.Position, Vector(bal.staggerRingSpeed,0):Rotated(i + expParams.CircleAngle), 0, expParams)
                    end, i % (step * 2) == 0 and bal.staggerRingDelay or 0)
                end
            elseif slowPattern == 2 then
                expParams.CurvingStrength = 0.005
                expParams.BulletFlags = ProjectileFlags.ORBIT_CW
                for _, proj in pairs (npc:FireProjectilesEx(npc.Position, Vector(bal.orbitRingSpeed,bal.orbitRingNum), ProjectileMode.CIRCLE_CUSTOM, expParams)) do
                    proj.TargetPosition = npc.Position
                end
                expParams.BulletFlags = ProjectileFlags.ORBIT_CCW
                for _, proj in pairs (npc:FireProjectilesEx(npc.Position, Vector(bal.orbitRingSpeed,bal.orbitRingNum), ProjectileMode.CIRCLE_CUSTOM, expParams)) do
                    proj.TargetPosition = npc.Position
                end
            elseif slowPattern == 3 then
                expParams.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE | ProjectileFlags.SAWTOOTH_WIGGLE
                npc:FireProjectilesEx(npc.Position, Vector(bal.sawRingSpeed,bal.sawRingNum), ProjectileMode.CIRCLE_CUSTOM, expParams)
            end
        else
            mod:SpritePlay(sprite, "ExpAttack")
        end

    --The Virus
    elseif data.State == "Puking" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("Puking") then
            data.State = "Revert"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_MOUTH_FULL, npc, 1, 0.65)
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_MEGA_PUKE, npc)
        else
            mod:SpritePlay(sprite, "Puking")
        end

        if (sprite:WasEventTriggered("Shoot") and not sprite:WasEventTriggered("Stop")) then
            vomitParams.Scale = mod:RandomInt(5,15,rng) * 0.1
            local aimPos = targetpos + rng:RandomVector():Resized(mod:RandomInt(0,60,rng))
            local proj = npc:FireProjectilesEx(npc.Position, (aimPos - npc.Position)/45, 0, vomitParams)[1]
            if npc.FrameCount % 3 == 0 then
                proj.Scale = proj.Scale * 1.5
                proj:AddProjectileFlags(ProjectileFlags.EXPLODE)
                proj:GetData().projType = "PinkyVomit"
                proj.Parent = npc
                proj:Update()
            end
        end

    --Synthoil
    elseif data.State == "SpinStart" then
        if not sprite:WasEventTriggered("Shoot") then
            npc.Velocity = Vector.Zero
        end
     
        if sprite:IsFinished("SpinStart") then
            npc.StateFrame = bal.spinDuration
            data.State = "Spinning"
        elseif sprite:IsEventTriggered("Target") then
            npc.TargetPosition = targetpos
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_SWORD_SPIN, npc, 0.8, 1)
            mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc, 0.8, 1.3)
            npc.Velocity = (npc.TargetPosition - npc.Position):Resized(bal.spinSpeed)
            data.IsSpinning = true
        else
            mod:SpritePlay(sprite, "SpinStart")
        end

    elseif data.State == "Spinning" then
        mod:SpritePlay(sprite, "Spin")

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 or ShouldDie(npc) then
            npc.I1 = npc.I1 - 1
            if npc.I1 <= 0 or ShouldDie(npc) then
                data.State = "SpinStop"
            else
                data.State = "SpinContinue"
            end
        end

    elseif data.State == "SpinContinue" then
        if not sprite:WasEventTriggered("Shoot") then
            npc.Velocity = npc.Velocity * 0.9
        end

        if sprite:IsFinished("SpinContinue") then
            npc.StateFrame = bal.spinDuration
            data.State = "Spinning"
        elseif sprite:IsEventTriggered("Stop") then
            data.IsSpinning = false
        elseif sprite:IsEventTriggered("Target") then
            npc.TargetPosition = targetpos
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(SoundEffect.SOUND_SWORD_SPIN, npc, 0.8, 1)
            mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc, 0.8, 1.3)
            npc.Velocity = (npc.TargetPosition - npc.Position):Resized(bal.spinSpeed)
            data.IsSpinning = true
        else
            mod:SpritePlay(sprite, "SpinContinue")
        end

    elseif data.State == "SpinStop" then
        npc.Velocity = npc.Velocity * 0.8

        if sprite:IsFinished("SpinEnd") then
            data.State = "Revert"
        elseif sprite:IsEventTriggered("Stop") then
            data.IsSpinning = false
        else
            mod:SpritePlay(sprite, "SpinEnd")
        end

    --Growth Hormones
    elseif data.State == "GrowthLand" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("GrowthLand") then
            data.State = "GrowthHop"
        elseif sprite:IsEventTriggered("Coll") then
            ToggleCollision(npc)
            mod:PlaySound(SoundEffect.SOUND_MOTHER_LAND_SMASH, npc)
            game:ShakeScreen(30)
            game:MakeShockwave(npc.Position, 0.075, 0.03, 20)
            for _, player in pairs(mod:GetAllPlayers()) do
                player:TryThrow(EntityRef(npc), Vector.Zero, 13)
            end
            mod:DestroyGridsInRadius(npc.Position, 400)
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, npc.Position, Vector.Zero, npc)
            effect.SpriteScale = Vector(2,2)
            effect.Color = mod.Colors.GrowthHormones
            effect:Update()
            npc.SizeMulti = bal.growthSizeMult
            data.Engrowthed = true
        else
            mod:SpritePlay(sprite, "GrowthLand")
        end

    elseif data.State == "GrowthHop" then
        if not (sprite:WasEventTriggered("Shoot") and not sprite:WasEventTriggered("Stop")) then
            npc.Velocity = Vector.Zero
        end

        if sprite:IsFinished("GrowthHop") then
            npc.I1 = npc.I1 - 1
            if npc.I1 <= 0 or ShouldDie(npc) then
                data.State = "GrowthJump"
            else
                sprite:Play("GrowthHop", true)
            end
        elseif sprite:IsEventTriggered("Shoot") then
            npc.Velocity = (targetpos - npc.Position):Resized(data.Adrenalized and bal.hopSpeedAdrenaline or bal.hopSpeed)
        elseif sprite:IsEventTriggered("Stop") then
            npc.Velocity = Vector.Zero
            mod:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, npc, 0.8)
            mod:PlaySound(SoundEffect.SOUND_MOTHER_LAND_SMASH, npc, 1, 0.3)
            game:ShakeScreen(15)
            for _, player in pairs(mod:GetAllPlayers()) do
                player:TryThrow(EntityRef(npc), Vector.Zero, 7)
            end
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, npc.Position, Vector.Zero, npc)
            effect.SpriteScale = Vector(1.5,1.5)
            effect.Color = mod.Colors.GrowthHormones
            effect:Update()
            for i = 1, bal.numRainProjs do
                mod:ScheduleForUpdate(function() 
                    rainParams.Scale = mod:RandomInt(10,15,rng) * 0.1
                    local pos = Isaac.GetRandomPosition() + rng:RandomVector():Resized(mod:RandomInt(0,30,rng))
                    npc:FireProjectiles(pos, rng:RandomVector(), 0, rainParams)
                end, i)
            end
        else
            mod:SpritePlay(sprite, "GrowthHop")
        end

    elseif data.State == "GrowthJump" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("GrowthJump") then
            if data.Adrenalized then
                sprite:GetLayer("Body"):SetCropOffset(Vector(0,112))
            end
            data.State = "Land"
        elseif sprite:IsEventTriggered("Coll") then
            ToggleCollision(npc)
            mod:PlaySound(SoundEffect.SOUND_FAT_WIGGLE, npc, 0.5)
            npc.SizeMulti = Vector.One
            data.Engrowthed = false
        else
            mod:SpritePlay(sprite, "GrowthJump")
        end

    elseif data.State == "Land" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("Land") then
            npc.StateFrame = mod:RandomInt(bal.idleTime, rng)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Coll") then
            ToggleCollision(npc)
            mod:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, npc)
            game:ShakeScreen(15)
            game:MakeShockwave(npc.Position, 0.05, 0.025, 10)
            DestroyInRadius(npc, 65)
            for i = 1, 2 do
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, i, npc.Position, Vector.Zero, npc)
            end
        else
            mod:SpritePlay(sprite, "Land")
        end
    end

    if data.IsSpinning then
        if npc:CollidesWithGrid() then
            mod:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, npc, 1.2, 0.5)
            npc.Velocity = npc.Velocity * 1.25
        end

        for _, ent in pairs(Isaac.FindInRadius(npc.Position, bal.spinRadius, EntityPartition.PLAYER | EntityPartition.ENEMY)) do
            if ent:ToPlayer() then
                if ent:ToPlayer():GetDamageCooldown() <= 0 and not mod:isFriend(npc) then
                    ent:TakeDamage(2, 0, EntityRef(npc), 0)
                    ent.Velocity = (ent.Position - npc.Position):Resized(30)
                    mod:PlaySound(SoundEffect.SOUND_PUNCH, npc, 0.8, 0.75)
                end
            elseif ent:ToBomb() then
                ent.Velocity = (ent.Position - npc.Position):Resized(30)
            elseif ent:ToNPC() then
                if npc.FrameCount % 10 == 0 and not ((ent.Type == npc.Type and ent.Variant == npc.Variant) or (mod:isFriend(npc) and mod:isFriend(ent))) then
                    ent:TakeDamage(40, 0, EntityRef(npc), 0)
                    ent.Velocity = (ent.Position - npc.Position):Resized(30)
                end
            end
        end
        mod:DestroyGridsInRadius(npc.Position, 80)
    end

    --Adrenaline
    if data.Adrenalized then
        if npc.FrameCount % 3 == 0 and npc.EntityCollisionClass >= EntityCollisionClass.ENTCOLL_ALL then
            local smoke = Isaac.Spawn(1000, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, npc.Position, (npc.Velocity * 0.5) + Vector(0,mod:RandomInt(-10,-5,rng)):Rotated(mod:RandomInRange(15,rng)), npc)
            smoke.Color = Color(1,1,1,0.8,0.8,0.6,0.8)
            smoke.DepthOffset = -80
            smoke.PositionOffset = npc.PositionOffset + npc:GetNullOffset("SmokePos")
            smoke:Update()
        end
    end
end

function mod:PinkyRender(npc, sprite, data)
    if mod:IsNormalRender() then
        if data.RollBounceSpeed then
            data.RollBounceHeight = data.RollBounceHeight + data.RollBounceSpeed
            data.RollBounceSpeed = data.RollBounceSpeed + 1
            if data.RollBounceHeight >= 0 then
                data.RollBounceHeight = 0
                npc:FireProjectiles(npc.Position, Vector(bal.rollProjSpeed, 0), ProjectileMode.CIRCLE_EIGHT, rollParams)
                mod:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, npc, mod:RandomInt(100,120,rng) * 0.01, 0.75)
                game:ShakeScreen(5)
                npc.PositionOffset = Vector.Zero
                data.RollBounceSpeed = nil
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, npc.Position, Vector.Zero, npc)
                effect.Color = mod.Colors.SpeedBall
                effect:Update()
            else
                npc.PositionOffset = Vector(0, data.RollBounceHeight)
            end
        end

        --Euthanasia
        if sprite:IsPlaying("Death") then
            if sprite:IsEventTriggered("ItemGet") then
                mod:PlaySound(SoundEffect.SOUND_POWERUP1, npc)
            elseif sprite:IsEventTriggered("Inject") then
                mod:PlaySound(SoundEffect.SOUND_GOOATTACH0, npc)
                mod:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, npc)
                npc.SplatColor = mod.Colors.Euthanasia
            elseif sprite:IsEventTriggered("Break") then
                mod:PlaySound(SoundEffect.SOUND_GLASS_BREAK, npc)
                mod:PlaySound(SoundEffect.SOUND_GASCAN_POUR, npc)
                mod:PlaySound(SoundEffect.SOUND_FAT_GRUNT, npc, 0.75)
            elseif sprite:IsEventTriggered("Explosion") and not data.DidDeathRing then
                deathParams.CircleAngle = mod:RandomAngle(npc:GetDropRNG())
                npc:FireProjectiles(npc.Position, Vector(bal.deathProjSpeed, bal.deathProjNum), ProjectileMode.CIRCLE_CUSTOM, deathParams)
                data.DidDeathRing = true
            end
        end
    end
end

function mod:PinkyHurt(npc, sprite, data, amount, damageFlags, source)
    return {DamageFlags = DamageFlag.DAMAGE_NOKILL}
end

function mod:PinkyColl(npc, sprite, data, collider)
    if data.Engrowthed and collider:ToNPC() then
        if (sprite:IsEventTriggered("Coll") or npc.Velocity:Length() >= 0.1) 
        and not ((collider.Type == npc.Type and collider.Variant == npc.Variant) or (mod:isFriend(npc) and mod:isFriend(collider))) then
            collider:TakeDamage(40, 0, EntityRef(npc), 0)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, proj)
    if proj:GetData().projType == "PinkyVomit" then
        local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, proj.Position, Vector.Zero, proj.SpawnerEntity):ToEffect()
        cloud:SetTimeout(bal.cloudDuration)
        cloud:Update()
    end
end, EntityType.ENTITY_PROJECTILE)