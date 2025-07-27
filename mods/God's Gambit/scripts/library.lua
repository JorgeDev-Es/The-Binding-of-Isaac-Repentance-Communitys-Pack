local mod = GodsGambit
local game = Game()
local sfx = SFXManager()

mod.RNG = RNG()

function mod:RandomInt(min, max, rand)
    if type(min) == "table" then
        rand = max
        max = min[2]
        min = min[1]
    end
    if not (max or min) then
        rand = rand or mod.RNG
        return rand:RandomFloat()
    elseif not max then
        rand = max
        max = min
        min = 0
    end  
    if min > max then 
        local temp = min
        min = max
        max = temp
    end
    rand = rand or mod.RNG
    return min + (rand:RandomInt(max - min + 1))
end

function mod:RandomAngle(rng)
    return mod:RandomInt(0,359,rng)
end

function mod:RandomInRange(i, entrng)
    return mod:RandomInt(-i, i, entrng)
end

function mod:GetRandomElem(table, rand)
    if table and #table > 0 then
		local index = mod:RandomInt(1, #table, rand)
        return table[index], index
    end
end

function mod:Lerp(first, second, percent, smoothIn, smoothOut)
    if smoothIn then
        percent = percent ^ smoothIn
    end

    if smoothOut then
        percent = 1 - percent
        percent = percent ^ smoothOut
        percent = 1 - percent
    end

	return (first + (second - first)*percent)
end

function mod:Shuffle(tbl)
	for i = #tbl, 2, -1 do
        local j = mod:RandomInt(1, i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

function mod:Sway(back, forth, interval, smoothIn, smoothOut, frameCnt)
    local time = (frameCnt or game:GetFrameCount()) % interval
    local halfInterval = interval / 2
    if time < halfInterval then
        return mod:Lerp(back, forth, time / halfInterval, smoothIn, smoothOut)
    else
        return mod:Lerp(forth, back, (time - halfInterval) / halfInterval, smoothIn, smoothOut)
    end
end

function mod:SpritePlay(sprite, anim)
	if not sprite:IsPlaying(anim) then
		sprite:Play(anim)
	end
end

function mod:spritePlay(sprite, anim) --Its capatilized like this in FF so im used to this
    mod:SpritePlay(sprite, anim)
end

function mod:SpriteOverlayPlay(sprite, anim)
	if not sprite:IsOverlayPlaying(anim) then
		sprite:PlayOverlay(anim)
	end
end

function mod:SpriteSetAnimation(sprite, anim, reset)
    if reset == nil then reset = false end
    if not sprite:IsPlaying() then
        sprite:Play(anim)
    else
        sprite:SetAnimation(anim, reset)
    end
end

function mod:FlipSprite(sprite, pos1, pos2)
    if pos1.X > pos2.X then
        sprite.FlipX = true
    else
        sprite.FlipX = false
    end
end

function mod:SnapVector(angle, snapAngle)
	local snapped = math.floor(((angle:GetAngleDegrees() + snapAngle/2) / snapAngle)) * snapAngle
	local snappedDirection = angle:Rotated(snapped - angle:GetAngleDegrees())
	return snappedDirection
end

function mod:GetAngleDegreesButGood(vec)
    local angle
    if type(vec) == "number" then angle = vec
    else angle = (vec):GetAngleDegrees() end
    
    if angle < 0 then
        return 360 + angle
    else
        return angle
    end
end

--From Dead
function mod:GetAngleDifference(a1, a2)
    a1 = mod:GetAngleDegreesButGood(a1)
    a2 = mod:GetAngleDegreesButGood(a2)
    local sub = a1 - a2
    return (sub + 180) % 360 - 180
end

function mod:NormalizeDegrees(a)
    return -((-a + 180) % 360) + 180
end

function mod:NormalizeDegreesTo360(a)
    return a % 360
end

function mod:GetAbsoluteAngleDifference(vec1, vec2)
    local val = math.abs(mod:NormalizeDegrees(mod:NormalizeDegrees(mod:GetAngleDegreesButGood(vec1)) - mod:NormalizeDegrees(mod:GetAngleDegreesButGood(vec2))))
    return val
end

--Some of FF's Library for handling status on enemies
function mod:isFriend(npc)
	return npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
end
function mod:isCharm(npc)
	return npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM)
end
function mod:isScare(npc)
	return npc:HasEntityFlags(EntityFlag.FLAG_FEAR | EntityFlag.FLAG_SHRINK)
end
function mod:isConfuse(npc)
	return npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION)
