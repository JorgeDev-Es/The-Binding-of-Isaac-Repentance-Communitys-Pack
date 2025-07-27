local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local bal = {
    idleSpeed = {1.25,0.15},
    chargeCooldown = 30,
    chargeSpeed = 12,
    clusterSpeed = 12,
    clusterAmount = {8,10},
    woundProjSpeed = {6,10},
    woundDuration = 300,
}

local params = ProjectileParams()
params.Color = mod.Colors.MortisBloodProj
params.BulletFlags = ProjectileFlags.NO_WALL_COLLIDE

local function GetWoundPosition(npc)
    return game:GetRoom():GetLaserTarget(npc.Position, npc.V1)
end

local function DoCharge(npc, data)
    npc.Velocity = mod:Lerp(npc.Velocity, npc.V1, 0.3)
    local grid = game:GetRoom():GetGridEntityFromPos(npc.Position + npc.V1:Resized(30))
    if grid then 
        if not (grid.CollisionClass <= GridCollisionClass.COLLISION_NONE or grid:Destroy()) then
            if grid:GetType() == GridEntityType.GRID_WALL then
                npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
                data.State = "Collision"

                for i = 1, 3 do
                    local gib = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE, 0, GetWoundPosition(npc), -npc.V1:Resized(mod:RandomInt(4,7)):Rotated(mod:RandomInt(-20,20)), npc)
                    gib:Update()
                end
                mod:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, npc)
            else
                npc.Velocity = npc.V1:Resized(-8)
                npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                npc.StateFrame = mod:RandomInt(10,20,npc:GetDropRNG())
                data.State = "Idle"
            end   
            mod:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, npc, 1.5, 0.75)
        end
    end
end

function mod:GashAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)

    if not data.Init then
        npc.SplatColor = mod.Colors.MortisBlood
        npc.StateFrame = bal.chargeCooldown
        data.State = "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        if mod:WanderAbout(npc, data, bal.idleSpeed) then
            if math.abs(npc.Velocity.X) > 0.05 then
                mod:FlipSprite(sprite, npc.Position, npc.Position + npc.Velocity)
            end
            mod:SpritePlay(sprite, "Walk")
        else
            mod:SpritePlay(sprite, "Idle")
        end

        npc.StateFrame = npc.StateFrame - 1
        if npc.StateFrame <= 0 then
            if mod:IsAlignedWithPos(npc.Position, targetpos, 20, LineCheckMode.EXPLOSION, 400) then
                npc.V1 = mod:SnapVector((targetpos - npc.Position):Resized(bal.chargeSpeed), 90)
                data.AnimSuffix, sprite.FlipX = mod:GetMoveString(npc.V1, true)
                data.State = "ChargeStart"
                mod:PlaySound(SoundEffect.SOUND_ANGRY_GURGLE, npc)
            end
        end
    
    elseif data.State == "ChargeStart" then
        if sprite:WasEventTriggered("Charge") then
            DoCharge(npc, data)
        else
            npc.Velocity = npc.Velocity * 0.7
        end

        if sprite:IsFinished("Charge"..data.AnimSuffix.."Start") then
            data.State = "Charging"
        elseif sprite:IsEventTriggered("Charge") then
            npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            mod:PlaySound(SoundEffect.SOUND_FETUS_JUMP, npc)
        else
            mod:SpritePlay(sprite, "Charge"..data.AnimSuffix.."Start")
        end

    elseif data.State == "Charging" then
        DoCharge(npc, data)
        mod:SpritePlay(sprite, "Charge"..data.AnimSuffix)

    elseif data.State == "Collision" then
        npc.Velocity = npc.Velocity * 0.5

        if sprite:IsFinished("Collision"..data.AnimSuffix) then
            npc.StateFrame = bal.chargeCooldown
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Hop") then
            local wound = Isaac.Spawn(mod.ENT.GashWound.ID, mod.ENT.GashWound.Var, 0, GetWoundPosition(npc), Vector.Zero, npc)
            wound.SpriteRotation = npc.V1:GetAngleDegrees() + 90
            wound:GetData().SpawnerRef = npc
            wound:Update()

            mod:ShootClusterProjectiles(npc, -npc.V1:Resized(bal.clusterSpeed), mod:RandomInt(bal.clusterAmount,rng), params, 20, 0.5, -5, 1.5, wound.Position)
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
            npc.Velocity = npc.V1:Resized(-8)

            for i = 1, 3 do
                mod:ScheduleForUpdate(function()
                    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, mod:isFriend(npc) and EffectVariant.PLAYER_CREEP_RED or EffectVariant.CREEP_RED, 0, wound.Position - npc.V1:Resized(30 * (i - 1)), Vector.Zero, npc):ToEffect()
                    creep.Color = mod.Colors.MortisBlood
                    creep.SpriteScale = Vector((4 - i) * 0.5, (4 - i) * 0.5)
                    creep:SetTimeout(bal.woundDuration)
                    creep:Update()
                    local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, creep.Position, Vector.Zero, npc)
                    splat.Color = creep.Color
                    splat.SpriteScale = creep.SpriteScale
                    splat:Update()
                    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, creep.Position, Vector.Zero, npc)
                    poof.Color = creep.Color
                    poof.SpriteScale = creep.SpriteScale
                    poof:Update()
                end, i * 2)
            end

            for i = 1, 3 do
                local gib = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, wound.Position, -npc.V1:Resized(mod:RandomInt(7,10)):Rotated(mod:RandomInt(-20,20)), npc)
                gib.Color = mod:GetMortisBackdropSplatColor()
                gib.SplatColor = mod:GetMortisBackdropSplatColor()
                gib:Update()
            end
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 4, wound.Position + npc.V1:Resized(30), Vector.Zero, npc)
            poof.Color = mod.Colors.MortisBlood
            poof.SpriteScale = Vector(0.8,0.8)
            poof:Update()
            mod:PlaySound(SoundEffect.SOUND_KNIFE_PULL, npc)
        elseif sprite:IsEventTriggered("Land") then
            mod:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, npc, 3, 0.5)
            mod:PlaySound(SoundEffect.SOUND_BLOBBY_WIGGLE, npc)
        else
            mod:SpritePlay(sprite, "Collision"..data.AnimSuffix)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
    local sprite = effect:GetSprite()
    if mod.UsingMorgueisBackdrop then
        sprite:ReplaceSpritesheet(0, "gfx/enemies/gash/gash_wound_morgueis.png", true)
    elseif mod.UsingMoistisBackdrop then
        sprite:ReplaceSpritesheet(0, "gfx/enemies/gash/gash_wound_moistis.png", true)
    end
    sprite:Play("Appear", true)
    effect.DepthOffset = -2000
