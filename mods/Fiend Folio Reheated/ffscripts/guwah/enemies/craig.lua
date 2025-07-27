local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:CraigAI(npc, sprite, data)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)

    if not data.Init then
        npc.StateFrame = mod:RandomInt(45,60,rng)
        data.State = "Wander"
        sprite:Play("Idle1")
        data.Init = true
    end

    if data.State == "Wander" then
        local walkpos 
        npc.StateFrame = npc.StateFrame - 1

        if npc.StateFrame <= 0 then
            data.BulbPos = data.BulbPos or mod:GetCraigPos(npc)
            if data.BulbPos and npc.Position:Distance(data.BulbPos) < 20 then
                npc.TargetPosition = mod:GetNearestBulbRockPos(npc.Position)
                local vec = npc.TargetPosition - npc.Position
                data.Anim = "Chomp" .. mod:GetMoveString(mod:SnapVector(vec, 90))
                data.State = "Jump"
            end
            if data.BulbPos then
                walkpos = data.BulbPos
            end
        end

        if not walkpos then 
            data.MovePos = data.MovePos or mod:FindRandomValidPathPosition(npc)
            if npc.Position:Distance(data.MovePos) < 20 then
                data.MovePos = mod:FindRandomValidPathPosition(npc)
            end
            walkpos = data.MovePos
        end

        if walkpos then
            local vel
            walkpos = mod:confusePos(npc, walkpos)
            
            if mod:isScare(npc) and npc.Position:Distance(targetpos) <= 200 then
                vel = (npc.Position - targetpos):Resized(3)
            elseif room:CheckLine(npc.Position,walkpos,0,1,false,false) then
                vel = (walkpos - npc.Position):Resized(3)
            else
                npc.Pathfinder:FindGridPath(walkpos, 0.6, 900, true)
            end
        
            if vel then
                npc.Velocity = mod:Lerp(npc.Velocity, vel, 0.1)
            end
        else
            npc.Velocity = npc.Velocity * 0.8
        end

        local anim
        local suffix
        if npc.Velocity:Length() > 0.1 then
            if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
                anim = "WalkHori"
                if npc.Velocity.X < 0 then
                    suffix = 1
                else
                    suffix = 2
                end
            else
                anim = "WalkVert"
                if targetpos.X < npc.Position.X then
                    suffix = 1
                else
                    suffix = 2
                end
            end
        else
            anim = "Idle"
            if targetpos.X < npc.Position.X then
                suffix = 1
            else
                suffix = 2
            end
        end
        if npc.FrameCount > 1 then
            sprite:SetAnimation(anim..suffix, false)
        end
    elseif data.State == "Jump" then
        if sprite:IsFinished(data.Anim) then
            data.Anim = "ShootDown"
            data.State = "Shoot"
        elseif sprite:IsEventTriggered("Jump") then
            npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            local vec = npc.TargetPosition - npc.Position
            vec = vec:Resized(vec:Length() - 10)
            npc.Velocity = vec / 4
            mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP,npc)
            mod:PlaySound(mod.Sounds.CraigJump,npc)
        elseif sprite:IsEventTriggered("Chomp") then
            npc.Velocity = Vector.Zero
            mod:tryTriggerBulbRock(true)
        elseif sprite:IsEventTriggered("Detach") then
            local landpos = mod:FindSafeSpawnSpot(npc.Position, 100, 200, true)
            npc.Velocity = (landpos - npc.Position) / 5
        elseif sprite:IsEventTriggered("Land") then
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            npc.Velocity = npc.Velocity * 0.25
            mod:PlaySound(SoundEffect.SOUND_FETUS_LAND,npc)
        else 
            mod:spritePlay(sprite, data.Anim)
        end

        if sprite:WasEventTriggered("Chomp") and not sprite:WasEventTriggered("Detach") then
            npc.Velocity = Vector.Zero
        else
            npc.Velocity = npc.Velocity * 0.8
        end

    elseif data.State == "Shoot" then
        npc.Velocity = npc.Velocity * 0.8
        if sprite:IsFinished(data.Anim) then
            sprite:Play("Idle1")
            npc.StateFrame = mod:RandomInt(60,90,rng)
            data.State = "Wander"
            data.MovePos = nil
            data.BulbPos = nil
        elseif sprite:IsEventTriggered("Warn") then
            local vec = targetpos - npc.Position
            data.ShootAngle = mod:GetAngleDegreesButGood(vec)
            data.Anim = "Shoot" .. mod:GetMoveString(mod:SnapVector(vec, 90))
            sprite:SetAnimation(data.Anim, false)

            local tracer = Isaac.Spawn(1000, 198, 0, npc.Position + Vector(10, 0):Rotated(data.ShootAngle), Vector(0.001,0), npc):ToEffect()
            tracer.Timeout = 20
            tracer.TargetPosition = Vector(1,0):Rotated(data.ShootAngle)
            tracer.LifeSpan = 15
            tracer:FollowParent(npc)
            tracer.SpriteScale = Vector(5,5)
            tracer.Color = FiendFolio.ColorElectricYellow
            tracer:Update()
        elseif sprite:IsEventTriggered("Shoot") then
            mod:PlaySound(mod.Sounds.CraigLaser,npc,1,2)
            local laser = EntityLaser.ShootAngle(14, npc.Position, data.ShootAngle, 20, Vector(0,-30), npc)
            laser.Color = FiendFolio.ColorElectricYellow
        else
            mod:spritePlay(sprite, data.Anim)
        end
    end
