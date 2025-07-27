local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
    moveSpeed = 4,
    shootCooldown = {20,60},
    chargesBeforeShoot = 2,
    projSpeed = 9,
    projSpeed2 = 9.5,
    projSpeed3 = 15,
    chargeAngle = 20,
    chargeSpeed = 26,
    cutThresh = 0.66,
    emergeDelay = {15,25},
    cutInterval = 0,
    numCuts = 5,
}

local params = ProjectileParams()
params.Color = mod.Colors.MortisBloodProj
params.FallingAccelModifier = -0.09
params.Scale = 1.25

local paramsNeedle = ProjectileParams()
paramsNeedle.Variant = mod.ENT.SulfuricNeedle.Var

function mod:DocAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local room = game:GetRoom()
    local targetpos = mod:GetPlayerTargetPos(npc)

    if not data.Init then
        npc.SplatColor = mod.Colors.MortisBlood
        npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        npc.StateFrame = mod:RandomInt(bal.shootCooldown, rng)
        npc.I1 = bal.chargesBeforeShoot
        data.State = "Chase"
        data.Init = true

        mod:ScheduleForUpdate(function() 
			if mod.UsingMorgueisBackdrop then
				sprite:ReplaceSpritesheet(1, "gfx/enemies/d.o.c/scalpel_d.o.c_morgueis.png", true)
			elseif mod.UsingMoistisBackdrop then
				sprite:ReplaceSpritesheet(1, "gfx/enemies/d.o.c/scalpel_d.o.c_moistis.png", true)
			end
		end, 0)
    end

    if data.State == "Chase" then
        local tryToCut = false
        if npc.HitPoints <= npc.MaxHitPoints * bal.cutThresh and not data.MadeCuts then
            tryToCut = true
            targetpos = room:GetGridPosition(room:GetGridIndex(npc.Position))
        end
        if tryToCut and npc.Position:Distance(targetpos) <= 5 then
            npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
            npc.Position = targetpos
            npc.Velocity = Vector.Zero
            data.State = "Dig"
            data.MadeCuts = true
        else
            if npc.Pathfinder:HasPathToPos(targetpos) then
                local suffix = (npc.Velocity.X < 0 and "Left" or "Right")
                mod:SpriteSetAnimation(sprite, "Walk"..suffix)
                if sprite:IsEventTriggered("Move") then
                    data.Stepping = true
                elseif sprite:IsEventTriggered("Sound") then
                    mod:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, npc, 1.75, 0.2)
                    data.Stepping = false
                end
    
                if data.Stepping then
                    mod:ChasePosition(npc, targetpos, bal.moveSpeed)
                else
                    npc.Velocity = npc.Velocity * 0.75
                end
            else
                local suffix = (targetpos.X < npc.Position.X and "Left" or "Right")
                data.Stepping = false
                npc.Velocity = npc.Velocity * 0.75
                mod:SpriteSetAnimation(sprite, "Chase"..suffix)
            end
        end

        if not tryToCut then
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                data.State = "Shoot"
                data.Suffix = (targetpos.Y < npc.Position.Y and "Up" or "Down")
            elseif npc.StateFrame <= 30 then
                local targVec = (targetpos - npc.Position)
                for i = 0, 180, 180 do
                    local vec = Vector.FromAngle(i)
                    local angleDif = mod:GetAbsoluteAngleDifference(vec, targVec)
                    if angleDif <= bal.chargeAngle then
                        data.State = "Charge"
                        data.Suffix = (i == 0 and "Right" or "Left")
                        data.ChargeVec = vec
                        break
                    end
                end
            end
        end

    elseif data.State == "Shoot" then
        npc.Velocity = npc.Velocity * 0.75

        if sprite:IsFinished("Spit"..data.Suffix) then
            npc.StateFrame = mod:RandomInt(bal.shootCooldown, rng)
            npc.I1 = bal.chargesBeforeShoot
            data.State = "Chase"
        elseif sprite:IsEventTriggered("Shoot") then
            data.Suffix = (targetpos.Y < npc.Position.Y and "Up" or "Down")
            mod:SpriteSetAnimation(sprite, "Spit"..data.Suffix)
            params.Spread = 2
            npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(bal.projSpeed), ProjectileMode.SPREAD_TWO, params)
            params.Spread = 1
            npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(bal.projSpeed2), ProjectileMode.SPREAD_TWO, params)
            npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(bal.projSpeed3), ProjectileMode.SINGLE, paramsNeedle)
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 5, npc.Position, Vector.Zero, npc)
            effect.DepthOffset = (data.Suffix == "Up" and -40 or 40)
            effect.PositionOffset = npc:GetNullOffset("EffectPos")
            effect.Color = mod:CloneColor(mod.Colors.MortisBlood, 0.5)
            effect:Update()
            mod:PlaySound(SoundEffect.SOUND_GHOST_SHOOT, npc, 0.8)
            mod:PlaySound(SoundEffect.SOUND_SKIN_PULL, npc, 1, 0.75)
            mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc, 0.75)
        else
            mod:SpritePlay(sprite, "Spit"..data.Suffix)
        end

    elseif data.State == "Charge" then
        if sprite:WasEventTriggered("Shoot") and not sprite:WasEventTriggered("Land") then
            npc.Velocity = npc.Velocity * 0.95
            for i = -20, 20, 20 do
                local grid = room:GetGridEntityFromPos(npc.Position + data.ChargeVec:Resized(40):Rotated(i))
                if grid then
                    grid:Destroy()
                end
            end
        elseif sprite:WasEventTriggered("Land") then
            if room:GetGridCollisionAtPos(npc.Position) > GridCollisionClass.COLLISION_NONE then
                local snapPos = mod:GetNearestPosOfCollisionClassOrLess(npc.Position, GridCollisionClass.COLLISION_NONE)
                if snapPos then
                    npc.Velocity = (snapPos - npc.Position)/10
                else
                    npc.Velocity = npc.Velocity * 0.75
                end
            else
                npc.Velocity = npc.Velocity * 0.75
            end
        else
            npc.Velocity = npc.Velocity * 0.75
        end

        if sprite:IsFinished("Thrust"..data.Suffix) then
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            npc.I1 = npc.I1 - 1
            if npc.I1 <= 0 then
                data.State = "Shoot"
                data.Suffix = (targetpos.Y < npc.Position.Y and "Up" or "Down")
            else
                npc.StateFrame = mod:RandomInt(bal.shootCooldown, rng)
                data.State = "Chase"
            end
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_MONSTER_ROAR_3, npc, 1, 1.25)
        elseif sprite:IsEventTriggered("Shoot") then
            local targVec = (targetpos - npc.Position)
            local angleDiff = mod:GetAngleDifference(data.ChargeVec, targVec)
            if math.abs(angleDiff) > bal.chargeAngle then
                data.ChargeVec = data.ChargeVec:Rotated((math.abs(angleDiff)/angleDiff) * -bal.chargeAngle)
            else
                data.ChargeVec = targVec
            end
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            npc.Velocity = data.ChargeVec:Resized(bal.chargeSpeed)
            mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc, 0.8, 1.5)
            mod:PlaySound(SoundEffect.SOUND_KNIFE_PULL, npc, 1.25)
        elseif sprite:IsEventTriggered("Land") then
            mod:PlaySound(SoundEffect.SOUND_SCAMPER, npc)
        else
            mod:SpritePlay(sprite, "Thrust"..data.Suffix)
        end

    elseif data.State == "Dig" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("Dig") then
            npc.Visible = false
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                npc.I1 = bal.numCuts
                data.MoveDirection = Direction.NO_DIRECTION
                data.CutInterval = bal.cutInterval
                data.IsScalpel = true
                data.State = "Emerge"
                npc.CollisionDamage = 0
                npc.Position = mod:GetNearestObstacleSpawnPos(targetpos, npc.Position, true)
                mod:SpritePlay(sprite, "Emerge")
                npc.Visible = true
            end
        elseif sprite:IsEventTriggered("Shoot") then
            npc.StateFrame = mod:RandomInt(bal.emergeDelay, rng)
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            mod:MakeScalpelPit(npc, true)
            mod:PlaySound(SoundEffect.SOUND_KNIFE_PULL, npc)
            mod:PlaySound(SoundEffect.SOUND_MAGGOT_ENTER_GROUND, npc)
        elseif sprite:IsEventTriggered("Coll") then
            mod:ToggleCollision(npc)
            npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET)
        else
            mod:SpritePlay(sprite, "Dig")
        end

    elseif data.State == "Hidden" then
        npc.Velocity = Vector.Zero
        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            npc.Visible = true
            mod:SpritePlay(sprite, "Resurface")
            data.State = "Resurface"
            if mod:HasWaterPits() then 
                npc:SetColor(room:GetFXParams().WaterEffectColor, 15, 999, true, true)
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, npc.Position, Vector.Zero, npc)
                mod:PlaySound(SoundEffect.SOUND_BOSS2_DIVE, npc, 1.25, 0.75)
            end
        end

    elseif data.State == "Resurface" then
        if sprite:IsFinished("Resurface") then
            npc.StateFrame = mod:RandomInt(bal.shootCooldown, rng)
            data.State = "Chase"
        elseif sprite:IsEventTriggered("Move") then
            npc.TargetPosition = mod:FindSafeSpawnSpot(npc.Position, 60, 9999, true)
            mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc)
        elseif sprite:IsEventTriggered("Coll") then
            mod:ToggleCollision(npc)
            npc.CollisionDamage = 2
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
        elseif sprite:IsEventTriggered("Land") then
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            mod:PlaySound(SoundEffect.SOUND_SCAMPER, npc)
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
        else
            mod:SpritePlay(sprite, "Resurface")
        end

        if sprite:WasEventTriggered("Move") and not sprite:WasEventTriggered("Land") then
            npc.Velocity = (npc.TargetPosition - npc.Position)/7
        else
            npc.Velocity = npc.Velocity * 0.5
        end
    end

    if data.IsScalpel then
        if mod:ScalpelAI(npc, sprite, data, true) then
            npc.StateFrame = mod:RandomInt(bal.emergeDelay, rng)
            npc.Visible = false
            mod:ToggleCollision(npc)
            data.State = "Hidden"
            data.IsScalpel = false
        end
    end
    if data.State ~= "Chase" then
        data.Stepping = false
    end