end
function mod:isScareOrConfuse(npc)
	return npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION | EntityFlag.FLAG_FEAR | EntityFlag.FLAG_SHRINK)
end
function mod:isBaited(npc)
	return npc:HasEntityFlags(EntityFlag.FLAG_BAITED)
end

function mod:makeProjectileConsiderFriend(npc, projectile)
	if npc then
		if mod:isFriend(npc) then
			projectile:AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES)
		elseif mod:isCharm(npc) then
			projectile:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES)
		end
	end
end

function mod:reverseIfFear(npc, vec, multiplier)
	multiplier = multiplier or 1
	if mod:isScare(npc) then
		vec = vec * -1 * multiplier
	end
	return vec
end

function mod:confusePos(npc, pos, frameCountCheck, isVec, alwaysConfuse)
	frameCountCheck = frameCountCheck or 10
	local d = npc:GetData()
	if mod:isConfuse(npc) or alwaysConfuse then
		if isVec then
			if npc.FrameCount % frameCountCheck == 0 then
				d.confusedEffectPos = nil
			end
			d.confusedEffectPos = d.confusedEffectPos or RandomVector()*math.random(2,5)
			return d.confusedEffectPos
		else
			if npc.FrameCount % frameCountCheck == 0 then
				d.confusedEffectPos = nil
			end
			if d.confusedEffectPos and npc.Position:Distance(d.confusedEffectPos) < 2 then
				d.confusedEffectPos = npc.Position
			end
			d.confusedEffectPos = d.confusedEffectPos or npc.Position + RandomVector()*math.random(5,15)
			return d.confusedEffectPos
		end
	else
		d.confusedEffectPos = nil
		return pos
	end
end

function mod:rotateIfConfuse(npc, vec)
	if mod:isConfuse(npc) then
		vec = vec:Rotated(mod:RandomInt(360))
	end
	return vec
end

function mod:UnscareWhenOutOfRoom(npc, timeCheck)
	local d = npc:GetData()
	timeCheck = timeCheck or 10
	if mod:isScare(npc) then
		local room = Game():GetRoom()
		if not room:IsPositionInRoom(npc.Position, 0) then
			d.outOfRoomUncareTimer = d.outOfRoomUncareTimer or 0
			d.outOfRoomUncareTimer = d.outOfRoomUncareTimer + 1
			if d.outOfRoomUncareTimer > timeCheck then
				npc:ClearEntityFlags(EntityFlag.FLAG_FEAR)
				npc.Color = Color.Default
			end
		else
			d.outOfRoomUncareTimer = 0
		end
	else
		d.outOfRoomUncareTimer = 0
	end
end

function mod:GetPlayerTarget(npc)
    if npc.FrameCount % 30 == 0 or not (npc.Target and npc.Target:Exists()) then
        npc.Target = npc:GetPlayerTarget()
    end
    return npc.Target
end

function mod:GetPlayerTargetPos(npc)
    return mod:confusePos(npc, mod:GetPlayerTarget(npc).Position)
end

function mod:PlaySound(soundID, npc, pitch, volume, isLooping, frameDelay, pan)
    pitch = pitch or 1
    volume = volume or 1
    frameDelay = frameDelay or 2
    pan = pan or 0
    if npc and npc:ToNPC() then
        npc:ToNPC():PlaySound(soundID, volume, frameDelay, isLooping, pitch)   
    else
        sfx:Play(soundID, volume, frameDelay, isLooping, pitch, pan) 
    end