end

function mod:CraigHurt(npc, amount, damageFlags, source)
    if mod:HasDamageFlag(damageFlags, DamageFlag.DAMAGE_LASER) and source.Entity and source.Type == mod.FF.Craig.ID and (source.Variant == mod.FF.Craig.Var or source.Variant == mod.FF.TaintedCraig.Var) then
        return false
    end
end

function mod:GetNearestBulbRockPos(pos)
    local bulbpos
    local dist = 9999
    for _, bulbrock in pairs(StageAPI.GetCustomGrids(nil, "FFBulbRock")) do
        local grid = bulbrock.GridEntity
        if grid and grid.Position:Distance(pos) < dist then
            bulbpos = grid.Position
            dist = grid.Position:Distance(pos)
        end
    end
    return bulbpos
end

function mod:GetCraigPos(npc)
	local room = game:GetRoom()
	local validtiles = {}

    for i = 0, room:GetGridSize() - 1 do 
        local gridpos = room:GetGridPosition(i)
        local bulbpos = mod:GetNearestBulbRockPos(gridpos)
		if bulbpos and bulbpos:Distance(gridpos) <= 160 and room:GetGridCollision(i) == GridCollisionClass.COLLISION_NONE and npc.Pathfinder:HasPathToPos(gridpos) and room:IsPositionInRoom(gridpos,0) then
            table.insert(validtiles, i)
        end
	end

	local dist = 10000
	local targetpos = nil
	for i, index in pairs(validtiles) do
		local distance = npc.Position:Distance(room:GetGridPosition(index))
		if distance < dist or not targetpos then
			targetpos = room:GetGridPosition(index)
			dist = distance
		end
	end

	return targetpos
end

local function TaintedCraigChase(npc, sprite, data, speed, targetpos)
    mod:ChasePlayer(npc, speed, tagretpos)

    local anim = "Idle"
    if npc.Velocity:Length() < 0.1 then
        data.Suffix = "Down"
        if data.State == "LaserShoot" then
            anim = anim.."NoHead"
        end
        mod:spritePlay(sprite, anim)
    else
        local anim = "Walk"
        if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
            data.Suffix = "Hori"
            if npc.Velocity.X > 0 then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end
        else
            if npc.Velocity.Y > 0 then
                data.Suffix = "Down"
            else
                data.Suffix = "Up"
            end
            sprite.FlipX = false
        end
        anim = anim..data.Suffix
        if data.State == "LaserShoot" then
            anim = anim.."NoHead"
        end
        if not sprite:IsPlaying() then
            sprite:Play(anim)
        else
            sprite:SetAnimation(anim, false)
        end
    end
