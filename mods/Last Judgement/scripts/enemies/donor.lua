local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

local donorBal = {
    moveSpeed = 1,
    moveSpeedScaling = 0.25,
    idleTime = {60,120},
    shootTime = {300,450},
    shootHPThresh = 0.9,
    shootRange = 100,
    launchSpread = 75,
    launchSpeed = 24,
    gutRange = 160,
}

local slinkingBal = {
    moveSpeed = 3,
    avoidRange = 100,
    shootTime = {60,120},
    minAttackRange = 100,
    maxProjSpeed = 12,
    burstProjAmount = {6,9},
    burstProjSpeed = 8,
}

local params1 = ProjectileParams()
params1.Color = mod.Colors.OrganYellow
params1.Scale = 2.5
params1.FallingSpeedModifier = -30
params1.FallingAccelModifier = 2

local hulkingBal = {
    moveSpeed = 3,
    shootCooldown = 20,
    attackRange = 300,
    projSpeed = 6,
    projDuration = 12,
}

local params2 = ProjectileParams()
params2.Color = mod.Colors.OrganPurple
params2.FallingAccelModifier = 1.5

local patheticBal = {
    jumpTime = {30,60},
    maxJumpDist = 200,
    projAmount = {6,9},
    projSpeed = 4,
}

local params3 = ProjectileParams()
params3.Color = mod.Colors.OrganBlue
params3.FallingAccelModifier = 1.5

function mod:GetCordOffset(npc)
    return npc:GetNullOffset("CordPos") + Vector(0,17)
end

function mod:AttachCord(startEnt, endEnt, subtype, anim, splatColor, startOffset, endOffset)
    subtype = subtype or 0

    local cord = Isaac.Spawn(EntityType.ENTITY_EVIS, 10, subtype, startEnt.Position, Vector.Zero, startEnt):ToNPC()
    cord:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    cord:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    cord.TargetPosition = Vector.One
    anim = anim or cord:GetSprite():GetDefaultAnimationName()
    if anim then
        cord:GetSprite():Play(anim, true)
    end

    if startOffset then
        local anchor = Isaac.Spawn(mod.ENT.CordAnchorPoint.ID, mod.ENT.CordAnchorPoint.Var, 0, startEnt.Position, Vector.Zero, startEnt):ToEffect()
        anchor.Parent = startEnt
        anchor.ParentOffset = startOffset
        anchor:Update()
        cord.Parent = anchor
        startEnt:GetData().CordAnchorPoint = anchor
    else
        cord.Parent = startEnt
    end
    cord.Parent:AddVelocity(Vector(0.001,0))

    if endOffset then
        local anchor = Isaac.Spawn(mod.ENT.CordAnchorPoint.ID, mod.ENT.CordAnchorPoint.Var, 0, endEnt.Position, Vector.Zero, endEnt):ToEffect()
        anchor.Parent = endEnt
        anchor.ParentOffset = endOffset
        anchor:Update()
        cord.Target = anchor
        endEnt:GetData().CordAnchorPoint = anchor
    else
        cord.Target = endEnt
    end
    cord.Target:AddVelocity(Vector(0.001,0))

    if splatColor then
        cord.SplatColor = splatColor
        cord:GetData().CordSplatColor = splatColor
    end
    for i = 1, 20 do
        cord:Update()
    end

    return cord
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant == 10 then
        if npc:GetData().CordSplatColor then
            npc.SplatColor = npc:GetData().CordSplatColor
        end
    end
end, EntityType.ENTITY_EVIS)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, effect)
    if mod:IsReallyDead(effect.Parent) then
        effect:Remove()
    else
        local cordOffset = mod:GetCordOffset(effect.Parent)
        if cordOffset and cordOffset:Length() > 0 then
            effect.ParentOffset = cordOffset
        end
        effect.Position = effect.Parent.Position + effect.ParentOffset
    end
end, mod.ENT.CordAnchorPoint.Var)

local function GetGuts(npc)
    local guts = {}
    for _, gut in pairs(Isaac.FindByType(mod.ENT.Donor.ID)) do
        if gut.Parent and gut.Parent.InitSeed == npc.InitSeed then
            table.insert(guts, gut)
        end
    end
    return guts
end