end

function mod:SnapToDiagonal(angle)
    return (90 * math.floor((angle + 45) / 90 + 0.5) - (angle + 45))
end

function mod:SnapVecToDiagonal(vec)
    return vec:Rotated(mod:SnapToDiagonal(mod:GetAngleDegreesButGood(vec)))
end

function mod:MoveDiagonally(npc, speed, lerpVal, fallbackVec) --Going to write my own version of this
    local vec = mod:SnapVecToDiagonal(npc.Velocity)
    if npc.Velocity:Length() < 0.1 then
        vec = fallbackVec or Vector(1,1):Rotated(90 * mod:RandomInt(0,3))
    end
    npc.Velocity = mod:Lerp(npc.Velocity, vec:Resized(speed or 3), lerpVal or 0.3)
    return vec
end

function mod:AngleLimitVector(vec, targVec, angleLimit)
    local angleDiff = mod:GetAngleDifference(vec, targVec)
    if math.abs(angleDiff) > angleLimit then
        return vec:Rotated((math.abs(angleDiff)/angleDiff) * -angleLimit)
    else
        return targVec
    end
end

local DelayedFuncs = {}
local function RunUpdates(tab)
	for i = #tab, 1, -1 do
		local f = tab[i]
		f.Delay = f.Delay - 1
		if f.Delay <= 0 then
			f.Func()
			table.remove(tab, i)
		end
	end
end

function mod:ScheduleForUpdate(foo, delay, callback, noCancelOnNewRoom)
	callback = callback or ModCallbacks.MC_POST_UPDATE
	if not DelayedFuncs[callback] then
		DelayedFuncs[callback] = {}
		mod:AddCallback(callback, function()
			RunUpdates(DelayedFuncs[callback])
		end)
	end

	table.insert(DelayedFuncs[callback], {Func = foo, Delay = delay or 0, NoCancel = noCancelOnNewRoom})
end

mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.IMPORTANT, function()
	for callback, tab in pairs(DelayedFuncs) do
		for i = #tab, 1, -1 do
			local f = tab[i]
			if not f.NoCancel then
				table.remove(tab, i)
			end
		end
	end
end)

function mod:GetEntityCount(id,var,sub,spawner,ignoreFriendly)
    var = var or -1
    sub = sub or -1
    if ignoreFriendly then
        local count = 0
        for _, ent in pairs(Isaac.FindByType(id, var, sub)) do
            if not mod:isFriend(ent) then
                count = count + 1
            end
        end
        return count
    else
        return Isaac.CountEntities(spawner,id,var,sub)
    end
end

function mod:FindSafeSpawnSpot(position, radius, fallbackRadius, fallbackToPos, avoidPlayer, avoidSelf, avoidGridPath)
    radius = radius or 9999
    local room = game:GetRoom()
    local pathfinder = Isaac.Spawn(960,0,0,position,Vector.Zero,nil):ToNPC() --Spawns a Horf, teleports it around for pathfinding checks. Shopkeeper didnt work for some reason. I hate this.
    pathfinder:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    pathfinder:AddEntityFlags(EntityFlag.FLAG_NO_QUERY)
    pathfinder.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    pathfinder.Size = 8
    pathfinder.Visible = false
    local valids1 = {}
    local valids2 = {}

    for i = 0, room:GetGridSize() do
        local gridpos = room:GetGridPosition(i)
        if gridpos:Distance(position) > 20 and room:GetGridCollision(i) <= GridCollisionClass.COLLISION_NONE then
            pathfinder.Position = gridpos
            if not mod:AmISoftlocked(pathfinder, true) then
                if gridpos:Distance(position) <= radius 
                and not ((avoidPlayer and game:GetNearestPlayer(gridpos).Position:Distance(gridpos) <= avoidPlayer) 
                or (avoidSelf and gridpos:Distance(position) <= avoidSelf)
                or (avoidGridPath and room:GetGridPath(i) > 900)) then
                    table.insert(valids1, gridpos)
                elseif fallbackRadius and gridpos:Distance(position) <= fallbackRadius then
                    table.insert(valids2, gridpos)
                end
            end
        end
    end
    pathfinder:Remove()

    local spawnpos = mod:GetRandomElem(valids1)
    if fallbackRadius and not spawnpos then
        spawnpos = mod:GetRandomElem(valids2)
	end
	if fallbackToPos and not spawnpos then
		spawnpos = position
	end
    return spawnpos
