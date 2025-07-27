local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local exorcistBal = {
    moveSpeed = 5,
    reviveRadius = 85,
    remnantsToChase = 2,
    remnantCap = 6,
}

local remnantBal = {
    driftSpeed = 1,
    orbitDistance = 40,
    orbitSpeed = 4,
    shootCooldown = {60,90},
    projSpeed = 9,
}

local params = ProjectileParams()
params.Scale = 0.75
params.BulletFlags = ProjectileFlags.SMART | ProjectileFlags.NO_WALL_COLLIDE

local function GetRemnants(npc)
    local remnants = {}
    for _, remnant in pairs(Isaac.FindByType(mod.ENT.Remnant.ID, mod.ENT.Remnant.Var)) do
        if remnant.Parent and remnant.Parent.InitSeed == npc.InitSeed then
            table.insert(remnants, remnant)
        end
    end
    return remnants
end

local function CanReachPos(npc, pos)
    local room = game:GetRoom()
    return (npc.Pathfinder:HasPathToPos(pos, false) and room:GetGridPathFromPos(pos) <= 900)
end

local function GetRevivePos(npc, pos)
    if CanReachPos(npc, pos) then
        return pos
    else
        local room = game:GetRoom()
        for i = 45, 360, 45 do
            local closePos = pos + Vector.FromAngle(i):Resized(35)
            if CanReachPos(npc, closePos) then
                return closePos
            end
        end
        for i = 45, 360, 45 do
            local closePos = pos + Vector.FromAngle(i):Resized(75)
            if CanReachPos(npc, closePos) then
                return closePos
            end
        end
    end
end

local function IsRemnantValid(pos, remnant)
    return (remnant.FrameCount > 15 and remnant:GetData().State == "Inert")
end

local function GetReviveTarget(npc)
    local targetpos 
    local dist = 400
    for _, remnant in pairs(Isaac.FindByType(mod.ENT.Remnant.ID, mod.ENT.Remnant.Var)) do
        if IsRemnantValid(nil, remnant) then
            local revivePos = GetRevivePos(npc, remnant.Position)
            if revivePos then
                local newDist = revivePos:Distance(npc.Position)
                if newDist < dist then
                    targetpos = revivePos
                    dist = newDist
                end
            end
        end
    end
    return targetpos
end

function mod:ExorcistAI(npc, sprite, data)
    local bal = exorcistBal
    local targetpos = mod:GetPlayerTargetPos(npc)

    if not data.Init then
        data.State = "Idle"
        data.Init = true
    end

    if data.State == "Idle" then
        mod:AnimWalkFrame(npc, sprite, "WalkHori", "WalkVert", true)
        mod:SpriteOverlayPlay(sprite, "Head")

        local remnants = GetRemnants(npc)
        local reviveTarget = GetReviveTarget(npc)
        if reviveTarget and #remnants < bal.remnantCap then
            mod:ChasePosition(npc, reviveTarget, bal.moveSpeed, 0.3)
            local nearRemnant = mod:GetNearestThing(npc.Position, mod.ENT.Remnant.ID, mod.ENT.Remnant.Var, -1, IsRemnantValid)
            if nearRemnant and npc.Position:Distance(nearRemnant.Position) <= bal.reviveRadius then
                sprite:RemoveOverlay()
                mod:SpritePlay(sprite, "Revive")
                data.State = "Revive"
            end
        elseif #remnants >= bal.remnantsToChase and npc.Pathfinder:HasPathToPos(targetpos) then
            mod:ChasePosition(npc, targetpos, bal.moveSpeed, 0.3)
        else
            mod:WanderGridAligned(npc, data, bal.moveSpeed, 0.3) --, 1, 1, 60, 40, 100)
        end

    elseif data.State == "Revive" then
        npc.Velocity = npc.Velocity * 0.6

        if sprite:IsFinished("Revive") then
            data.GridAlignedHome = nil
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Revive") then
            local didRevive = false
            for _, remnant in pairs(Isaac.FindByType(mod.ENT.Remnant.ID, mod.ENT.Remnant.Var)) do
                if remnant:GetData().State == "Inert" and remnant.Position:Distance(npc.Position) < bal.reviveRadius + remnant.Size then
                    local angle = (remnant.Position - npc.Position):GetAngleDegrees()
                    for _, other in pairs(GetRemnants(npc)) do
                        if math.abs(other:GetData().OrbitAngle - angle) <= 45 then
                            angle = angle + 45
                        end
                    end
                    remnant.Parent = npc
                    remnant:GetData().OrbitAngle = angle
                    remnant:GetData().State = "Transform"
                    if mod:isFriend(npc) then
                        remnant:AddCharmed(EntityRef(npc), -1)
                    end
                    didRevive = true
                end
            end

            local poof1 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, npc.Position, Vector.Zero, npc)
            poof1.Color = mod:CloneColor(mod.Colors.PsyPurple, 0.25)
            poof1.SpriteScale = Vector(0.7,0.7)
            poof1:Update()
            local poof2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 2, npc.Position, Vector.Zero, npc)
            poof2.Color = mod:CloneColor(mod.Colors.PsyPurple, 0.25)
            poof2:Update()
        
            mod:PlaySound(SoundEffect.SOUND_BLACK_POOF, npc)
            mod:PlaySound(SoundEffect.SOUND_CANDLE_LIGHT, npc)
            if didRevive then
                mod:PlaySound(SoundEffect.SOUND_SUMMONSOUND, npc)
            end
        else
            mod:SpritePlay(sprite, "Revive")
        end
    end