function mod:DonorAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)
    local bal = donorBal

    if not data.Init then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_BLOOD_SPLASH)
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc.SplatColor = mod.Colors.MortisBlood
        data.State = "Appear"
        data.Suffix = ""
        sprite:Play("Appear", true)
        data.Init = true
    end

    mod:QuickSetEntityGridPath(npc)

    local numGuts = 0
    for _, gut in pairs(GetGuts(npc)) do
        if gut:GetData().Grounded then
            local dist = npc.Position:Distance(gut.Position)
            local excess = dist - bal.gutRange
            if excess > 0 then
                npc.Velocity = mod:Lerp(npc.Velocity, (gut.Position - npc.Position):Resized(excess), 0.05)
                gut.Velocity = mod:Lerp(gut.Velocity, (npc.Position - gut.Position):Resized(excess), 0.25)
            end
        end
        numGuts = numGuts + 1
    end

    if data.SpawnedGuts and numGuts <= 0 then
        npc:Kill()
    end

    if data.State == "Appear" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("Appear") then
            npc.StateFrame = mod:RandomInt(bal.shootTime, rng)
            data.CurrentAnim = "Idle"
            data.CurrentDirection = ""
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Coll") then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET)
        else
            mod:SpritePlay(sprite, "Appear")
        end

    elseif data.State == "Idle" then
        local moveSpeed = bal.moveSpeed + ((3 - numGuts) * bal.moveSpeedScaling)
        local isMoving, _, moveVec = mod:WanderAboutAir(npc, data, moveSpeed, 0.3, bal.idleTime[1], bal.idleTime[2], nil, 60, nil, 0)
        if isMoving and math.abs(moveVec.X) > 0 and not data.Moving then
            data.CurrentAnim = "StartMove"
            data.CurrentDirection = (moveVec.X < 0) and "Left" or "Right"
            sprite:Play(data.CurrentAnim..data.CurrentDirection..data.Suffix, true)
            mod:PlaySound(mod.Sounds.DonorStart, npc, 1, 0.33)
            data.Moving = true
        elseif data.Moving and not isMoving then
            data.CurrentAnim = "StopMove"
            sprite:Play(data.CurrentAnim..data.CurrentDirection..data.Suffix, true)
            mod:PlaySound(mod.Sounds.DonorStop, npc, 1, 0.33)
            data.Moving = false
        end
        
        if not isMoving then
            npc.Velocity = Vector.Zero
        end

        if sprite:IsFinished() then
            if data.CurrentAnim == "StartMove" then
                data.CurrentAnim = "Move"
            elseif data.CurrentAnim == "StopMove" then
                data.CurrentAnim = "Idle"
                data.CurrentDirection = ""
            end
        end
        mod:SpritePlay(sprite, data.CurrentAnim..data.CurrentDirection..data.Suffix)

        --[[if sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_BLOBBY_WIGGLE, npc, 2.5, 0.2)
            mod:PlaySound(SoundEffect.SOUND_SCAMPER, npc, 1, 0.2)
        end]]

        if npc.FrameCount > 0 and npc.Pathfinder:HasPathToPos(targetpos, false) and not data.SpawnedGuts then
            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 or npc.HitPoints <= npc.MaxHitPoints * bal.shootHPThresh or (targetpos:Distance(npc.Position) <= bal.shootRange and game:GetRoom():CheckLine(npc.Position, targetpos, 3)) then
                data.State = "Launch"
                if data.Moving then
                    mod:PlaySound(mod.Sounds.DonorStop, npc, 1, 0.33)
                    data.Moving = false
                end
            end
        end

    elseif data.State == "Launch" then
        npc.Velocity = Vector.Zero

        if sprite:IsFinished("Explode") then
            data.SpawnedGuts = true
            data.CurrentAnim = "Idle"
            data.CurrentDirection = ""
            data.Suffix = " D"
            data.State = "Idle"
        elseif sprite:IsEventTriggered("Sound") then
            mod:PlaySound(SoundEffect.SOUND_ANGRY_GURGLE, npc, 0.75)
            npc.TargetPosition = targetpos
            data.Suffix = (npc.TargetPosition.Y < npc.Position.Y) and "Up" or "Down"
            sprite:SetAnimation("Shoot"..data.Suffix, false)
        elseif sprite:IsEventTriggered("Shoot") then
            local vals = rng:RandomFloat() <= 0.5 and {-bal.launchSpread,bal.launchSpread} or {bal.launchSpread,-bal.launchSpread}
            local iter = 1
            for i = vals[1], vals[2], vals[2] do
                local gutVar
                local cordAnim
                local vec = (npc.TargetPosition - npc.Position):Resized(bal.launchSpeed):Rotated(i)
                if iter == 1 then
                    gutVar = mod.ENT.SlinkingGuts.Var
                    cordAnim = "SlinkingCord"
                elseif iter == 2 then
                    gutVar = mod.ENT.HulkingGuts.Var
                    cordAnim = "HulkingCord"
                elseif iter == 3 then
                    gutVar = mod.ENT.PatheticGuts.Var
                    cordAnim = "PatheticCord"
                    vec = vec / 4
                end
                local gut = Isaac.Spawn(mod.ENT.Donor.ID, gutVar, 0, npc.Position + vec, vec, npc)
                gut:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                gut.Parent = npc
                gut:Update()
                local cord = mod:AttachCord(npc, gut, mod.ENT.DonorCord.Sub, cordAnim, gut.SplatColor, mod:GetCordOffset(npc), mod:GetCordOffset(gut))
                cord.DepthOffset = -20
                iter = iter + 1
            end

            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 5, npc.Position, Vector.Zero, npc)
            effect.SpriteScale = Vector(0.7,0.7)
            effect.Color = mod:CloneColor(mod.Colors.MortisBlood, 0.5)
            effect.DepthOffset = (data.Suffix == "Up") and -120 or 0
            effect.SpriteOffset = Vector(0,-25)
            effect:Update()
            npc:BloodExplode()
        elseif sprite:IsEventTriggered("Sound2") then
            mod:PlaySound(SoundEffect.SOUND_SKIN_PULL, npc, 1.2, 0.65)
        else
            mod:SpritePlay(sprite, "Explode")
        end
    end

    if data.Suffix == " D" then
        if npc.FrameCount % 3 == 0 and rng:RandomFloat() <= 0.2 then
            local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, npc.Position, Vector.Zero, npc)
            local scale = mod:RandomInt(30,60,rng) * 0.01
            splat.SpriteScale = Vector(scale,scale)
            splat.Color = npc.SplatColor
            splat:Update()
        end
    end

    if npc:IsDead() then --I have to reimplement this bc it was bugged and offset waaay to the right for some reason whY???? 
        local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 3, npc.Position, Vector.Zero, npc)
        splat.Color = npc.SplatColor 
        splat.SpriteOffset = Vector(0,-15)
        splat:Update()
    end
