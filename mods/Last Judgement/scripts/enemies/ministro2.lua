local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
    numJumps = {2,3},
    laserChance = 0.3,
    projChance = 0.5,
    maxProjRange = 200,
    maxOrbs = 2,
    projSpreadRange = 60,
    projAirTime = 20,
    burstProjSpeed = 8.5,
}

local params = ProjectileParams()
params.Variant = mod.ENT.MinistroIIProjectile.Var
params.FallingAccelModifier = 2
params.FallingSpeedModifier = -30

local function GetLaserTarget(npc)
    local room = game:GetRoom()
    local orbs = {}
    for _, orb in pairs(Isaac.FindByType(mod.ENT.MinistroIIOrb.ID, mod.ENT.MinistroIIOrb.Var)) do
        if room:CheckLine(npc.Position, orb.Position, LineCheckMode.PROJECTILE) then
            table.insert(orbs, orb.Position)
        end
    end
    return mod:GetRandomElem(orbs, npc:GetDropRNG()) or mod:GetPlayerTargetPos(npc)
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant == mod.ENT.MinistroII.Var then
        local sprite, data, targetpos, room, rng = npc:GetSprite(), npc:GetData(), mod:GetPlayerTargetPos(npc), game:GetRoom(), npc:GetDropRNG()

        if not data.Init then
            npc.ProjectileCooldown = mod:RandomInt(bal.numJumps, rng)    
            data.Init = true
        end

        if npc.State == 3 then
            if npc.ProjectileCooldown <= 0 then
                local laserTarget = GetLaserTarget(npc)
                local hitSpawnCap = (mod:GetEntityCount(mod.ENT.MinistroIIOrb.ID, mod.ENT.MinistroIIOrb.Var) >= mod:GetEntityCount(mod.ENT.MinistroII.ID, mod.ENT.MinistroII.Var) * bal.maxOrbs)
                if room:CheckLine(npc.Position, laserTarget, LineCheckMode.PROJECTILE) and (hitSpawnCap or rng:RandomFloat() <= bal.laserChance) then
                    npc.State = 9
                elseif rng:RandomFloat() <= bal.projChance and not hitSpawnCap then
                    sprite:Play("Attack", true)
                    npc.State = 8
                end  
            end

        elseif npc.State == 8 then
            if sprite:IsFinished("Attack") then
                npc.ProjectileCooldown = mod:RandomInt(bal.numJumps, rng) 
                npc.State = 3
            elseif sprite:IsEventTriggered("OrbShoot") then
                local baseTarget = (targetpos:Distance(npc.Position) <= bal.maxProjRange and targetpos or npc.Position + RandomVector() * mod:RandomInt(60,bal.maxProjRange))
                local projTarget = Isaac.GetFreeNearPosition(baseTarget + (RandomVector() * mod:RandomInt(0,bal.projSpreadRange,rng)), 20)
                local vel = (projTarget - npc.Position) / bal.projAirTime
                --Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 5, projTarget, Vector.Zero, npc)
                npc:FireProjectiles(npc.Position, vel, ProjectileMode.SINGLE, params)
                mod:PlaySound(SoundEffect.SOUND_WORM_SPIT, npc)
                mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, npc)
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 5, npc.Position, Vector.Zero, npc)
                effect.DepthOffset = 40
                effect.PositionOffset = npc:GetNullOffset("EffectPos")
                effect.Color = Color(1,1,1,0.6)
                effect:Update()
            end

        elseif npc.State == 9 then
            npc.Velocity = npc.Velocity * 0.5

            if sprite:IsFinished("Laser") then
                npc.ProjectileCooldown = mod:RandomInt(bal.numJumps, rng) 
                npc.State = 3
            elseif sprite:IsEventTriggered("Warn") then
                npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                npc.Velocity = Vector.Zero
                data.LaserAngle = (GetLaserTarget(npc) - npc.Position):GetAngleDegrees()
                local _, endPoint = room:CheckLine(npc.Position, npc.Position + Vector.FromAngle(data.LaserAngle):Resized(1000), LineCheckMode.PROJECTILE)
                mod:MakeCustomTracer(npc.Position, endPoint, npc, {
                    Color = Color(1,0,0),
                    Width = 0.5,
                    Duration = 12,
                    LineCheckMode = LineCheckMode.PROJECTILE,
                    FollowParent = true,
                })
            elseif sprite:IsEventTriggered("Shoot") then
                local laser = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.THIN_RED, 0, npc.Position, Vector.Zero, npc):ToLaser()
                laser.Parent = npc
                laser.Angle = data.LaserAngle
                laser.Timeout = 8
                laser.PositionOffset = npc:GetNullOffset("EffectPos")
                local laserEnd = mod:GetLaserEndPointFromLaser(laser)
                laser:SetMaxDistance(laser.Position:Distance(laserEnd))
                laser.DepthOffset = 20
                laser.CollisionDamage = 0.1
                laser.OneHit = true
                laser:Update()
                laser:Update()
                for _, orb in pairs(Isaac.FindByType(mod.ENT.MinistroIIOrb.ID, mod.ENT.MinistroIIOrb.Var)) do
                    if mod:CapsuleCollision(laser.Position, laserEnd, orb.Position, 17) then
                        orb:GetData().LaserAngle = laser.Angle
                        orb:Kill()
                    end
                end
                npc:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            else
                mod:SpritePlay(sprite, "Laser")
            end
        end
    end