end

function mod:TaintedCraigAI(npc, sprite, data)
    local room = game:GetRoom()
    local rng = npc:GetDropRNG()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)

    if not data.Init then
        data.State = "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        local speed = 3.5
        local chasepos = targetpos
        if npc.Child and npc.Child:Exists() then
            local radius = npc.Child:ToLaser().Radius
            if radius >= 100 then
                data.State = "Heehee"
            elseif radius >= 80 then
                chasepos = room:GetCenterPos()
            end
        elseif npc.FrameCount > 1 then
            local ring = Isaac.Spawn(7, 2, 2, npc.Position, Vector.Zero, npc):ToLaser()
            ring.CollisionDamage = 0
            ring.Parent = npc
            ring.Radius = 5
            ring:AddTearFlags(TearFlags.TEAR_CONTINUUM)
            ring:SetColor(FiendFolio.ColorElectricYellow, 999, 1, false, false)
            ring.Visible = false
            ring:GetData().CraigRing = true
            npc.Child = ring
            sfx:Play(SoundEffect.SOUND_LASERRING)
        end
        TaintedCraigChase(npc, sprite, data, speed, chasepos)

    elseif data.State == "Heehee" then
        npc.Velocity = npc.Velocity * 0.7

        if sprite:IsFinished("TeeHee"..data.Suffix) then
            data.State = "ChargeUp"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(mod.Sounds.SpyVsSpyLaughEvil, npc, 1)
        else
            mod:spritePlay(sprite, "TeeHee"..data.Suffix)
        end
    elseif data.State == "ChargeUp" then
        npc.Velocity = npc.Velocity * 0.7

        if sprite:IsFinished("ChargeUp") then
            data.State = "LaserShoot"
            local laser = EntityLaser.ShootAngle(14, npc.Position, data.ShootAngle, 150, Vector(0,-25), npc)
            laser.ParentOffset = Vector(15,0):Rotated(data.ShootAngle)
            laser.Color = FiendFolio.ColorElectricYellow
            npc.Child = laser
            mod:PlaySound(mod.Sounds.ElectricShock, npc, 1, 1.5)
            mod:PlaySound(mod.Sounds.Blaargh, npc, 1.5)
            mod:PlaySound(mod.Sounds.BeastBrimStart, npc, 3, 0.4)
            mod:PlaySound(SoundEffect.SOUND_LASERRING_STRONG, npc, 0.2, 0.5)
            mod:PlaySound(SoundEffect.SOUND_LASERRING, npc, 0.2, 0.5)
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(mod.Sounds.ShockerCharge, npc, 1, 0.8)
        elseif sprite:IsEventTriggered("Lock") then
            local vec = targetpos - npc.Position
            data.ShootAngle = mod:GetAngleDegreesButGood(vec)

            local tracer = Isaac.Spawn(1000, 198, 0, npc.Position + Vector(10, 0):Rotated(data.ShootAngle), Vector(0.001,0), npc):ToEffect()
            tracer.Timeout = 20
            tracer.TargetPosition = Vector(1,0):Rotated(data.ShootAngle)
            tracer.LifeSpan = 15
            tracer:FollowParent(npc)
            tracer.SpriteScale = Vector(5,5)
            tracer.Color = FiendFolio.ColorElectricYellow
            tracer:Update()
        else
            mod:spritePlay(sprite, "ChargeUp")
        end
        
    elseif data.State == "LaserShoot" then
        npc.Velocity = npc.Velocity * 0.7

        if npc.Child and npc.Child:Exists() then
            local laser = npc.Child:ToLaser()
            if laser.Timeout < 5 then
                sfx:Stop(mod.Sounds.BeastBrimLoop)
                mod:PlaySound(mod.Sounds.BeastBrimEnd, npc, 3, 0.4)
                npc.Child = nil
            else
                TaintedCraigChase(npc, sprite, data, 2.5, targetpos)
                local angledifference = mod:GetAngleDifferenceDead(Vector(1,0):Rotated(laser.Angle), targetpos - npc.Position)
                laser.Angle = laser.Angle - (angledifference/50)
                laser.ParentOffset = Vector(15,0):Rotated(laser.Angle)
                local angle = 360 - mod:NormalizeDegreesTo360(laser.Angle)
                if angle < 60 then
                    data.Suffix = 5
                elseif angle < 120 then
                    data.Suffix = 4
                elseif angle < 180 then
                    data.Suffix = 3
                elseif angle < 240 then
                    data.Suffix = 2
                elseif angle < 300 then
                    data.Suffix = 1
                else
                    data.Suffix = 6
                end
                if sprite.FlipX then
                    if data.Suffix == 2 then
                        data.Suffix = 6
                    elseif data.Suffix == 3 then
                        data.Suffix = 5
                    elseif data.Suffix == 5 then
                        data.Suffix = 3
                    elseif data.Suffix == 6 then
                        data.Suffix = 2
                    end
                end
                mod:spriteOverlayPlay(sprite, "Shoot0"..data.Suffix)
                if not sfx:IsPlaying(mod.Sounds.BeastBrimLoop) then
                    mod:PlaySound(mod.Sounds.BeastBrimLoop, npc, 3, 0.4, true)
                end
            end
        else 
            data.State = "LaserEnd"
            sprite:RemoveOverlay()
            mod:spritePlay(sprite, "AttackEnd"..data.Suffix)
            if data.Suffix == 1 then
                data.Suffix = "Down"
            elseif data.Suffix == 4 then
                data.Suffix = "Up"
            else
                data.Suffix = "Hori"
            end
        end
    
    elseif data.State == "LaserEnd" then
        npc.Velocity = npc.Velocity * 0.7

        if sprite:IsFinished("AttackEnd"..data.Suffix) then
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Stop") then
            mod:PlaySound(SoundEffect.SOUND_BEAST_DEATH, npc, 3, 0.6)
        else
            mod:spritePlay(sprite, "AttackEnd"..data.Suffix)
        end

    elseif data.State == "Death" then
        if sprite:IsFinished("Death") then
            npc.SplatColor = mod.ColorCharred
            game:BombExplosionEffects(npc.Position, 2, 0, Color.Default, npc, 1.5)
            npc:Kill()
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(mod.Sounds.ElectricShock, npc, 1, 1.5)
        else
            mod:spritePlay(sprite, "Death")
        end
    end
end

function FiendFolio.TaintedCraigDeathAnim(npc)
	local onCustomDeath = function(npc, deathAnim)
        npc:GetData().State = "Death"
        sfx:Stop(mod.Sounds.BeastBrimLoop)
        deathAnim:GetData().State = "Death"
        deathAnim:GetData().Init = true
    end
    FiendFolio.genericCustomDeathAnim(npc, "Death", true, onCustomDeath, false, false, true, true)
end

function mod:CraigRing(laser, data)
    laser.Visible = true
    laser:SetColor(FiendFolio.ColorElectricYellow, 999, 1, false, false)
    if laser.Parent and not mod:IsReallyDead(laser.Parent) then
        laser.Velocity = laser.Parent.Position - laser.Position
        if laser.Parent:GetData().State ~= "Idle" then
            laser.Radius = laser.Radius - 1.5
            if laser.Radius <= 5 then
                laser:SetTimeout(1)
            end
        elseif laser.Radius < 100 then
            laser.Radius = laser.Radius + 0.6
        end
    else
        laser.Velocity = Vector.Zero
        laser.Radius = laser.Radius - 5
        if laser.Radius <= 5 then
            laser:SetTimeout(1)
        end
    end
end