end

mod:RegisterLoopingSound(mod.Sounds.DonorLoop, function()
    for _, donor in pairs(Isaac.FindByType(mod.ENT.Donor.ID, mod.ENT.Donor.Var)) do
        if donor:GetData().State == "Idle" and donor:GetData().Moving then
            return 0.33, 1
        end
    end
end, 0.1)

local function DoGutTrail(npc)
    local rng = npc:GetDropRNG()
    if npc:GetData().Grounded and npc.FrameCount % 3 == 0 and rng:RandomFloat() <= 0.2 then
        local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, npc.Position, Vector.Zero, npc)
        local scale = mod:RandomInt(50,100,rng) * 0.01
        splat.SpriteScale = Vector(scale,scale)
        splat.Color = npc.SplatColor
        splat:Update()
        return splat
    end
end

local function GetSlinkingPos(npc, targetpos)
    local vec = npc.Parent.Position - targetpos
    local optimalDist = math.max(40, 250 - vec:Length())
    local optimalTarget = npc.Parent.Position + vec:Resized(optimalDist)
    if npc.Pathfinder:HasPathToPos(optimalTarget, false) then
        return optimalTarget
    end
    for _, dist in pairs({80,40,120,160}) do
        local target = npc.Parent.Position + vec:Resized(dist)
        if npc.Pathfinder:HasPathToPos(target, false) then
            return target
        end
    end
end

local function SlinkingGutProj(proj, tab)
    if proj.FrameCount % 3 == 0 then
        local particle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, proj.Position, -proj.Velocity * 0.5, proj)
        particle.DepthOffset = -80
        particle.PositionOffset = proj.PositionOffset
        particle.Color = mod.Colors.OrganYellow
        particle:Update()
    end
end