end, EntityType.MINISTRO)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, function(_, proj)
    proj:GetSprite():Play("Projectile", true)
end, mod.ENT.MinistroIIProjectile.Var)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj)
    local scale = 1 + ((proj.Scale - 1) * 0.5)
    proj.SpriteScale = Vector(scale, scale)
end, mod.ENT.MinistroIIProjectile.Var)


mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, proj)
    if proj.Variant == mod.ENT.MinistroIIProjectile.Var then
        proj = proj:ToProjectile()
        if proj.Height >= -10 and game:GetRoom():GetGridCollisionAtPos(proj.Position) <= GridCollisionClass.COLLISION_NONE then
            local orb = Isaac.Spawn(mod.ENT.MinistroIIOrb.ID, mod.ENT.MinistroIIOrb.Var, 0, proj.Position, Vector.Zero, proj.SpawnerEntity):ToNPC()
            orb:GetSprite():GetLayer(0):SetColor(proj.Color) 
            orb.Scale = proj.SpriteScale.X
            orb:GetData().ProjFlags = proj.ProjFlags
            if proj:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
                orb.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
                orb:GetData().isFriend = true
            else
                orb.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            end
            orb:Update()
        else
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BULLET_POOF, 0, proj.Position, Vector.Zero, proj)
            effect.Color = proj.Color
            effect.SpriteScale = proj.SpriteScale * 1.15
            effect.PositionOffset = proj.PositionOffset
            effect:Update()
        end
    end
end, mod.ENT.MinistroIIProjectile.ID)

local burstParams = ProjectileParams()

function mod:MinistroIIOrbAI(npc, sprite, data)
    if not data.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS)
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, npc.Position, Vector.Zero, npc)
        effect.DepthOffset = -120
        effect.SpriteScale = Vector(1,0.65)
        effect:Update()
        mod:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS, npc)
        data.State = "Land"
        data.Init = true
    end

    npc.Velocity = Vector.Zero
    mod:NegateKnockoutDrops(npc)
    mod:QuickSetEntityGridPath(npc)
    npc:UpdateDirtColor()

    if data.State == "Land" then
        if sprite:IsFinished("Land") then
            data.State = "Idle"
            mod:SpritePlay(sprite, "Landed")
        else
            mod:SpritePlay(sprite, "Land")
        end

    elseif data.State == "Idle" then
        mod:SpritePlay(sprite, "Landed")
    end
    
    if npc:IsDead() then
        burstParams.BulletFlags = data.ProjFlags or 0
        burstParams.Scale = npc.Scale * 0.75
        if data.LaserAngle then
            for i = -90, 90, 180 do
                npc:FireProjectiles(npc.Position, Vector(bal.burstProjSpeed,0):Rotated(data.LaserAngle + i), ProjectileMode.SPREAD_THREE, burstParams)
            end
        else
            burstParams.CircleAngle = mod:RandomAngle()
            npc:FireProjectiles(npc.Position, Vector(bal.burstProjSpeed,6), ProjectileMode.CIRCLE_CUSTOM, burstParams)
        end
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BULLET_POOF, 0, npc.Position, Vector.Zero, npc)
        effect.Color = npc.Color
        effect.DepthOffset = 40
        effect.SpriteScale = npc.SpriteScale * 1.15
        effect:Update()
    end
end

function mod:MinistroIIOrbColl(npc, sprite, data, collider)
    if data.isFriend or mod:isFriend(npc) then
        if collider:ToNPC() then
            npc:Kill()
        end
    else
        if collider:ToPlayer() then
            npc:Kill()
        end
    end
end