end

local function CheckForExorcists(checkIfDead)
    if checkIfDead then
        for _, exorcist in pairs(Isaac.FindByType(mod.ENT.Exorcist.ID, mod.ENT.Exorcist.Var)) do
            if not exorcist:IsDead() then
                return true
            end
        end
        return false
    else
        return mod:GetEntityCount(mod.ENT.Exorcist.ID, mod.ENT.Exorcist.Var) > 0
    end
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, npc)
    if npc:IsEnemy() then
        if CheckForExorcists(true) and not (npc.Type == mod.ENT.Remnant.ID and npc.Variant == mod.ENT.Remnant.Var) and mod:GetEntityCount(mod.ENT.Remnant.ID, mod.ENT.Remnant.Var) < 30 then
            Isaac.Spawn(mod.ENT.Remnant.ID, mod.ENT.Remnant.Var, 0, npc.Position, (npc.Velocity * 0.5) + (RandomVector() * 2), npc)
        end
    end
end)

local function CheckForParent(npc, doExplode)
    if mod:IsReallyDead(npc.Parent) then
        if doExplode then
            npc:GetData().State = "Explode"
        end
        return false
    end
    return true
end

local function OrbitParent(npc, data)
    local bal = remnantBal
    data.OrbitAngle = data.OrbitAngle + bal.orbitSpeed
    npc.TargetPosition = npc.Parent.Position + Vector.FromAngle(data.OrbitAngle):Resized(bal.orbitDistance)
    npc.Velocity = mod:MinimizeVector(npc.TargetPosition - npc.Position, 8)
end