local function SlinkingGutProjDeath(proj, tab)
    local bal = slinkingBal
    local angle = mod:RandomInt(360)
    local numProjs = mod:RandomInt(bal.burstProjAmount)
    for i = 360/numProjs, 360, 360/numProjs do
        local vec = Vector.FromAngle(i + angle + mod:RandomInt(-25,25)):Resized(bal.burstProjSpeed)
        local p = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, proj.Variant, 0, proj.Position, vec, proj):ToProjectile()
        p.Color = proj.Color
        p.ProjectileFlags = proj.ProjectileFlags
        p.Scale = mod:RandomInt(5,12) * 0.1
        p.FallingSpeed = mod:RandomInt(-20,-5)
        p.FallingAccel = 2
        p:Update()
    end
end

local function SlinkingGutMove(npc, targetpos, speed)
    local idealPos = GetSlinkingPos(npc, targetpos)
    local targDist = npc.Position:Distance(targetpos)
    local angleDiff = mod:GetAbsoluteAngleDifference(npc.Parent.Position - targetpos, npc.Position - targetpos)
    local shouldWander = true
    if angleDiff > 20 or targDist < npc.Parent.Position:Distance(targetpos) or (idealPos and npc.Position:Distance(idealPos) > 15) then
        if idealPos then
            mod:ChasePosition(npc, idealPos, speed, 0.2, false)
            shouldWander = false
        end
    end
  
    if shouldWander then
        if (targDist < slinkingBal.avoidRange or mod:isScare(npc)) and not mod:isConfuse(npc) then
            npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position - targetpos):Resized(speed * 1.33), 0.2)
        else
            local moveTarget = mod:confusePos(npc, npc.Position, 30, false, true)
            npc.Velocity = mod:Lerp(npc.Velocity, (moveTarget - npc.Position):Resized(speed), 0.1)
        end
    end
end

function mod:SlinkingGutsAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)
    local bal = slinkingBal

    if not data.Init then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        npc.SplatColor = mod.Colors.OrganYellow
        data.State = "Appear"
        data.Init = true
    end

    if mod:IsReallyDead(npc.Parent) then
        npc:Kill()
    else
        if data.State == "Appear" then
            npc.Velocity = npc.Velocity * 0.8

            if sprite:IsFinished("Appear") then
                npc.StateFrame = mod:RandomInt(bal.shootTime, rng)
                data.State = "Idle"
            elseif sprite:IsEventTriggered("Sound") then
                data.Grounded = true
                mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc)
                npc.Velocity = npc.Velocity * 0.5
            else
                mod:SpritePlay(sprite, "Appear")
            end
        
        elseif data.State == "Idle" then
            mod:SpritePlay(sprite, "Idle")
            SlinkingGutMove(npc, targetpos, bal.moveSpeed)

            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 and (targetpos:Distance(npc.Position) > bal.minAttackRange or not game:GetRoom():CheckLine(npc.Position, targetpos, 3)) then
                data.State = "Shoot"
            end

        elseif data.State == "Shoot" then
            SlinkingGutMove(npc, targetpos, bal.moveSpeed * 0.33)

            if sprite:IsFinished("Shoot") then
                npc.StateFrame = mod:RandomInt(bal.shootTime, rng)
                data.State = "Idle"
            elseif sprite:IsEventTriggered("Shoot") then
                local vec = (targetpos - npc.Position)/20
                vec = vec:Resized(math.min(bal.maxProjSpeed, vec:Length()))
                local proj = npc:FireProjectilesEx(npc.Position, vec, 0, params1)[1]
                proj:GetData().projType = "customProjectileBehavior"
                proj:GetData().customProjectileBehaviorLJ = {customFunc = SlinkingGutProj, death = SlinkingGutProjDeath}
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, npc.Position, Vector.Zero, npc)
                effect.Color = mod:CloneColor(mod.Colors.OrganYellow, 0.75)
                effect.DepthOffset = 40
                effect.SpriteScale = Vector(1,0.75)
                effect.SpriteOffset = Vector(0,-15)
                effect:Update()
                mod:PlaySound(SoundEffect.SOUND_HEARTOUT, npc, 1.5, 0.7)
            else
                mod:SpritePlay(sprite, "Shoot")
            end
        end

        DoGutTrail(npc)
    end
end

