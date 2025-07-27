local mod = FiendFolio
local game = Game()
local rng = RNG()
local sfx = SFXManager()

local function HasPathToPos(npc, pos)
    local room = game:GetRoom()
    local grid = room:GetGridEntity(room:GetGridIndex(npc.Position))
    if grid and grid:GetType() == GridEntityType.GRID_TELEPORTER and room:CheckLine(npc.Position, pos, 0, 999, false, false) then
        return true --Ugh
    else
        return npc.Pathfinder:HasPathToPos(pos, false)
    end
end

local function AnimateTemptress(npc, sprite, data)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)

    if HasPathToPos(npc, targetpos) then
        local anim = "Walk"

        if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
            data.Suffix = "Hori"
            mod:FlipSprite(sprite, npc.Position + npc.Velocity, npc.Position)
        else
            sprite.FlipX = false
            if npc.Velocity.Y < 0 then
                data.Suffix = "Up"
            else
                data.Suffix = "Down"
            end
        end

        anim = anim..data.Suffix
        if npc.StateFrame <= 0 then
            anim = anim.."Pissed"
        end

        if not sprite:IsPlaying() then
            sprite:Play(anim, true)
        else
            sprite:SetAnimation(anim, false)
        end
    else
        mod:spritePlay(sprite, "Idle"..data.Suffix)
    end
end

local function TemptressPathfind(npc, data, speed)
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)

    if HasPathToPos(npc, targetpos) then
        mod.XalumGridPathfind(npc, targetpos, speed, 0.8)
    else
        npc.Velocity = npc.Velocity * 0.75
    end
end

local function MakeDebris(npc, vec, amount)
    local rng = npc:GetDropRNG()

    for i = 1, amount do
        local rock = Isaac.Spawn(1000,4,0,npc.Position-vec:Resized(20),vec:Resized(mod:RandomInt(4,amount,rng)):Rotated(mod:RandomInt(-75,75,rng)),npc)
        rock:Update()
        local dust = Isaac.Spawn(1000,mod.FF.FFWhiteSmoke.Var,mod.FF.FFWhiteSmoke.Sub,npc.Position-vec:Resized(20),vec:Resized(mod:RandomInt(4,amount/2,rng)):Rotated(mod:RandomInt(-75,75,rng)),npc)
        dust.Color = Color(0.4,0.4,0.4,1)
        dust:GetData().longonly = true
    end
end

function mod:GetClosestWallPos(pos)
    local returnpos = pos
    local dist = 99999
    for i = 90, 360, 90 do
        local wallpos = mod.XalumFindWall(pos, Vector(20,0):Rotated(i)).Position
        if wallpos:Distance(pos) < dist then
            dist = wallpos:Distance(pos)
            returnpos = wallpos
        end
    end
    return returnpos
end