function mod:RemnantAI(npc, sprite, data)
    local bal = remnantBal
    local targetpos = mod:GetPlayerTargetPos(npc)
    local rng = npc:GetDropRNG()

    if not data.Init then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
        npc.SplatColor = mod:CloneColor(mod.Colors.PsyPurple, 0.65)
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 1, npc.Position, Vector.Zero, npc)
        poof.Color = mod:CloneColor(mod.Colors.PsyPurple, 0.65)
        poof:Update()
        data.State = "Inert"
        if npc.SubType == 0 or npc.SubType > 4 then
            data.Suffix = mod:RandomInt(1,4,rng)
        else
            data.Suffix = npc.SubType
        end
        data.Init = true
    end

    if data.State == "Inert" then
        local room = game:GetRoom()
        if not room:IsPositionInRoom(npc.Position, 20) then
            npc.Velocity = mod:Lerp(npc.Velocity, (room:GetCenterPos() - npc.Position):Resized(bal.driftSpeed), 0.05)
        else
            npc.Velocity = npc.Velocity * 0.9
        end

        if not CheckForExorcists() then
            data.State = "Fade"
        else
            mod:SpritePlay(sprite, "Idle"..data.Suffix)
        end

    elseif data.State == "Fade" then
        npc.Velocity = npc.Velocity * 0.8

        if sprite:IsFinished("Fade"..data.Suffix) then
            npc:Remove()
        else
            mod:SpritePlay(sprite, "Fade"..data.Suffix)
        end
    
    elseif data.State == "Transform" then
        if CheckForParent(npc) then
            OrbitParent(npc, data)
        else
            npc.Velocity = npc.Velocity * 0.8
        end

        if sprite:IsFinished("Transform"..data.Suffix) then
            npc.StateFrame = mod:RandomInt(bal.shootCooldown, rng)
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Coll") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
        else
            mod:SpritePlay(sprite, "Transform"..data.Suffix)
        end

    elseif data.State == "Idle" then
        if CheckForParent(npc, true) then
            mod:SpritePlay(sprite, "BigIdle"..data.Suffix)
            OrbitParent(npc, data)

            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                data.State = "Shoot"
            end
        end

    elseif data.State == "Shoot" then
        if CheckForParent(npc, true) then
            OrbitParent(npc, data)
        
            if sprite:IsFinished("Shoot"..data.Suffix) then
                npc.StateFrame = mod:RandomInt(bal.shootCooldown, rng)
                data.State = "Idle"
            elseif sprite:IsEventTriggered("Shoot") then
                npc:FireProjectiles(npc.Position, (targetpos - npc.Position):Resized(bal.projSpeed), 0, params)

                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 5, npc.Position, Vector.Zero, npc):ToEffect()
                effect.Color = mod:CloneColor(mod.Colors.PsyPurple, 0.65)
                effect.SpriteScale = Vector(0.8,0.8)
                effect.SpriteOffset = Vector(0,-12)
                effect.DepthOffset = 40
                effect:FollowParent(npc)
                effect:Update()

                mod:PlaySound(SoundEffect.SOUND_SHAKEY_KID_ROAR, npc, 1.1)
            else
                mod:SpritePlay(sprite, "Shoot"..data.Suffix)
            end
        end

    elseif data.State == "Explode" then
        npc.Velocity = npc.Velocity * 0.8

        if sprite:IsFinished("Explode"..data.Suffix) then
            mod:MakeGhostExplosion(npc.Position, npc, 1, mod.Colors.PsyPurple)
            npc:Kill()
        else
            mod:SpritePlay(sprite, "Explode"..data.Suffix)
        end
    end
end

function mod:RemnantHurt(npc, sprite, data, amount, damageFlags, source)
    if npc.EntityCollisionClass <= EntityCollisionClass.ENTCOLL_NONE or not data.Init then
        return false
    end
end

function mod:MakeGhostExplosion(position, source, scale, color, playerDamage, enemyDamage)
    scale = scale or 1
    playerDamage = playerDamage or 1
    enemyDamage = enemyDamage or 10

    local boom = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_GHOST, 1, position, Vector.Zero, source)
    boom.SpriteScale = Vector(scale, scale)
    boom:GetData().CustomGhostExplosion = true
    if color then
        boom.Color = color
        boom:GetData().ColoredGhostExplosion = true
    end
    boom:Update()

    mod:DamageInRadius(position, 60 * scale, playerDamage, source, 0, false, false, enemyDamage)

    sfx:Play(SoundEffect.SOUND_DEMON_HIT, scale)
end

function mod:CheckForGhostExplosion(effect)
    for _, boom in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_GHOST, 1)) do
        if effect.Position:Distance(boom.Position) <= 1 and boom:GetData().CustomGhostExplosion then
            effect.SpriteScale = boom.SpriteScale
            if boom:GetData().ColoredGhostExplosion then
                effect.Color = boom.Color
                mod:ScheduleForUpdate(function() effect.Color = boom.Color end, 0)
            end
            break
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.CheckForGhostExplosion, EffectVariant.BLOOD_EXPLOSION)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.CheckForGhostExplosion, EffectVariant.BLOOD_SPLAT)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, mod.CheckForGhostExplosion, EffectVariant.POOF01)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, collectibleType, rng, player, useFlags, slot, varData)
    for _, remnant in pairs(Isaac.FindByType(mod.ENT.Remnant.ID, mod.ENT.Remnant.Var)) do
        mod:MakeGhostExplosion(remnant.Position, player, 1, mod.Colors.PsyPurple, 0, player.Damage * 5)
        remnant:Kill()
    end
end, CollectibleType.COLLECTIBLE_VADE_RETRO)