local function GetHulkingPos(npc, targetpos)
    local vec = targetpos - npc.Parent.Position
    local optimalDist = math.max(20, vec:Length()/2)
    local optimalTarget = npc.Parent.Position + vec:Resized(optimalDist)
    if npc.Pathfinder:HasPathToPos(optimalTarget, false) then
        return optimalTarget
    end
    for _, dist in pairs({80,60,40,20}) do
        if dist < vec:Length() or dist <= 20 then
            local target = npc.Parent.Position + vec:Resized(dist)
            if npc.Pathfinder:HasPathToPos(target, false) then
                return target
            end
        end
    end
end

local function HulkingGutMove(npc, targetpos, speed)
    local idealPos = GetHulkingPos(npc, targetpos)
    local shouldWander = true
    local angleDiff = mod:GetAbsoluteAngleDifference(npc.Parent.Position - targetpos, npc.Position - targetpos)
    if angleDiff > 20 or npc.Parent.Position:Distance(npc.Position) > npc.Parent.Position:Distance(targetpos) or (idealPos and npc.Position:Distance(idealPos) > 30) then
        if idealPos then
            mod:ChasePosition(npc, idealPos, speed, 0.2, false)
            shouldWander = false
        end
    end
  
    if shouldWander then
        local moveTarget = mod:confusePos(npc, npc.Position, 30, false, true)
        npc.Velocity = mod:Lerp(npc.Velocity, (moveTarget - npc.Position):Resized(speed), 0.1)
    end
end

function mod:HulkingGutsAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)
    local bal = hulkingBal

    if not data.Init then
        npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        npc.SplatColor = mod.Colors.OrganPurple
        data.State = "Appear"
        data.Init = true
    end

    if mod:IsReallyDead(npc.Parent) then
        npc:Kill()
    else
        if data.State == "Appear" then
            npc.Velocity = npc.Velocity * 0.8

            if sprite:IsFinished("Appear") then
                npc.StateFrame = bal.shootCooldown
                data.State = "Idle"
            elseif sprite:IsEventTriggered("Sound") then
                data.Grounded = true
                mod:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, npc, 1.2, 0.5)
                npc.Velocity = npc.Velocity * 0.5
            else
                mod:SpritePlay(sprite, "Appear")
            end
        
        elseif data.State == "Idle" then
            mod:SpritePlay(sprite, "Idle")
            HulkingGutMove(npc, targetpos, bal.moveSpeed)
            npc.StateFrame = npc.StateFrame - 1

        elseif data.State == "Shoot" then
            HulkingGutMove(npc, targetpos, bal.moveSpeed * 0.33)

            if sprite:IsFinished("Shoot") then
                npc.StateFrame = bal.shootCooldown
                data.State = "Idle"
            elseif sprite:IsEventTriggered("Shoot") then
                --[[local vec = (targetpos - npc.Position):Resized(bal.projSpeed)
                npc:FireProjectiles(npc.Position, vec, ProjectileMode.SPREAD_THREE, params2)
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, npc.Position, Vector.Zero, npc)
                effect.Color = mod:CloneColor(mod.Colors.OrganPurple, 0.75)
                effect.DepthOffset = 40
                effect.SpriteOffset = Vector(0,-10)
                effect:Update()
                mod:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, npc, 1.2, 0.7)]]

                mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc, 0.8, 1)
                for i = 0, bal.projDuration do
                    mod:ScheduleForUpdate(function() 
                        local vec = RandomVector():Resized(bal.projSpeed)
                        local proj = npc:FireProjectilesEx(npc.Position, vec, 0, params2)[1]
                        proj.Scale = mod:RandomInt(8,15) * 0.1
                        proj.FallingSpeed = mod:RandomInt(-40,-15)
                        proj:Update()
                        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 1, npc.Position, Vector(0,mod:RandomInt(-8,-4)):Rotated(mod:RandomInt(-20,20)), npc)
                        effect.DepthOffset = 40
                        effect.PositionOffset = npc:GetNullOffset("EffectPos")
                        effect.Color = mod:CloneColor(mod.Colors.OrganPurple, 0.75)
                        effect:Update()
                        mod:PlaySound(SoundEffect.SOUND_BOSS2_BUBBLES, npc, 0.8, 1)
                    end, i)
                end
            else
                mod:SpritePlay(sprite, "Shoot")
            end
        end

        DoGutTrail(npc)
    end