end

function mod:AmISoftlocked(npc, allowLineOfSight)
    local room = game:GetRoom()
    npc = npc:ToNPC()
    for i = 0, game:GetNumPlayers() do
        local playerpos = game:GetPlayer(i).Position
        if npc.Pathfinder:HasPathToPos(playerpos) or (allowLineOfSight and room:CheckLine(npc.Position, playerpos, 3, 0, false, false)) then
            return false
        end
    end
    return true
end

function mod:GetAllPlayers()
	local players = {}
	for i = 1, game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i)
		if player:Exists() then
			table.insert(players, player)
		end
	end
	return players
end

function mod:isLeavingStatusCorpse(entity)
	return entity:HasMortalDamage() and (entity:HasEntityFlags(EntityFlag.FLAG_ICE) or entity:GetData().FFApplyMartyrOnDeath == true)
end

function mod:isStatusCorpse(entity)
	return entity:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN) or entity:GetData().FFMartyrDuration ~= nil
end

function mod:IsReallyDead(npc)
    if npc then 
        if npc:ToNPC() ~= nil then
            npc = npc:ToNPC()
            return (npc:IsDead() or npc.State == 18 or mod:isLeavingStatusCorpse(npc) or mod:isStatusCorpse(npc))
        else
            return not npc:Exists()
        end
    end
    return true
end

function mod:GetGridsInRadius(pos, radius)
    local room = game:GetRoom()
    local grids = {}
    for i = 0, room:GetGridSize() - 1 do
        local grid = room:GetGridEntity(i)
        if grid and pos:Distance(grid.Position) < radius then
            table.insert(grids, grid)
        end
    end
    return grids
end

function mod:CloneProjectile(proj, vel, pos, scale)
    pos = pos or proj.Position
    scale = scale or 1
    local p = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, proj.Variant, proj.SubType, pos, vel, proj.SpawnerEntity):ToProjectile()
    p.ProjectileFlags = proj.ProjectileFlags
    p.Color = proj.Color
    p.Scale = scale
    p:Update()
    return p
end

function mod:GetNewPosGridAligned(pos, ignoreRocks, gridLimit)
	local room = game:GetRoom()
	local positions = {}
    pos = room:GetGridPosition(room:GetGridIndex(pos))
    gridLimit = gridLimit or 20 

	for i = 0, 270, 90 do
        local gridValid = true
        local vec = Vector(0, 40):Rotated(i)
		local dist = 1
    
		while gridValid and dist < gridLimit do
			local newPos = pos + (vec * dist)
            local newIndex = room:GetGridIndex(newPos)
			if room:GetGridPath(newIndex) > 900 and not ignoreRocks then
				gridValid = false
			elseif ignoreRocks and room:GetGridCollision(newIndex) >= GridCollisionClass.COLLISION_WALL then
				gridValid = false
			else
				table.insert(positions, newPos)
				dist = dist + 1
			end
		end
	end

	if #positions > 0 then
		return mod:GetRandomElem(positions)
	else
		return pos, true
	end
end

