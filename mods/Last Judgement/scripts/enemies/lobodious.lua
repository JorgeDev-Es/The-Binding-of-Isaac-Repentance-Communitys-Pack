local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
    moveSpeed = 1,
    moveSpeedRocks = 2.5,
    shootCooldown = {50,90},
    projSpeed = {4,6},
    projSpread = 30,
    projAngleVar = 15,
    retractSpeed = 7,
    maxBrains = 3,
}

local params = ProjectileParams()
params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE
params.Variant = mod.ENT.BrainProjectile.Var

local function GetBrains(npc, sortByDistance)
    local brains = {}
    for _, brain in pairs(Isaac.FindByType(mod.ENT.BrainProjectile.ID, mod.ENT.BrainProjectile.Var)) do
        if brain.Parent and brain.Parent.InitSeed == npc.InitSeed then
            table.insert(brains, brain)
        end
    end
    if sortByDistance then
        table.sort(brains, function(a,b) return a.Position:Distance(npc.Position) < b.Position:Distance(npc.Position) end)
    end
    return brains
end

local function LobodiusMove(npc)
    local state = npc:GetData().State
    if state == "Idle" or state == "Shoot" then
        local targetpos = mod:GetPlayerTargetPos(npc)
        local moveSpeed = game:GetRoom():GetGridCollisionAtPos(npc.Position) >= GridCollisionClass.COLLISION_SOLID and bal.moveSpeedRocks or bal.moveSpeed
        npc.Velocity = mod:Lerp(npc.Velocity, (targetpos - npc.Position):Resized(moveSpeed), 0.1)
    else
        npc.Velocity = npc.Velocity * 0.8
    end
end

local function MakeLaserTells(npc)
    local brains = GetBrains(npc, true)
    local current = npc
    for i = 1, #brains do
        local brain = brains[i]
        local beam = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.KINETI_BEAM, 0, brain.Position, Vector.Zero, npc)
        beam.Parent = current
        beam.Target = brain
        beam.Color = Color(0.5,0.8,1)
        beam:GetData().LobodiousBeam = true
        beam:GetData().LobodiousParent = npc
        current.Child = brain
        current = brain
    end
end

local function MakeLasers(npc)
    local current = npc
    while current.Child and current.Child:Exists() do
        local laser = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.ELECTRIC, 0, current.Position, Vector.Zero, npc):ToLaser()
        local vec = current.Child.Position - current.Position
        laser.Angle = vec:GetAngleDegrees()
        laser:SetMaxDistance(vec:Length())
        if not mod:isFriend(npc) then
            laser.CollisionDamage = 0
        end
        laser.Mass = 0
        laser.Parent = current
        laser.Target = current.Child
        laser.PositionOffset = Vector(0,-25)
        laser:Update()
        laser:GetData().LobodiousLaser = true
        laser:GetData().LobodiousParent = npc
        current = current.Child
    end
end

function mod:LobodiousAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)

    if not data.Init then
        npc.SplatColor = mod.Colors.MortisBlood
        npc.SpriteOffset = Vector(0,-10)
        npc.StateFrame = mod:RandomInt(bal.shootCooldown,rng)
        data.State = "Idle"
        data.Init = true
    end

    LobodiusMove(npc)

    if data.State == "Idle" then
        mod:SpritePlay(sprite, "Idle")

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if data.ShotBrains then
                data.ShotBrains = false
                data.SlowingBrains = true
                MakeLaserTells(npc)
                data.State = "RetractStart"
            else
                data.State = "Shoot"
            end
        end
    
    elseif data.State == "Shoot" then
        if sprite:IsFinished("Shoot") then
            npc.StateFrame = mod:RandomInt(bal.shootCooldown,rng)
            data.ShotBrains = true
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Shoot") then
            for i = -bal.projSpread, bal.projSpread, bal.projSpread do
                local proj = npc:FireProjectilesEx(npc.Position, (targetpos - npc.Position):Resized(mod:RandomInt(bal.projSpeed,rng)):Rotated(i + mod:RandomInt(-bal.projAngleVar,bal.projAngleVar,rng)), 0, params)[1]
                proj:ClearProjectileFlags(ProjectileFlags.HIT_ENEMIES)
                proj.Parent = npc
                proj:Update()
            end
            npc.Velocity = (npc.Position - targetpos):Resized(5)
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, npc.Position, Vector.Zero, npc)
            effect.Color = mod:CloneColor(mod.Colors.MortisBlood, 0.5)
            effect.DepthOffset = 40
            effect.SpriteOffset = Vector(0,-18)
            effect:Update()
            mod:PlaySound(SoundEffect.SOUND_GHOST_SHOOT, npc, 1.1, 0.7)
        else
            mod:SpritePlay(sprite, "Shoot")
        end

    elseif data.State == "RetractStart" then
        if sprite:IsFinished("RetractStart") then
            data.State = "Retracting"
        elseif sprite:IsEventTriggered("Sound") then
            MakeLasers(npc)
            mod:PlaySound(SoundEffect.SOUND_GRROOWL, npc, 1.1, 0.7)
            data.SlowingBrains = false
            data.RetractingBrains = true
        else
            mod:SpritePlay(sprite, "RetractStart")
        end

    elseif data.State == "Retracting" then
        mod:SpritePlay(sprite, "RetractLoop")
        if #GetBrains(npc) <= 0 then
            data.RetractingBrains = false
            data.State = "RetractEnd"
        end

    elseif data.State == "EatBrain" then
        if sprite:IsFinished("RetractBrain") then
            data.State = "Retracting"
        else
            mod:SpritePlay(sprite, "RetractBrain")
        end

    elseif data.State == "RetractEnd" then
        if sprite:IsFinished("RetractEnd") then
            npc.StateFrame = mod:RandomInt(bal.shootCooldown,rng)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_VAMP_GULP, npc, 0.9, 0.5)
        else
            mod:SpritePlay(sprite, "RetractEnd")
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local data = effect:GetData()
    if data.LobodiousBeam then
        if mod:IsReallyDead(effect.Target) or mod:IsReallyDead(data.LobodiousParent) or not data.LobodiousParent:GetData().SlowingBrains then
            data.LobodiousBeam = false
            mod:FadeOut(effect, 5)
            mod:ScheduleForUpdate(function() effect:Remove() end, 5)
        end
    end