end

function mod:DocHurt(npc, sprite, data, amount, damageFlags, source)
    if data.IsScalpel then
        return false
    end
end


mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, function(_, proj)
    proj:GetSprite():Play("Projectile", true)
    proj.SpriteRotation = proj.Velocity:GetAngleDegrees()
end, mod.ENT.SulfuricNeedle.Var)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj)
    local scale = 1 + ((proj.Scale - 1) * 0.5)
    proj.SpriteScale = Vector(scale, scale)
    proj.SpriteRotation = proj.Velocity:GetAngleDegrees()
end, mod.ENT.SulfuricNeedle.Var)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, proj)
    if proj.Variant == mod.ENT.SulfuricNeedle.Var then
        proj = proj:ToProjectile()
        for _, grid in pairs(mod:GetGridsInRadius(proj.Position, 40)) do
            if grid.CollisionClass >= GridCollisionClass.COLLISION_SOLID then
                grid:Destroy()
            end
        end
        local poof = Isaac.Spawn(mod.ENT.SulfuricNeedlePoof.ID, mod.ENT.SulfuricNeedlePoof.Var, 0, proj.Position, Vector.Zero, proj)
        poof.PositionOffset = proj.PositionOffset
        poof.SpriteScale = proj.SpriteScale
        poof.SpriteRotation = proj.SpriteRotation
        poof.Color = proj.Color
        poof:Update()
        mod:PlaySound(SoundEffect.SOUND_GLASS_BREAK, nil, 1.2, 0.75)
    end
end, mod.ENT.SulfuricNeedle.ID)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local sprite = effect:GetSprite()
    if sprite:IsFinished("Poof") then
        effect:Remove()
    else
        mod:SpritePlay(sprite, "Poof")
    end
end, mod.ENT.SulfuricNeedlePoof.Var)