function mod:WanderGridAligned(npc, data, speed, lerpVal)
    lerpVal = lerpVal or 0.3

    if data.GridAlignedHome and not (data.LastWanderFrame and game:GetFrameCount() - data.LastWanderFrame > 10) then
        local vel 
        data.LastWanderFrame = game:GetFrameCount()
        if npc.Position:Distance(data.GridAlignedHome) < 15 
        or (mod:isScareOrConfuse(npc) and npc.StateFrame % 10 == 0)
        or not game:GetRoom():CheckLine(npc.Position,data.GridAlignedHome,0,500,false,false) then
            data.GridAlignedHome = nil
        else
            vel = (data.GridAlignedHome - npc.Position):Resized(speed)
        end

        if vel then
            npc.Velocity = mod:Lerp(npc.Velocity, vel, lerpVal)
            return true, false
        else
            npc.Velocity = npc.Velocity * lerpVal
        end
    else
        data.LastWanderFrame = game:GetFrameCount()
        data.GridAlignedHome = mod:GetNewPosGridAligned(npc.Position, false, nil)
        return true, true
    end
end

function mod:IsAlignedWithPos(pos1, pos2, margin, lineCheck, maxRange, behindVec)
    margin = margin or 20
    if math.abs(pos2.X - pos1.X) <= margin or math.abs(pos2.Y - pos1.Y) <= margin then
        if lineCheck and not game:GetRoom():CheckLine(pos1,pos2,lineCheck,0,false,false) then
            return false
        end

        local vec = mod:SnapVector(pos2 - pos1, 90)
        if maxRange and vec:Length() > maxRange then
            return false
        end
        if behindVec and math.abs(mod:GetAngleDifference(vec, behindVec)) < 30 then
            return false
        end
        return vec
    end
    return false
end

function mod:GetMoveString(vec, doFlipX)
    if math.abs(vec.Y) > math.abs(vec.X) then
        if vec.Y > 0 then
            return "Down", false
        else
            return "Up", false
        end
    else
        if vec.X > 0 then
            if doFlipX then
                return "Hori", false
            else
                return "Right", false
            end
        else
            if doFlipX then
                return "Hori", true
            else
                return "Left", false
            end
        end
    end
end

function mod:MoveStringToVec(suffix, flipX)
    if suffix == "Down" then
        return Vector(0,1)
    elseif suffix == "Up" then
        return Vector(0,-1)
    elseif suffix == "Hori" then
        return (flipX and Vector(-1,0) or Vector(1,0))
    elseif suffix == "Right" then
        return Vector(1,0)
    elseif suffix == "Left" then
        return Vector(-1,0)
    else
        return Vector(0,0)
    end
end

function mod:AnimWalkFrame(npc, sprite, horianim, vertanim, doFlip, idleAnim, idleThreshold, overrideVelocity)
    local velocity = overrideVelocity or npc.Velocity
    idleThreshold = idleThreshold or 0.1
    if velocity:Length() < idleThreshold then
        if idleAnim then
            mod:spritePlay(sprite, idleAnim)
            return idleAnim
        elseif type(vertanim) == "table" then
            sprite:SetFrame(vertanim[1], 0)
            return vertanim[1]
        else
            sprite:SetFrame(vertanim, 0)
            return vertanim
        end
    else
        local anim
        if math.abs(velocity.X) > math.abs(velocity.Y) then
            if type(horianim) == "table" and not doFlip then
                if velocity.X < 0 then
                    anim = horianim[1]
                else
                    anim = horianim[2]
                end
            else
                anim = horianim
            end
        else
            if type(vertanim) == "table" then
                if velocity.Y > 0 then
                    anim = vertanim[1]
                else
                    anim = vertanim[2]
                end
            else
                anim = vertanim
            end
        end
        if doFlip then 
            if velocity.X < 0 then
                sprite.FlipX = true
            else
                sprite.FlipX = false
            end
        end
        if not sprite:IsPlaying() then
            sprite:Play(anim)
        else
            sprite:SetAnimation(anim, false)
        end
        return anim
    end