function mod:TemptressAI(npc, sprite, data)
    local room = game:GetRoom()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)
    local rng = npc:GetDropRNG()

    if not data.Init then
        npc.Visible = false
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

        local wallpos = mod:GetClosestWallPos(npc.Position)
        local suffix, flipX = mod:GetMoveString(npc.Position - wallpos, true)
        data.Suffix, sprite.FlipX = suffix, not flipX

        npc.StateFrame = mod:RandomInt(200,250,rng)
        data.DebrisVec = mod:SuffixToVec(data.Suffix, not sprite.FlipX)
        data.State = "Hiding"
        data.Init = true
    end

    mod.QuickSetEntityGridPath(npc)
    mod.NegateKnockoutDrops(npc)

    if data.State == "Hiding" then
        npc.Velocity = Vector.Zero
        npc.StateFrame = npc.StateFrame - 1
        if (npc.SubType == 0 and npc.StateFrame <= 0) or mod.CanIComeOutYet() then
            npc.StateFrame = mod:RandomInt(10,20,rng)
            data.State = "Greet"
            mod:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND,npc,1.2,0.5)
            game:ShakeScreen(10)
            MakeDebris(npc, data.DebrisVec, 8)

            for i = 1, 2 do
                local wall = Isaac.Spawn(mod.FF.TemptressHole.ID, mod.FF.TemptressHole.Var, mod.FF.TemptressHole.Sub, npc.Position, Vector.Zero, npc):ToEffect()
                local wsprite = wall:GetSprite()
                wsprite.FlipX = sprite.FlipX
                wsprite:SetFrame("Hole"..data.Suffix, 0)
                if i == 1 then
                    wall:AddEntityFlags(EntityFlag.FLAG_RENDER_WALL)
                else
                    wall:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
                end
            end
        end
    elseif data.State == "Greet" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("Peek"..data.Suffix) then
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                data.State = "Emerge"
                mod:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND,npc)
                game:ShakeScreen(20)
                MakeDebris(npc, data.DebrisVec, 8)
            end
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(mod.Sounds.TemptressAttack, npc, 1, 0.5)
        else
            mod:spritePlay(sprite, "Peek"..data.Suffix)
            npc.Visible = true
        end
    
    elseif data.State == "Emerge" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("Appear"..data.Suffix) then
            npc.StateFrame = 90
            data.Speed = 3
            data.TargetSpeed = 3
            data.State = "Chase"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(mod.Sounds.TemptressEmerge, npc, 1, 1)
        elseif sprite:IsEventTriggered("Collision") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)

            local hitbox = Isaac.Spawn(mod.FF.Hitbox.ID, mod.FF.Hitbox.Var, 0, npc.Position, Vector.Zero, npc)
            local hdata = hitbox:GetData()
            hdata.Width = 30
            hdata.Height = 30
            hdata.FixToSpawner = true
            hdata.Relay = true
            hitbox.CollisionDamage = npc.CollisionDamage
            hitbox.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            hitbox.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        else
            mod:spritePlay(sprite, "Appear"..data.Suffix)
        end
    
    elseif data.State == "Chase" then
        if sprite:IsEventTriggered("Move") then
            data.Speed = data.TargetSpeed * 2.75
            mod:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, npc, mod:RandomInt(130,150,rng)/100, 0.25)
        end
        TemptressPathfind(npc, data, data.Speed)
        AnimateTemptress(npc, sprite, data)

        data.Speed = mod:Lerp(data.Speed, data.TargetSpeed, 0.25)
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if not data.AngerSounded then
                mod:PlaySound(mod.Sounds.TemptressChase, npc)
                data.AngerSounded = true
            end

            if data.TargetSpeed < 4.9 then
                data.TargetSpeed = data.TargetSpeed + 0.02
            end

            breakRocks = false
            distcheck = -npc.StateFrame
            if not HasPathToPos(npc, targetpos) then
                breakRocks = true
                distcheck = distcheck * 2
            end
            if npc.Position:Distance(targetpos) <= distcheck then
                data.State = "Attack"
                data.BreakRocks = breakRocks
            end
        end
    elseif data.State == "Attack" then
        npc.Velocity = npc.Velocity * 0.75
    
        if sprite:IsFinished("Attack"..data.Suffix) then
            npc.StateFrame = 90
            data.Speed = 3
            data.TargetSpeed = 3
            data.AngerSounded = false
            data.State = "Chase"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(mod.Sounds.TemptressAttack, npc, 1, 1)
        elseif sprite:IsEventTriggered("Shoot") then
            local params = ProjectileParams()
            params.Scale = 1.75
            params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE

            mod:SetGatheredProjectiles()
            npc:FireProjectiles(npc.Position, Vector(6,0), 6, params)
            for _, projectile in pairs(mod:GetGatheredProjectiles()) do
                local pdata = projectile:GetData()
                pdata.projType = "Temptress"
                pdata.TemptSpeed = 6
                pdata.OriginPos = npc.Position
                pdata.TemptAngleShift = 3
            end

            mod:SetGatheredProjectiles()
            npc:FireProjectiles(npc.Position, Vector(6,0), 6, params)
            for _, projectile in pairs(mod:GetGatheredProjectiles()) do
                local pdata = projectile:GetData()
                pdata.projType = "Temptress"
                pdata.OriginPos = npc.Position
                pdata.TemptSpeed = 6
                pdata.TemptDistance = 20
                pdata.TemptAngleShift = -3
            end

            if data.BreakRocks then
                mod:DestroyNearbyGrid(npc, 120)
                data.BreakRocks = false
            end

            mod:PlaySound(SoundEffect.SOUND_HELLBOSS_GROUNDPOUND, npc)
            mod:PlaySound(SoundEffect.SOUND_MOTHER_LAND_SMASH, npc)
            game:ShakeScreen(10)

            Isaac.Spawn(1000,16,3,npc.Position,Vector.Zero,npc)
        else
            mod:spritePlay(sprite, "Attack"..data.Suffix)
        end
    end
