local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:findGridInSquare(npc, centrePos, squareDiff, prioritizeTarget, avoidTarget)
    local room = game:GetRoom()
    centrePos = room:GetGridPosition(room:GetGridIndex(centrePos or nilvector))
    squareDiff = squareDiff or 1

    local isScared = mod:isScare(npc)
    local isConfused = mod:isConfuse(npc)

    if isConfused and squareDiff > 1 then
        squareDiff = squareDiff - 1
    end

    local validSpots = {}
    local closestToTarget
    local furthestToTarget
    for y = squareDiff * -1, squareDiff do
        for x = squareDiff * -1, squareDiff do
            if not (x == 0 and y == 0) then
                local checkedSpot = centrePos + Vector(x * 40, y * 40)
                --Currently fails with spikes :)
                if room:IsPositionInRoom(checkedSpot, 20) and room:GetGridCollisionAtPos(checkedSpot) == GridCollisionClass.COLLISION_NONE then
                    --CHeck if there's a fire on the spot, dumb, why isn't it a grid
                    local fireFree = true
                    local fires = Isaac.FindInRadius(checkedSpot, 1, EntityPartition.ENEMY)
                    for _, fire in pairs(fires) do
                        if fire.Type == 33 then
                            fireFree = false
                            break
                        end
                    end
                    --No fires detected >B)
                    if fireFree then
                        if isScared then
                            local dist = checkedSpot:Distance(npc:GetPlayerTarget().Position)
                            if (not furthestToTarget) or furthestToTarget and dist > furthestToTarget[2] then
                                furthestToTarget = {checkedSpot, dist}
                            end
                        end
                        --Try to not land on a space with target on it
                        if avoidTarget then
                            local dist = checkedSpot:Distance(npc:GetPlayerTarget().Position)
                            if dist > 25 then
                                table.insert(validSpots, checkedSpot)
                            end 
                        else
                            table.insert(validSpots, checkedSpot)
                            --Confusion blocks the check
                            if prioritizeTarget and not (isConfused or isScared) then
                                local dist = checkedSpot:Distance(npc:GetPlayerTarget().Position)
                                if (not closestToTarget) or closestToTarget and dist < closestToTarget[2] then
                                    closestToTarget = {checkedSpot, dist}
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    --Only gets updated if scared, no need for safety
    if furthestToTarget then
        return furthestToTarget[1]
    --Only gets updated if prioritized, no need for safety
    elseif closestToTarget then
        return closestToTarget[1]
    --It better be
    elseif #validSpots > 0 then
        return validSpots[math.random(#validSpots)]
    --Sad
    else
        return centrePos
    end
end

function mod:desirerUpdate(npc)
    local d, sprite = npc:GetData(), npc:GetSprite()
    local r, target = npc:GetDropRNG(), npc:GetPlayerTarget()
    if not d.init then
        d.state = "idle"
        d.init = true
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    if d.state == "idle" then
        mod:spritePlay(sprite, "Down")
        if npc.StateFrame > 5 and r:RandomInt(3) == 0 then
            d.state = "jump"
        end
        npc.Velocity = npc.Velocity * 0.75
    elseif d.state == "jump" then
        if sprite:IsFinished("JumpDown") then
            d.state = "idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Jump") then
            local isTargetClose = target.Position:Distance(npc.Position) < 150
            d.target = mod:findGridInSquare(npc, npc.Position, 2, isTargetClose)
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
            
            if d.target.X < npc.Position.X then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end
        elseif sprite:IsEventTriggered("Land") then
            npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS,1,2,false,1)
            d.target = nil
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        else
            mod:spritePlay(sprite, "JumpDown")
        end
        if d.target then
            local vec = (d.target - npc.Position)
            if vec:Length() > 10 then
                vec = vec:Resized(10)
            end
            npc.Velocity = mod:Lerp(npc.Velocity, vec, 0.1)
        else
            npc.Velocity = npc.Velocity * 0.75
        end
    end