end

function mod:ChasePlayer(npc, speed, lerpval, setGridPath)
    mod:ChasePosition(npc, mod:GetPlayerTargetPos(npc), speed, lerpval, setGridPath)
end

function mod:ChasePosition(npc, targetpos, speed, lerpval, setGridPath)
    lerpval = lerpval or 0.25
    if setGridPath == nil then setGridPath = true end
    local pathSpeed
    if type(speed) == "table" then
        pathSpeed = speed[2]
        speed = speed[1]
    else
        pathSpeed = (speed * 0.1) + 0.2
    end
    local room = game:GetRoom()

    
    if mod:isScare(npc) then
        local playerPos = game:GetNearestPlayer(npc.Position).Position
        npc.Velocity = mod:Lerp(npc.Velocity, (npc.Position - playerPos):Resized(speed), lerpval)
    elseif room:CheckLine(npc.Position,targetpos,0,1,false,false) then
        npc.Velocity = mod:Lerp(npc.Velocity, (targetpos - npc.Position):Resized(speed), lerpval)
    elseif npc.Pathfinder:HasPathToPos(targetpos) then
        npc.Pathfinder:FindGridPath(targetpos, pathSpeed, 900, true)
    else
        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, lerpval)
    end

    if setGridPath then
        mod:QuickSetEntityGridPath(npc)
    end
end

function mod:QuickSetGridPath(pos, value)
    value = value or 900
	local room = game:GetRoom()
	local index = room:GetGridIndex(pos)
    local gridPath = room:GetGridPath(index)
	if gridPath <= value or gridPath <= 900 then
		room:SetGridPath(index, value)
	end
end

function mod:QuickSetEntityGridPath(entity, value, ignoreColl)
    if entity.EntityCollisionClass > EntityCollisionClass.ENTCOLL_PLAYEROBJECTS or ignoreColl then
        mod:QuickSetGridPath(entity.Position, value)
    end
end

function mod:CloneColor(color, alpha)
    local new = Color.Lerp(color, Color.Default, 0)
    new.A = alpha or 1
    return new
end


function mod:FadeIn(ent, length)
    length = length or 4
    local color = ent.Color
    ent:SetColor(mod:CloneColor(color,0),length,1,true,true)
end

function mod:FadeOut(ent, length)
    length = length or 12
    local color = ent.Color
    ent.Color = mod:CloneColor(color,0)
    ent:SetColor(color,length,1,true,true)
end

function mod:FadeRemove(ent, length)
    if not ent:GetData().DoingFadeRemoval then
        mod:FadeOut(ent, length)
        mod:ScheduleForUpdate(function() ent:Remove() end, length)
        ent:GetData().DoingFadeRemoval = length
        return true
    end
end

function mod:HasDamageFlag(damageFlags, damageFlag)
    return damageFlags & damageFlag ~= 0
end

function mod:GetNearestThing(position, type, variant, subtype, filter, me)
    local nearest 
    local nearDist = 99999
    variant = variant or -1
    subtype = subtype or -1
    for _, entity in ipairs(Isaac.FindByType(type, variant, subtype, false, false)) do
        if (filter == nil or filter(position, entity)) and (me == nil or me.InitSeed ~= entity.InitSeed) then
            if entity.Position:Distance(position) < nearDist then
                nearDist = entity.Position:Distance(position)
                nearest = entity
            end
        end
    end
    return nearest
end

function mod:IsRoomActive()
    local room = game:GetRoom()
    return (room:IsAmbushActive() or not room:IsClear())
end

function mod:IsPlayerDamage(source)
    if source.Entity ~= nil then
        return (source.Entity.Type == 1 or source.Entity.Type == 3 or source.Entity.SpawnerType == 1 or source.Entity.SpawnerType == 3)
    else
        return false
    end
end