end

function mod:TemptressRender(npc, sprite, data, isPaused, isReflected)
    if not (isPaused or isReflected) then
        if data.State == "Death" then
            if sprite:IsFinished("Death"..data.Suffix) then
                npc:Kill()
            elseif sprite:IsEventTriggered("Shoot") and not data.DidDeathEffect then
                npc:BloodExplode()
                mod.TemptressDeathEffect(npc)
                data.DidDeathEffect = true
            else
                mod:spritePlay(sprite, "Death"..data.Suffix)
            end
        end
    end
end

function mod:TemptressProjectile(projectile, data)
    data.TemptAngle = data.TemptAngle or (data.OriginPos - projectile.Position):GetAngleDegrees()
    data.TemptDistance = data.TemptDistance or data.OriginPos:Distance(projectile.Position)

    data.TemptDistance = data.TemptDistance + data.TemptSpeed
    data.TemptAngle = data.TemptAngle + data.TemptAngleShift
    if data.TemptSpeed > 2 then
        data.TemptSpeed = data.TemptSpeed - 0.05
    end


    projectile.TargetPosition = data.OriginPos + Vector(data.TemptDistance,0):Rotated(data.TemptAngle)

    if projectile.TargetPosition:Distance(data.OriginPos) > 400 then
        data.projType = nil
        projectile.FallingAccel = 1
    else
        projectile.FallingAccel = -0.1
        projectile.Velocity = projectile.TargetPosition - projectile.Position
    end
end

function FiendFolio.TemptressDeathAnim(npc)
    local onCustomDeath = function(npc, deathAnim)
        mod:PlaySound(mod.Sounds.TemptressDeath, npc)
        deathAnim:GetData().Suffix = npc:GetData().Suffix
        deathAnim:GetData().State = "Death"
        deathAnim:GetData().Init = true
        deathAnim.State = 17
    end

    mod:PlaySound(mod.Sounds.TemptressDeath, npc)
    FiendFolio.genericCustomDeathAnim(npc, "Death"..npc:GetData().Suffix, true, onCustomDeath, true)
end

function FiendFolio.TemptressDeathEffect(npc)
    local rng = npc:GetDropRNG()
    local params = ProjectileParams()
    params.FallingAccelModifier = 0.6

    local vec = mod:SuffixToVec(npc:GetData().Suffix, not npc:GetSprite().FlipX)

    for i = 1, mod:RandomInt(16,24,rng) do
        local makeTooth = false
        local var = mod:RandomInt(1,3,rng)
        params.FallingSpeedModifier = mod:RandomInt(-8,-2,rng)

        if var == 1 then
            params.Variant = 0
            params.Scale = mod:RandomInt(16,30,rng) * 0.05
        elseif var == 2 then
            params.Variant = 1
        elseif var == 3 then
            params.Variant = 1
            makeTooth = true
        end

        mod:SetGatheredProjectiles()
        npc:FireProjectiles(npc.Position + vec:Resized(40), vec:Resized(mod:RandomInt(10,14,rng)):Rotated(mod:RandomInt(-30,30,rng)), 0, params)
        for _, projectile in pairs(mod:GetGatheredProjectiles()) do
            if makeTooth then
                local sprite = projectile:GetSprite()
                sprite:Load("gfx/002.030_black tooth tear.anm2", true)
                sprite:ReplaceSpritesheet(0, "gfx/projectiles/temptress_tooth.png")
                sprite:LoadGraphics()
                sprite:Play("Tooth2Move", false)
                projectile:GetData().tooth = true
            end
        end
    end

    mod:PlaySound(mod.Sounds.MeatyBurst, npc, 1, 0.6)
end