end
function mod:desirerKill(npc)
    for i = 1, 2 do
        local med = Isaac.Spawn(mod.FF.DesirerWaning.ID, mod.FF.DesirerWaning.Var, 0, npc.Position + (RandomVector() * math.random()), nilvector, npc):ToNPC()
        local d = med:GetData()
        d.target = mod:findGridInSquare(med, med.Position, 1, false, true)
        d.state = "freed"
        med.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        med:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        med:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        local sprite = med:GetSprite()
        if d.target.X < med.Position.X then
            sprite.FlipX = true
        else
            sprite.FlipX = false
        end
        med:Update()
    end
end

function mod:desirerMedUpdate(npc)
    local d, sprite = npc:GetData(), npc:GetSprite()
    local r, target = npc:GetDropRNG(), npc:GetPlayerTarget()
    if not d.init then
        d.state = d.state or "idle"
        d.init = true
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    if d.state == "idle" then
        mod:spritePlay(sprite, "Down")
        if r:RandomInt(3) == 0 then
            d.state = "jump"
        end
        npc.Velocity = npc.Velocity * 0.75
    elseif d.state == "jump" then
        if sprite:IsFinished("JumpDown") then
            d.state = "idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Jump") then
            local isTargetClose = target.Position:Distance(npc.Position) < 150
            d.target = mod:findGridInSquare(npc, npc.Position, 2, isTargetClose)
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
            
            if d.target.X < npc.Position.X then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end
        elseif sprite:IsEventTriggered("Land") then
            npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS,1,2,false,1.25)
            d.target = nil
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        else
            mod:spritePlay(sprite, "JumpDown")
        end
        if d.target then
            local vec = (d.target - npc.Position)
            if vec:Length() > 10 then
                vec = vec:Resized(10)
            end
            npc.Velocity = mod:Lerp(npc.Velocity, vec, 0.1)
        else
            npc.Velocity = npc.Velocity * 0.75
        end
    elseif d.state == "freed" then
        if sprite:IsFinished("Freed") then
            d.state = "idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Land") then
            npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS,1,2,false,1.25)
            d.target = nil
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        else
            mod:spritePlay(sprite, "Freed")
        end
        if d.target then
            local vec = (d.target - npc.Position)
            if vec:Length() > 10 then
                vec = vec:Resized(10)
            end
            npc.Velocity = mod:Lerp(npc.Velocity, vec, 0.2)
        else
            npc.Velocity = npc.Velocity * 0.75
        end
    end
end
function mod:desirerMedKill(npc)
    for i = 1, 2 do
        local med = Isaac.Spawn(mod.FF.DesirerDiminished.ID, mod.FF.DesirerDiminished.Var, 0, npc.Position + (RandomVector() * math.random()), nilvector, npc):ToNPC()
        local d = med:GetData()
        d.target = mod:findGridInSquare(med, med.Position, 1, false, true)
        d.state = "freed"
        med.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        med:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        med:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        local sprite = med:GetSprite()
        if d.target.X < med.Position.X then
            sprite.FlipX = true
        else
            sprite.FlipX = false
        end
        med:Update()
    end
end

function mod:desirerSmallUpdate(npc)
    local d, sprite = npc:GetData(), npc:GetSprite()
    local r, target = npc:GetDropRNG(), npc:GetPlayerTarget()
    if not d.init then
        d.state = d.state or "idle"
        d.init = true
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    if d.state == "idle" then
        mod:spritePlay(sprite, "Down")
        if r:RandomInt(2) == 0 or npc.StateFrame > 1 then
            d.state = "jump"
        end
        npc.Velocity = npc.Velocity * 0.75
    elseif d.state == "jump" then
        if sprite:IsFinished("JumpFAST") then
            d.state = "idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Jump") then
            local isTargetClose = target.Position:Distance(npc.Position) < 50
            d.target = mod:findGridInSquare(npc, npc.Position, 2, isTargetClose)
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
            
            if d.target.X < npc.Position.X then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end
        elseif sprite:IsEventTriggered("Land") then
            npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS,0.5,2,false,1.4 + (math.random() * 0.2))
            d.target = nil
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        else
            mod:spritePlay(sprite, "JumpFAST")
        end
        if d.target then
            local vec = (d.target - npc.Position)
            if vec:Length() > 12 then
                vec = vec:Resized(12)
            end
            npc.Velocity = mod:Lerp(npc.Velocity, vec, 0.3)
        else
            npc.Velocity = npc.Velocity * 0.75
        end
    elseif d.state == "freed" then
        if sprite:IsFinished("Freed") then
            d.state = "idle"
            npc.StateFrame = 0
        elseif sprite:IsEventTriggered("Land") then
            npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS,0.5,2,false,1.4 + (math.random() * 0.2))
            d.target = nil
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
        else
            mod:spritePlay(sprite, "Freed")
        end
        if d.target then
            local vec = (d.target - npc.Position)
            if vec:Length() > 10 then
                vec = vec:Resized(10)
            end
            npc.Velocity = mod:Lerp(npc.Velocity, vec, 0.2)
        else
            npc.Velocity = npc.Velocity * 0.75
        end
    end