function mod:IsNormalRender()
    local isPaused = game:IsPaused()
    local isReflected = (game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT)
    return (isPaused or isReflected) == false
end

function mod:FindRandomValidPathPosition(npc, avoidplayer, minRange, maxRange, ignorepoops, requireLoS)
	local validPositions = {}
	local validPositions2 = {}
	local room = game:GetRoom()
	ignorepoops = ignorepoops or false

	for i = 0, room:GetGridSize() - 1 do
		local gridpos = room:GetGridPosition(i)
		local farfromplayer = true
		if npc.Pathfinder:HasPathToPos(gridpos, ignorepoops) and room:GetGridPath(i) <= 900 then
			if not (avoidPlayer and game:GetNearestPlayer(gridpos).Position:Distance(gridpos) < avoidPlayer) or (requireLoS and not room:CheckLine(npc.Position, gridpos, requireLoS)) then
                local dist = npc.Position:Distance(gridpos)
                if (minRange == nil or dist >= minRange) and (maxRange == nil or dist >= maxRange) then
                    table.insert(validPositions, gridpos)
                else
                    table.insert(validPositions2, gridpos)
                end
            else
                table.insert(validPositions2, gridpos)
			end
		end
	end
	return (mod:GetRandomElem(validPositions) or mod:GetRandomElem(validPositions2) or npc.Position)
end

function mod:MinimizeVector(vec, len)
    return vec:Resized(math.min(vec:Length(), len))
end

function mod:WanderAbout(npc, data, speed, lerpVal, minIdleTime, maxIdleTime, avoidPlayer, minRange, maxRange, requireLoS)
    lerpVal = lerpVal or 0.3
    minIdleTime = minIdleTime or 15
    maxIdleTime = maxIdleTime or 45

    local room = game:GetRoom()
    local rng = npc:GetDropRNG()
    local targetpos = mod:confusePos(npc, npc:GetPlayerTarget().Position)

    if data.IdleTime then
        npc.Velocity = npc.Velocity * (1 - lerpVal)
        data.IdleTime = data.IdleTime - 1
        if data.IdleTime <= 0 then
            data.IdleTime = nil
        end
        return false, false, Vector.Zero
    
    elseif data.WalkPos and not (data.LastWanderFrame and game:GetFrameCount() - data.LastWanderFrame > 10) then
        local vel 
        data.LastWanderFrame = game:GetFrameCount()
        if mod:isScare(npc) or (avoidPlayer and targetpos:Distance(npc.Position) <= avoidPlayer and room:CheckLine(npc.Position,targetpos,0,1,false,false)) then
            vel = mod:MinimizeVector(npc.Position - targetpos, speed)
            data.WalkPos = nil
        elseif room:CheckLine(npc.Position,data.WalkPos,0,1,false,false) or npc.GridCollisionClass <= EntityGridCollisionClass.GRIDCOLL_WALLS then
            vel = mod:MinimizeVector(data.WalkPos - npc.Position, speed)
        elseif npc.Pathfinder:HasPathToPos(data.WalkPos, false) then
            npc.Pathfinder:FindGridPath(data.WalkPos, (speed * 0.1) + 0.2, 900, true)
        else
            data.WalkPos = nil
        end

        if vel then
            npc.Velocity = mod:Lerp(npc.Velocity, vel, lerpVal)
        end

        if data.WalkPos and npc.Position:Distance(data.WalkPos) <= speed + 5 and npc.Velocity:Length() <= 1 then
            data.IdleTime = mod:RandomInt(minIdleTime,maxIdleTime,rng)
            data.WalkPos = nil
            return false, false, Vector.Zero
        else
            return true, false, vel or Vector.Zero
        end
    else
        data.LastWanderFrame = game:GetFrameCount()
        data.WalkPos = mod:FindRandomValidPathPosition(npc, avoidPlayer, minRange, maxRange, false, requireLoS)
        return false, true, Vector.Zero
    end