end, EffectVariant.KINETI_BEAM) 

mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_, laser)
    local data = laser:GetData()
    if data.LobodiousLaser then
        if mod:IsReallyDead(laser.Parent) or mod:IsReallyDead(laser.Target) then
            laser:SetTimeout(1)
            data.LobodiousLaser = false
        else
            laser.Velocity = laser.Parent.Position - laser.Position
            local vec = laser.Target.Position - laser.Parent.Position
            laser.Angle = vec:GetAngleDegrees()
            laser:SetMaxDistance(vec:Length())
        end
    end
end, LaserVariant.ELECTRIC) 

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, function(_, proj)
    proj:GetSprite():Play("Move", true)
end, mod.ENT.BrainProjectile.Var)

mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj)
    local scale = 1 + ((proj.Scale - 1) * 0.5)
    proj.SpriteScale = Vector(scale, scale)

    local room = game:GetRoom()
    if mod:IsReallyDead(proj.Parent) or not room:IsPositionInRoom(proj.Position, -20) then
        proj.FallingAccel = 1
        proj.Velocity = proj.Velocity * 0.9
    else
        proj.FallingAccel = 0
        proj.FallingSpeed = 0
        proj.Height = -35

        if room:GetGridCollisionAtPos(proj.Position) >= GridCollisionClass.COLLISION_WALL then
            for i = 90, 360, 90 do
                local pos = proj.Position + Vector(20,0):Rotated(i)
                if room:IsPositionInRoom(pos, 0) and room:GetGridCollisionAtPos(pos) < GridCollisionClass.COLLISION_WALL then
                    if math.abs(pos.X - proj.Position.X) > math.abs(pos.Y - proj.Position.Y) then
                        proj.Velocity = Vector(-proj.Velocity.X, proj.Velocity.Y)
                    else
                        proj.Velocity = Vector(proj.Velocity.X, -proj.Velocity.Y)
                    end
                end
            end
        end

        if proj.Parent:GetData().RetractingBrains then
            mod:SpritePlay(proj:GetSprite(), "MoveActive")
            proj.Velocity = mod:Lerp(proj.Velocity, (proj.Parent.Position - proj.Position):Resized(bal.retractSpeed), 0.05)
            if proj.Position:Distance(proj.Parent.Position) <= 15 then
                mod:PlaySound(SoundEffect.SOUND_SMB_LARGE_CHEWS_4, proj.Parent, 0.9, 0.75)
                proj.Parent:GetData().State = "EatBrain"
                proj.Parent:GetSprite():Play("RetractBrain", true)
                proj.Parent.Velocity = proj.Velocity * 0.5
                proj:GetData().NoGibs = true
                proj:Remove()

                for _, laser in pairs(Isaac.FindByType(EntityType.ENTITY_LASER, LaserVariant.ELECTRIC)) do
                    if laser:GetData().LobodiousLaser and laser.Parent.InitSeed == proj.InitSeed then
                        laser.Parent = proj.Parent
                        break
                    end
                end
            end
        elseif proj.Parent:GetData().SlowingBrains then
            proj.Velocity = proj.Velocity * 0.9
        end
    end
end, mod.ENT.BrainProjectile.Var)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, proj)
    if proj.Variant == mod.ENT.BrainProjectile.Var then
        if not proj:GetData().NoGibs then
            proj = proj:ToProjectile()
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, proj.Position, Vector.Zero, proj)
            poof.Color = mod.Colors.MortisBlood
            poof.SpriteScale = proj.SpriteScale * 0.66
            poof.PositionOffset = proj.PositionOffset
            poof:Update()
            local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, proj.Position, Vector.Zero, proj)
            splat.Color = mod.Colors.MortisBlood
            splat:Update()
            for i = 1, 2 do
                local gib = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, proj.Position, RandomVector() * mod:RandomInt(2,6), proj)
                gib.Color = mod.Colors.MortisBlood
                gib.SplatColor = mod.Colors.MortisBlood
                gib:Update()
            end
            sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL)
        end
    end
end, mod.ENT.BrainProjectile.ID)

mod:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, function()
    for _, brain in pairs(Isaac.FindByType(mod.ENT.BrainProjectile.ID, mod.ENT.BrainProjectile.Var)) do
        brain:GetData().NoGibs = true
    end
end)