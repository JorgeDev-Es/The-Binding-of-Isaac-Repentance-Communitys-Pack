local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
    idleTime = {15,30},
    hiddenTime = {25,30},
    projSpeed = {4,11},
    projAngleVar = 40,
    chargeSpeed = 20,
    chargeDrift = 4,
    projSpeed2 = 14,
    projRate = 4,
}

local directions = {"Right", "DiagDownRight", "Down", "DiagDownLeft", "Left", "DiagUpLeft", "Up", "DiagUpRight"}

local params = ProjectileParams()
params.Color = mod.Colors.BrimstoneProj
params.Variant = ProjectileVariant.PROJECTILE_TEAR
params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
params.ChangeTimeout = 5
params.ChangeFlags = 0

local params2 = ProjectileParams()
params2.Color = mod.Colors.OrganBlue

function mod:SkinbursterAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()
    local targetpos = mod:GetPlayerTargetPos(npc)

    if not data.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        ToggleCollisionAndFlags(npc)
        npc.Visible = false
        mod:ScheduleForUpdate(function()
            npc.Visible = true
            npc:UpdateDirtColor(true)
        end, 1, nil, true)
        npc.SplatColor = mod.Colors.MortisBlood
        data.State = "Emerge"
        data.Init = true
    end

    if data.State ~= "WallEmerge" and data.State ~= "ChargeStart" then
        npc:UpdateDirtColor()
    end

    if data.State == "Emerge" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("Emerge") then
            npc.StateFrame = mod:RandomInt(bal.idleTime, rng)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_SKIN_PULL, npc)
            mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc, 1.2, 0.5)
            ToggleCollisionAndFlags(npc)
        elseif sprite:IsEventTriggered("Coll") then
            mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc)
            mod:PlaySound(SoundEffect.SOUND_MAGGOT_BURST_OUT, npc, 1.2)
            for i = 1, 3 do
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE, 0, npc.Position, RandomVector():Resized(mod:RandomInt(3,8)), npc):Update()
            end
        else
            mod:SpritePlay(sprite, "Emerge")
        end

    elseif data.State == "Idle" then
        npc.Velocity = Vector.Zero
        mod:SpritePlay(sprite, "Idle")

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            data.AnimSuffix = "Down"
            data.State = "Shoot"
        end

    elseif data.State == "Shoot" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("Shoot"..data.AnimSuffix) then
            data.State = "Submerge"
        elseif sprite:IsEventTriggered("Target") then
            npc.V1 = (targetpos - npc.Position):Normalized()
            local angle = math.floor(((mod:GetAngleDegreesButGood(npc.V1)+12.5)%360)/45) + 1
            data.ShootingUp = (angle > 5)
            data.AnimSuffix = directions[angle] or data.AnimSuffix
            sprite:SetAnimation("Shoot"..data.AnimSuffix, false)
            local tracer = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GENERIC_TRACER, 0, npc.Position + npc.V1:Resized(5), Vector(0.001,0), npc):ToEffect()
            tracer.Timeout = 10
            tracer.TargetPosition = npc.V1
            tracer.LifeSpan = 10
            tracer:FollowParent(npc)
            tracer.SpriteScale = Vector(2,2)
            tracer.Color = Color(1,0.2,0,0.3,0,0,0)
            tracer:Update()
        elseif sprite:IsEventTriggered("Shoot") then
            local laser = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.THICK_RED, 0, npc.Position, Vector.Zero, npc):ToLaser()
            laser.Parent = npc
            laser.Angle = npc.V1:GetAngleDegrees()
            laser.Timeout = 15
            laser.PositionOffset = npc:GetNullOffset("LaserPos")
            laser.DepthOffset = data.ShootingUp and -40 or 40
            laser.CollisionDamage = 0.5
            laser:GetData().SkinbursterLaser = true
            laser:Update()
        else
            mod:SpritePlay(sprite, "Shoot"..data.AnimSuffix)
        end

    elseif data.State == "Submerge" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("Submerge") then
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                npc.V1 = Vector(1,0):Rotated(90 * mod:RandomInt(0,3,rng)):Resized(bal.chargeSpeed)
                npc.Position = mod:GetWallInDirection(targetpos, -npc.V1)
                data.AnimSuffix = mod:GetMoveString(npc.V1)
                data.State = "WallEmerge"
                --sprite:GetLayer("dirt"):SetColor(mod.MortisDirtColor)
                sprite:Play("EmergeWall"..data.AnimSuffix)
                npc.Visible = true
            else
                npc.Visible = false
            end
        elseif sprite:IsEventTriggered("Coll") then
            npc.StateFrame = mod:RandomInt(bal.hiddenTime, rng)
            ToggleCollisionAndFlags(npc)
            mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc)
            mod:PlaySound(SoundEffect.SOUND_MAGGOT_ENTER_GROUND, npc, 1.2)
        else
            mod:SpritePlay(sprite, "Submerge")
        end

    elseif data.State == "WallEmerge" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("EmergeWall"..data.AnimSuffix) then
            data.State = "ChargeStart"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc, 1.2, 0.5)
            mod:PlaySound(SoundEffect.SOUND_SKIN_PULL, npc)
            ToggleCollisionAndFlags(npc)
        elseif sprite:IsEventTriggered("Coll") then
            mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc)
        else
            mod:SpritePlay(sprite, "EmergeWall"..data.AnimSuffix)
        end

    elseif data.State == "ChargeStart" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("Charge"..data.AnimSuffix.."Start") then
            npc.StateFrame = 10
            data.State = "Charging"
            mod:PlaySound(SoundEffect.SOUND_MAGGOT_BURST_OUT, npc, 1.2)
            mod:PlaySound(SoundEffect.SOUND_MONSTER_ROAR_0, npc)
            local dirt = Isaac.Spawn(mod.ENT.SkinbursterDirt.ID, mod.ENT.SkinbursterDirt.Var, 0, npc.Position, Vector.Zero, npc)
            dirt.SpriteRotation = npc.V1:GetAngleDegrees() + 90
            dirt.SpriteOffset = Vector(0,-10)
            dirt:Update()
            for i = 1, 3 do
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE, 0, npc.Position, npc.V1:Resized(mod:RandomInt(6,10)):Rotated(mod:RandomInRange(30)), npc):Update()
            end
        else
            mod:SpritePlay(sprite, "Charge"..data.AnimSuffix.."Start")
        end

    elseif data.State == "Charging" then
        mod:SpritePlay(sprite, "Charge"..data.AnimSuffix)

        if data.FadingOut then
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                npc.Position = mod:FindRandomTeleportPos(npc, 100, 400)
                data.FadingOut = false
                data.State = "Emerge"
                sprite:Play("Emerge", true)
                npc.Visible = true
                npc:UpdateDirtColor(true)
                npc.Color = mod:CloneColor(npc.Color,1)
            else
                npc.Visible = false
            end
            npc.Velocity = npc.Velocity * 0.9
        else
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 and not room:IsPositionInRoom(npc.Position, 0) then
                local dirt = Isaac.Spawn(mod.ENT.SkinbursterDirt.ID, mod.ENT.SkinbursterDirt.Var, 0, mod:GetWallInDirection(npc.Position, npc.V1) + npc.V1:Resized(10), Vector.Zero, npc)
                dirt.SpriteRotation = npc.V1:GetAngleDegrees() - 90
                dirt.SpriteOffset = Vector(0,-10)
                dirt:Update()
                for i = 1, 3 do
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE, 0, npc.Position, -npc.V1:Resized(mod:RandomInt(6,10)):Rotated(mod:RandomInRange(30)), npc):Update()
                end
                npc.StateFrame = mod:RandomInt(bal.hiddenTime, rng)
                ToggleCollisionAndFlags(npc)
                mod:PlaySound(SoundEffect.SOUND_MAGGOT_ENTER_GROUND, npc, 1.2)
                mod:FadeOut(npc, 3)
                data.FadingOut = true
            else      
                if npc.FrameCount % bal.projRate == 0 then
                    mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc)
                    for i = 90, 270, 180 do
                        local proj = npc:FireProjectilesEx(npc.Position, npc.V1:Rotated(i):Resized(bal.projSpeed2), 0, params2)[1]
                        proj:GetData().projType = "customProjectileBehavior"
                        proj:GetData().customProjectileBehaviorLJ = {customFunc = function(proj, tab) proj.Velocity = proj.Velocity * 0.9 end}
                    end
                end
            end
            local drift = Vector.Zero --npc.V1.Y == 0 and Vector(0, mod:BoundValue(targetpos.Y - npc.Position.Y, -bal.chargeDrift, bal.chargeDrift)) or Vector(mod:BoundValue(targetpos.X - npc.Position.X, -bal.chargeDrift, bal.chargeDrift), 0)
            npc.Velocity = npc.V1 + drift
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
    local sprite = effect:GetSprite()
    sprite:GetLayer("dirt"):SetColor(mod.MortisDirtColor)
    sprite:Play("Ground", true)