end

function mod:seducerUpdate(npc)
    local d, sprite = npc:GetData(), npc:GetSprite()
    local r, target = npc:GetDropRNG(), npc:GetPlayerTarget()
    if not d.init then
        d.state = "idle"
        d.init = true
    else
        npc.StateFrame = npc.StateFrame + 1
    end

    if d.state == "idle" then
        if d.sliding then
            mod:spritePlay(sprite, "DownSlide")
        else
            if sprite:IsFinished("SlideStop") then
                mod:spritePlay(sprite, "Down")
            elseif not sprite:IsPlaying("SlideStop") then
                mod:spritePlay(sprite, "Down")
            end
        end
        if npc.StateFrame > 5 and not d.sliding and r:RandomInt(3) == 1 then
            d.state = "jump"
        end
    elseif d.state == "jump" then
        if sprite:IsFinished("JumpDown") then
            d.state = "idle"
        elseif sprite:IsEventTriggered("Jump") then
            local isTargetClose = target.Position:Distance(npc.Position) < 150
            d.target = mod:findGridInSquare(npc, npc.Position, 2, isTargetClose)
            
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            npc:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
            
            if d.target.X < npc.Position.X then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end
        elseif sprite:IsEventTriggered("Land") then
            npc.StateFrame = -10
            npc:PlaySound(SoundEffect.SOUND_MEAT_IMPACTS,1,2,false,1)
            d.target = nil
            npc.Velocity = mod:Lerp(npc.Velocity, d.slideVec:Resized(10), 0.1)
            npc.Velocity = d.slideVec:Resized(npc.Velocity:Length())
            d.sliding = d.slideVec
            d.slideVec = nil
            npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            npc:ClearEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, npc.Position, nilvector, npc):ToEffect();
            creep:SetTimeout(20)
			creep:Update()
        else
            mod:spritePlay(sprite, "JumpDown")
        end
        if d.target then
            local vec = (d.target - npc.Position)
            d.slideVec = d.slideVec or vec
            if vec:Length() > 10 then
                vec = vec:Resized(10)
            end
            npc.Velocity = mod:Lerp(npc.Velocity, vec, 0.1)
        end
    end

    if d.sliding then
        npc.StateFrame = math.min(npc.StateFrame, 0)
        npc.Velocity = mod:Lerp(npc.Velocity, npc.Velocity:Resized(10),0.1)
        if npc.Velocity.X < 0 then
            sprite.FlipX = true
        else
            sprite.FlipX = false
        end

        if npc:CollidesWithGrid() then
            d.sliding = nil
            npc.Velocity = npc.Velocity * 0.75
            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, npc.Position, nilvector, npc):ToEffect();
            creep:SetTimeout(20)
			creep:Update()
            mod:spritePlay(sprite, "SlideStop")
            d.state = "idle"
        else
            if npc.FrameCount % 2 == 0 then
                local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, npc.Position, nilvector, npc):ToEffect();
                creep.Scale = 0.5
                creep:SetTimeout(15)
                creep:Update()
            end
        end
    elseif not d.target then
        npc.Velocity = npc.Velocity * 0.75
    end
end

function mod:seducerCollision(npc, collider)
    if collider.Type ~= npc.Type and collider.Variant ~= npc.Variant
    and collider.Type ~= 2 
    then
        local d = npc:GetData()
        if d.sliding then
            d.sliding = nil
            npc.Velocity = npc.Velocity * 0.75
            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, npc.Position, nilvector, npc):ToEffect();
            creep:SetTimeout(20)
            creep:Update()
            mod:spritePlay(npc:GetSprite(), "SlideStop")
            d.state = "idle"
        end
    end
end