end

function mod:WanderAboutAir(npc, data, speed, lerpVal, minIdleTime, maxIdleTime, avoidPlayer, minRange, maxRange)
    lerpVal = lerpVal or 0.3
    minIdleTime = minIdleTime or 15
    maxIdleTime = maxIdleTime or 45

    local room = game:GetRoom()
    local rng = npc:GetDropRNG()
    local targetpos = mod:GetPlayerTargetPos(npc)

    if data.IdleTime then
        npc.Velocity = npc.Velocity * (1 - lerpVal)
        data.IdleTime = data.IdleTime - 1
        if data.IdleTime <= 0 then
            data.IdleTime = nil
        end
    
    elseif data.WalkPos and not (data.LastWanderFrame and game:GetFrameCount() - data.LastWanderFrame > 10) then
        local vel 
        local targDist = targetpos:Distance(npc.Position)
        data.LastWanderFrame = game:GetFrameCount()
        if (mod:isScare(npc) and targDist < 200) or (avoidPlayer and targDist <= avoidPlayer) then
            vel = mod:MinimizeVector(npc.Position - targetpos, speed)
            data.WalkPos = nil
        else
            vel = mod:MinimizeVector(data.WalkPos - npc.Position, speed)
        end

        if vel then
            npc.Velocity = mod:Lerp(npc.Velocity, vel, lerpVal)
        end

        if data.WalkPos and npc.Position:Distance(data.WalkPos) <= speed + 5 --[[and npc.Velocity:Length() <= 1]] then
            data.IdleTime = mod:RandomInt(minIdleTime,maxIdleTime,rng)
            data.WalkPos = nil
        else
            return true, false, vel
        end
    else
        data.LastWanderFrame = game:GetFrameCount()
        data.WalkPos = mod:FindRandomValidPathPositionAir(npc, avoidPlayer, minRange, maxRange)
        return true, true
    end
end

function mod:FindRandomValidPathPositionAir(npc, avoidPlayer, minRange, maxRange)
	local validPositions = {}
	local validPositions2 = {}
	local room = game:GetRoom()
    local fires = Isaac.FindByType(EntityType.ENTITY_FIREPLACE)

	for i = 0, room:GetGridSize() - 1 do
		local gridpos = room:GetGridPosition(i)
		local farfromplayer = true
		if room:GetGridCollision(i) <= GridCollisionClass.COLLISION_PIT and mod:IsPosSafeForFlying(gridpos, fires) then
			if not ((avoidPlayer and game:GetNearestPlayer(gridpos).Position:Distance(gridpos) < avoidPlayer)) then
                local dist = npc.Position:Distance(gridpos)
                if (minRange == nil or dist >= minRange) and (maxRange == nil or dist <= maxRange) then
                    table.insert(validPositions, gridpos)
                else
                    table.insert(validPositions2, gridpos)
                end
            else
                table.insert(validPositions2, gridpos)
			end
		end
	end
	return (mod:GetRandomElem(validPositions) or mod:GetRandomElem(validPositions2) or npc.Position)
end

function mod:IsPosSafeForFlying(pos, fires)
    fires = fires or Isaac.FindByType(EntityType.ENTITY_FIREPLACE)
    for _, fire in pairs(fires) do
        if fire.Variant < 10 and fire.Position:Distance(pos) <= 30 then
            return false
        end
    end
    local grid = game:GetRoom():GetGridEntityFromPos(pos)
    if grid and grid:GetType() == GridEntityType.GRID_ROCK_SPIKED then
        return false
    end
    return true
end

function mod:AngleLimitVector(vec, targVec, angleLimit)
    local angleDiff = mod:GetAngleDifference(vec, targVec)
    if math.abs(angleDiff) > angleLimit then
        return vec:Rotated((math.abs(angleDiff)/angleDiff) * -angleLimit)
    else
        return targVec
    end
end