end

function mod:HulkingGutsHurt(npc, sprite, data, amount, damageFlags, source)
    if npc.StateFrame <= 0 and data.State == "Idle" then
        data.State = "Shoot"
    end
end

local function GetPatheticPos(npc)
    local validPoses1 = {}
    local validPoses2 = {}
    local room = game:GetRoom()
    for i = 0, room:GetGridSize() - 1 do
        if room:GetGridPath(i) <= 900 then
            local gridPos = room:GetGridPosition(i)
            if gridPos:Distance(npc.Parent.Position) <= patheticBal.maxJumpDist and gridPos:Distance(npc.Position) <= patheticBal.maxJumpDist then
                table.insert((npc.Position:Distance(gridPos) >= 60) and validPoses1 or validPoses2, gridPos)
            end
        end
    end
    local rng = npc:GetDropRNG()
    return mod:GetRandomElem(validPoses1, rng) or mod:GetRandomElem(validPoses2, rng) or npc.Position
end

function mod:PatheticGutsAI(npc, sprite, data)
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)
    local bal = patheticBal

    if not data.Init then
        npc.SplatColor = mod.Colors.OrganBlue
        data.Suffix = mod:RandomInt(1,3,rng)
        if npc:HasEntityFlags(EntityFlag.FLAG_APPEAR) then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            npc.StateFrame = mod:RandomInt(bal.jumpTime, rng)
            data.Grounded = true
            data.State = "Idle"
        else
            sprite:Play("Jump0"..data.Suffix, true)
            sprite:SetFrame(16)
            data.State = "Jump"
        end
        data.Init = true
    end

    if mod:IsReallyDead(npc.Parent) then
        npc:Kill()
    else
        if data.State == "Idle" then
            mod:SpritePlay(sprite, "Idle0"..data.Suffix)
            npc.Velocity = npc.Velocity * 0.75

            npc.StateFrame = npc.StateFrame - 1
            if npc.StateFrame <= 0 then
                data.State = "Jump"
            end

        elseif data.State == "Jump" then
            if data.Grounded then
                npc.Velocity = npc.Velocity * 0.75
            end

            if sprite:IsFinished("Jump0"..data.Suffix) then
                npc.StateFrame = mod:RandomInt(bal.jumpTime, rng)
                data.State = "Idle"
            elseif sprite:IsEventTriggered("Jump") then
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                if npc.FrameCount > 1 then
                    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                    local targetPos = GetPatheticPos(npc)
                    npc.Velocity = (targetPos - npc.Position)/17
                end
                mod:PlaySound(SoundEffect.SOUND_SCAMPER, npc, 0.8)
                mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc, 1.2, 0.5)
                data.Grounded = false
            elseif sprite:IsEventTriggered("Land") then
                npc.Velocity = npc.Velocity * 0.5
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
                npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                local angle = mod:RandomInt(0,360,rng)
                local numProjs = mod:RandomInt(bal.projAmount)
                for i = 360/numProjs, 360, 360/numProjs do
                    local vec = Vector.FromAngle(i + angle + mod:RandomInt(-25,25)):Resized(bal.projSpeed)
                    local proj = npc:FireProjectilesEx(npc.Position, vec, 0, params3)[1]
                    proj.Scale = mod:RandomInt(5,12) * 0.1
                    proj.FallingSpeed = mod:RandomInt(-40,-15)
                    proj:Update()
                end
                local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, npc.Position, Vector.Zero, npc)
                splat.Color = npc.SplatColor
                splat:Update()
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, npc.Position, Vector.Zero, npc)
                effect.Color = mod.Colors.OrganBlue
                effect.DepthOffset = -40
                effect.SpriteScale = Vector(1,0.75)
                effect:Update()
                data.Suffix = mod:RandomInt(1,3,rng)
                sprite:SetAnimation("Jump0"..data.Suffix, false)
                mod:PlaySound(SoundEffect.SOUND_GOOATTACH0, npc)
                mod:PlaySound(SoundEffect.SOUND_MEAT_JUMPS, npc, 1.2, 0.5)
                data.Grounded = true
            else
                mod:SpritePlay(sprite, "Jump0"..data.Suffix)
            end
        end

        DoGutTrail(npc)
    end
end