end, mod.ENT.SkinbursterDirt.Var)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local sprite = effect:GetSprite()
    if effect.FrameCount > 3 then
        mod:SpritePlay(sprite, "GroundClose")
        if sprite:IsFinished() then
            effect:Remove()
        end
    end
end, mod.ENT.SkinbursterDirt.Var)

mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_, laser)
    if laser:GetData().SkinbursterLaser and laser.Timeout > 0 then
        local parent = laser.Parent
        if laser.Parent and laser.Parent:Exists() then
            local room = game:GetRoom()
            local angle
            for i = 90, 360, 90 do
                if room:IsPositionInRoom(laser.EndPoint + Vector(40,0):Rotated(i), 0) then
                    angle = i
                    break
                end
            end
            params.Scale = mod:RandomInt(60,140) * 0.01
            laser.Parent:ToNPC():FireProjectiles(laser.EndPoint, Vector(mod:RandomInt(bal.projSpeed), 0):Rotated(angle or mod:RandomAngle()):Rotated(mod:RandomInRange(bal.projAngleVar)), 0, params)
            --[[local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, laser.EndPoint + (RandomVector() * mod:RandomInt(0,30)), RandomVector(), laser)
            splat.SpriteScale = splat.SpriteScale * mod:RandomInt(80,120) * 0.01
            splat:Update()]]
            sfx:Play(SoundEffect.SOUND_BLOODSHOOT)
        end
    end
end, LaserVariant.THICK_RED)