end, mod.ENT.GashWound.Var)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local sprite = effect:GetSprite()

    if sprite:IsFinished("Appear") then
        local vec = Vector.FromAngle(effect.SpriteRotation + 90)
        if effect.FrameCount % 3 == 0 then
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 1, effect.Position + vec:Resized(-30), vec:Resized(mod:RandomInt(bal.woundProjSpeed)):Rotated(mod:RandomInt(-20,20)), effect)
            poof.Color = mod.Colors.MortisBlood
            local scale = mod:RandomInt(8,12,rng) * 0.1
            poof.SpriteScale = Vector(scale,scale)
            mod:FadeIn(poof, 3)
            poof:Update()
        end
        if effect.FrameCount % 8 == 0 then
            local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0, 0, effect.Position + vec:Resized(-30), vec:Resized(mod:RandomInt(bal.woundProjSpeed)):Rotated(mod:RandomInt(-35,35)), effect):ToProjectile()
            proj.FallingSpeed = mod:RandomInt(-10,-5)
            proj.Height = -10
            proj.FallingAccel = 0.6
            proj.Scale = mod:RandomInt(5,15,rng) * 0.1
            proj.Color = mod.Colors.MortisBloodProj
            proj:AddProjectileFlags(ProjectileFlags.NO_WALL_COLLIDE)
            mod:makeProjectileConsiderFriend(effect:GetData().SpawnerRef, proj)
            mod:FadeIn(proj, 3)
            proj:Update()
            mod:PlaySound(SoundEffect.SOUND_BLOODSHOOT, nil, mod:RandomInt(16,24) * 0.05, 0.3)
        end
        if effect.FrameCount > bal.woundDuration or not mod:IsRoomActive() then
            sprite:Play("Leave", true)
        end
    elseif sprite:IsFinished("Leave") then
        effect:Remove()
    end
end, mod.ENT.GashWound.Var)
