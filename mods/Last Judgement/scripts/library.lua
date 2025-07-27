local mod = LastJudgement
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

function mod:RandomFloat(low, high, rng) --I had a comment on this function saying it's not exact but I'm just copy pasting it
    local newLow = math.floor(low)
    local newHigh = math.ceil(high)
    local val = rng:RandomFloat() * (newHigh-newLow)
    return math.max(math.min(newLow+val, high), low)
end

function mod:RandomAngle(rng)
    return mod:RandomInt(0,359,rng)
end

function mod:RandomInRange(i, entrng)
    return mod:RandomInt(-i, i, entrng)
end

function mod:RandomSign(entrng)
    local rand = entrng or mod.RNG
    return (rand:RandomFloat() < 0.5 and -1 or 1)
end

function mod:RandomBool(entrng)
    return mod:RandomSign(entrng) == 1
end

function mod:GetRandomElem(table, rand)
    if table and #table > 0 then
		local index = mod:RandomInt(1, #table, rand)
        return table[index], index
    end
end

function mod:GetRandomIndex(letable, customRNG)
    local indexes = {}
    for index, _ in pairs(letable) do
        table.insert(indexes, index)
    end
    return mod:GetRandomElem(indexes, customRNG)
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

function mod:IsAnyPlayerOfType(playerType)
	for _, player in pairs(mod:GetAllPlayers()) do
		if player:GetPlayerType() == playerType then
			return true
		end
	end
end

function mod:AnyPlayerHasCollectible(collectible)
	for _, player in pairs(mod:GetAllPlayers()) do
		if player:HasCollectible(collectible) then
			return true
		end
	end
end

function mod:AnyPlayerHasTrinket(trinket)
    for _, player in ipairs(mod:GetAllPlayers()) do
        if player:HasTrinket(trinket) then
            return player
        end
    end
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

function mod:GetPlayerSource(source)
    if source and source.Entity then
        if source.Entity:ToPlayer() ~= nil then
            return source.Entity:ToPlayer()
        elseif source.Entity:ToFamiliar() ~= nil then
            return source.Entity:ToFamiliar().Player
        elseif source.Entity.SpawnerEntity ~= nil then
            if source.Entity.SpawnerEntity:ToPlayer() ~= nil then
                return source.Entity.SpawnerEntity:ToPlayer()
            elseif source.Entity.SpawnerEntity:ToFamiliar() ~= nil then
                return source.Entity.SpawnerEntity:ToFamiliar().Player
            end
        end
    end
end

function mod:DoesFamiliarShootPlayerTears(familiar)
	return (familiar.Variant == FamiliarVariant.INCUBUS
	or familiar.Variant == FamiliarVariant.SPRINKLER 
	or familiar.Variant == FamiliarVariant.TWISTED_BABY 
	or familiar.Variant == FamiliarVariant.BLOOD_BABY 
	or familiar.Variant == FamiliarVariant.UMBILICAL_BABY) 
end

mod.PlayerTearFamiliars = {
    [FamiliarVariant.INCUBUS] = true,
	[FamiliarVariant.SPRINKLER] = true,
	[FamiliarVariant.TWISTED_BABY] = true,
	[FamiliarVariant.BLOOD_BABY] = true,
	[FamiliarVariant.UMBILICAL_BABY] = true,
}

function mod:GetPlayerFromTear(tear)
	local player
	if not tear.SpawnerEntity then
		return
	elseif tear.SpawnerEntity:ToPlayer() then
		player = tear.SpawnerEntity:ToPlayer()
	elseif tear.SpawnerEntity:ToFamiliar() and tear.SpawnerEntity:ToFamiliar().Player then
		local familiar = tear.SpawnerEntity:ToFamiliar()
		if mod.PlayerTearFamiliars[familiar.Variant] then
			player = familiar.Player
		else
			return
		end
	else
		return
	end
	return player
end

function mod:SnapVector(angle, snapAngle)
    local snapped = math.floor(((angle:GetAngleDegrees() + snapAngle/2) / snapAngle)) * snapAngle
    local snappedDirection = angle:Rotated(snapped - angle:GetAngleDegrees())
    return snappedDirection
end

function mod:GetAimDirection(player)
    local aim = player:GetAimDirection()
    local lockAngle
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
            lockAngle = 45
        else
            lockAngle = 90
        end
    end
    if lockAngle then
        aim = mod:SnapVector(aim, lockAngle)
    end
    aim = aim:Normalized()
    return aim
end

function mod:GetLudoTear(player)
    for _, tear in pairs(Isaac.FindByType(EntityType.ENTITY_TEAR)) do
        tear = tear:ToTear()
        if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) and tear.SpawnerEntity and tear.SpawnerEntity.InitSeed == player.InitSeed then
            return tear
        end
    end
end

function mod:HasDamageFlag(damageFlags, damageFlag)
    return damageFlags & damageFlag ~= 0
end

function mod:GetOrbitOffset(angle, distance)
    return Vector( distance * math.cos(angle), distance * math.sin(angle))
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

--EntityNPC:PlaySound() but with optional arguments
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

function mod:PrintColor(color)
    print(color.R.." "..color.G.." "..color.B.." "..color.A.." "..color.RO.." "..color.GO.." "..color.BO)
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

function mod:AnimWalkFrame(npc, sprite, horianim, vertanim, doFlip, idleAnim, idleThreshold)
    idleThreshold = idleThreshold or 0.1
    if npc.Velocity:Length() < idleThreshold then
        if idleAnim then
            mod:spritePlay(sprite, idleAnim)
        elseif type(vertanim) == "table" then
            sprite:SetFrame(vertanim[1], 0)
        else
            sprite:SetFrame(vertanim, 0)
        end
    else
        local anim
        if math.abs(npc.Velocity.X) > math.abs(npc.Velocity.Y) then
            if type(horianim) == "table" and not doFlip then
                if npc.Velocity.X > 0 then
                    anim = horianim[1]
                else
                    anim = horianim[2]
                end
            else
                anim = horianim
            end
        else
            if type(vertanim) == "table" then
                if npc.Velocity.Y > 0 then
                    anim = vertanim[1]
                else
                    anim = vertanim[2]
                end
            else
                anim = vertanim
            end
        end
        if npc.Velocity.X < 0 and doFlip then
            sprite.FlipX = true
        else
            sprite.FlipX = false
        end
        if not sprite:IsPlaying() then
            sprite:Play(anim)
        else
            sprite:SetAnimation(anim, false)
        end
    end
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
    local pathSpeed
    if type(speed) == "table" then
        pathSpeed = speed[2]
        speed = speed[1]
    else
        pathSpeed = (speed * 0.1) + 0.2
    end

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
            npc.Pathfinder:FindGridPath(data.WalkPos, pathSpeed, 900, true)
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
        return false, false, Vector.Zero
    
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
            return false, false, Vector.Zero
        else
            return true, false, vel or Vector.Zero
        end
    else
        data.LastWanderFrame = game:GetFrameCount()
        data.WalkPos = mod:FindRandomValidPathPositionAir(npc, avoidPlayer, minRange, maxRange)
        return true, true, Vector.Zero
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

function mod:WanderGridAligned(npc, data, speed, lerpVal, gridLimit)
    lerpVal = lerpVal or 0.3

    if data.GridAlignedHome then
        local vel 

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
        end
    else
        data.GridAlignedHome = mod:GetNewPosGridAligned(npc.Position, false, gridLimit)
        return true, true
    end
end

function mod:FindRandomTeleportPos(npc, avoidplayer, nearPlayer)
	local validPositions = {}
	local validPositions2 = {}
	local room = game:GetRoom()

	for i = 0, room:GetGridSize() - 1 do
		local gridpos = room:GetGridPosition(i)
		if room:GetGridPath(i) <= 900 and room:IsPositionInRoom(gridpos, 0) then
            local playerDist = game:GetNearestPlayer(gridpos).Position:Distance(gridpos)
			if (avoidPlayer and playerDist < avoidPlayer) or (nearPlayer and playerDist > nearPlayer) then
                table.insert(validPositions2, gridpos)
            else
                table.insert(validPositions, gridpos)
			end
		end
	end
	return (mod:GetRandomElem(validPositions) or mod:GetRandomElem(validPositions2) or npc.Position)
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
        if behindVec and behindVec:Length() > 0.01 and math.abs(mod:GetAngleDifference(vec, behindVec)) < 30 then
            return false
        end
        return vec
    end
    return false
end

function mod:QuickSetEntityGridPath(entity, valueOverride)
	local room = game:GetRoom()
	local positionIndex = room:GetGridIndex(entity.Position)
	valueOverride = valueOverride or 900
	if entity.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE and room:GetGridPath(positionIndex) <= valueOverride then
		room:SetGridPath(positionIndex, valueOverride)
	end
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

function mod:DestroyGridsInRadius(pos, radius)
    for _, grid in pairs(mod:GetGridsInRadius(pos, radius)) do
        grid:Destroy()
    end
end

function mod:ChasePlayer(npc, speed, lerpval, setGridPath)
    return mod:ChasePosition(npc, mod:confusePos(npc, npc:GetPlayerTarget().Position), speed, lerpval, setGridPath)
end

function mod:ChasePosition(npc, targetpos, speed, lerpval, setGridPath)
    lerpval = lerpval or 0.25
    local pathSpeed
    if type(speed) == "table" then
        pathSpeed = speed[2]
        speed = speed[1]
    else
        pathSpeed = (speed * 0.1) + 0.2
    end
    if setGridPath == nil then setGridPath = true end
    local room = game:GetRoom()

    if room:CheckLine(npc.Position,targetpos,0,1,false,false) or mod:isScare(npc) then
        npc.Velocity = mod:Lerp(npc.Velocity, mod:reverseIfFear(npc, (targetpos - npc.Position):Resized(speed)), lerpval)
        return true
    elseif npc.Pathfinder:HasPathToPos(targetpos) then
        npc.Pathfinder:FindGridPath(targetpos, pathSpeed, 900, true)
        return true
    else
        npc.Velocity = mod:Lerp(npc.Velocity, Vector.Zero, lerpval)
    end

    if setGridPath then
        mod:QuickSetEntityGridPath(npc)
    end
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

function mod:IsRenderingReflection()
    return game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT
end

function mod:IsNormalRender()
    local isPaused = game:IsPaused()
    local isReflected = mod:IsRenderingReflection()
    return (isPaused or isReflected) == false
end

function mod:GetHealthPercent(ent)
	return ent.HitPoints / ent.MaxHitPoints
end

function mod:SetColorFlash(sprite)
    if sprite:IsOverlayPlaying() then
        local nullFrame = sprite:GetOverlayNullFrame("ColorTint")
        if nullFrame then
            mod:ScheduleForUpdate(function() sprite.Color = nullFrame:GetColor() end, 0)
        end
    end
end

function mod:SetDeform(sprite)
    if sprite:IsOverlayPlaying() then
        local nullFrame = sprite:GetOverlayNullFrame("Deform")
        if nullFrame then
            mod:ScheduleForUpdate(function() sprite.Scale = nullFrame:GetScale() end, 0)
        end
    end
end

mod.StageBackdrops = {
    Downpour = {31,36},
    Dross = {45},
}

function mod:CheckStage(stagename)
    local level = game:GetLevel()
    local room = game:GetRoom()
    local levelname = level:GetName()
    if levelname == stagename or levelname == stagename.."I" or levelname == stagename.."II" then
        return true
    elseif mod.StageBackdrops[stagename] then
        for _, backdrop in pairs(mod.StageBackdrops[stagename]) do
            if room:GetBackdropType() == backdrop then
                return true
            end
        end
    end
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

function mod:GetEntityCount(id,var,sub,spawner)
    var = var or -1
    sub = sub or -1
    return Isaac.CountEntities(spawner,id,var,sub)
end

function mod:grabbedByBigHorn(npc)
	local bigHornHands = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BIG_HORN_HAND)
	for _, hand in ipairs(bigHornHands) do
		if hand.Target and hand.Target.InitSeed == npc.InitSeed and hand.Target.Index == npc.Index then
			return true
		end
	end

	return false
end

function mod:WouldEnemyHaveDeathEffect(npc)
    return not (npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) or mod:isStatusCorpse(npc) or mod:isLeavingStatusCorpse(npc) or npc:GetChampionColorIdx() == 12 or mod:grabbedByBigHorn(npc))
end

function mod:MakeEnemyDeathAnim(npc, anim, extraFunc, canShutDoors, canCollide, hasKnockback, dropsBeforeAnim)
    local deathAnim = Isaac.Spawn(npc.Type, npc.Variant, npc.SubType, npc.Position, Vector.Zero, nil):ToNPC()
    local deathAnimData = deathAnim:GetData()
    local deathAnimSprite = deathAnim:GetSprite()
    local data = npc:GetData()

    if npc:GetChampionColorIdx() >= 0 then
		deathAnim:MakeChampion(0, npc:GetChampionColorIdx())
	end
    deathAnim:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	deathAnimData.FFIsDeathAnimation = true
	deathAnimSprite:Play(anim, true)
	deathAnimSprite.Offset = npc:GetSprite().Offset
	deathAnimSprite.FlipX = npc:GetSprite().FlipX
	deathAnim.SplatColor = npc.SplatColor

	if not canCollide then deathAnim.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE end
	if canShutDoors ~= nil then deathAnim.CanShutDoors = canShutDoors end
	if not hasKnockback then deathAnim:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) end
	deathAnim:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_TARGET)

	if (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
		deathAnim:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
	end

	if extraFunc then
        extraFunc(npc, deathAnim)
    end

	if dropsBeforeAnim then
		data.LJPreventDeathDrops = false
		deathAnimData.LJPreventDeathDrops = true
	else
		data.LJPreventDeathDrops = true
		deathAnimData.LJPreventDeathDrops = false
	end
	npc.Visible = false
end

function mod:CustomProjectileBehavior(proj, d)
    if d.projType == "customProjectileBehavior" and d.customProjectileBehaviorLJ then
        local tab = d.customProjectileBehaviorLJ
        if tab.customFunc then
            tab.customFunc(proj, tab)
        end
    end
end

function mod:CustomProjectileRemove(proj, d)
    if d.projType == "customProjectileBehavior" and d.customProjectileBehaviorLJ and d.customProjectileBehaviorLJ.death then
        local tab = d.customProjectileBehaviorLJ
        tab.death(proj, tab)
    end
end

function mod:RandomizedPosition(xSize, ySize, rng)
	rng = rng or mod.RNG
	return Vector(mod:RandomInt(-xSize, xSize, rng), mod:RandomInt(-ySize, ySize, rng))
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

function mod:BoundValue(val, lowerbound, upperbound)
    if lowerbound then
        val = math.max(val, lowerbound)
    end
    if upperbound then
        val = math.min(val, upperbound)
    end
    return val
end

function mod:IsNormalRender()
    local isPaused = game:IsPaused()
    local isReflected = (game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT)
    return (isPaused or isReflected) == false
end

function mod:ShootClusterProjectiles(npc, vec, amount, params, maxSpread, fallAccel, fallSpeed, maxFallSpeedMult, shootPos)
    if vec then
        local rng = npc:GetDropRNG()
		local basescale = params.Scale or 1
        local baseFallSpeed = params.FallingSpeedModifier or 0
		params = params or ProjectileParams()
		amount = amount or 8
        maxSpread = maxSpread or 20
        params.FallingAccelModifier = fallAccel or 0.6
        fallSpeed = fallSpeed or -5
        maxFallSpeedMult = maxFallSpeedMult or 1
        shootPos = shootPos or npc.Position
        local projs = {}
        for i = 1, amount do
            params.FallingSpeedModifier = mod:RandomInt(fallSpeed*50,fallSpeed*100*maxFallSpeedMult,rng) * 0.01
            params.Scale = basescale + mod:RandomInt(-10,10,rng) * 0.05
            table.insert(projs, npc:FireProjectilesEx(npc.Position, vec:Resized(vec:Length() * mod:RandomInt(80,120,rng) * 0.01):Rotated(mod:RandomInt(-maxSpread,maxSpread,rng)), 0, params)[1])			
        end
        params.Scale = basescale
        params.FallingSpeedModifier = baseFallSpeed
		return projs
    end
end

function mod:IsRoomActive()
    local room = game:GetRoom()
    return (room:IsAmbushActive() or not room:IsClear())
end

function mod:DamageInRadius(pos, radius, damage, source, flags, ignoreFlying, doFriendlyFire, enemyDamage, enemyDmgInterval, alwaysGatherEnemies)
    local hurtPlayers = true
    local hurtEnemies = false
    local checkSelf = false
    local did = false
    local playersHit = {}
    local enemiesHit = {}

    if source then
        if source:ToNPC() then
            hurtPlayers = not mod:isFriend(source) 
            hurtEnemies = mod:isCharm(source)
            checkSelf = true
        elseif source:ToProjectile() then
            hurtPlayers = not source:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)
            hurtEnemies = source:ToProjectile():HasProjectileFlags(ProjectileFlags.HIT_ENEMIES)
        end
    end

    if doFriendlyFire then
        hurtEnemies = true
    end

    damage = damage or 1
    flags = flags or 0
    enemyDamage = enemyDamage or damage
    enemyDmgInterval = enemyDmgInterval or 1

    if hurtPlayers then
        for i = 0, game:GetNumPlayers() do
            local player = game:GetPlayer(i)
            if player:Exists() and player.Position:Distance(pos) <= player.Size + radius and not (ignoreFlying and player:IsFlying()) then
                player:TakeDamage(damage, flags, EntityRef(source), 0)
                table.insert(playersHit, player:ToPlayer())
                if player:GetDamageCooldown() == 0 then
                    did = true
                end
            end
        end
    end

    if game:GetFrameCount() % enemyDmgInterval == 0 then
        for _, enemy in pairs(Isaac.FindInRadius(pos, radius * 2, EntityPartition.ENEMY)) do
            if enemy.Position:Distance(pos) <= enemy.Size + radius and not ((ignoreFlying and enemy:IsFlying()) or (checkSelf and source.InitSeed == enemy.InitSeed)) then
                if hurtEnemies and not mod:isFriend(enemy) then
                    enemy:TakeDamage(enemyDamage, flags, EntityRef(source), 0)
                    table.insert(enemiesHit, enemy:ToNPC())
                    did = true
                elseif hurtPlayer and mod:isFriend(enemy) then
                    enemy:TakeDamage(enemyDamage, flags, EntityRef(source), 0)
                    table.insert(enemiesHit, enemy:ToNPC())
                    did = true
                elseif alwaysGatherEnemies then
                    table.insert(enemiesHit, enemy:ToNPC())
                end
            end
        end
    end

    return did, hurtPlayers, playersHit, hurtEnemies, enemiesHit
end


function mod:IsPitAdjacent(index)
	local room = game:GetRoom()
	if index then
        local offsets = {-1, 1, -room:GetGridWidth(), room:GetGridWidth()}
		for _, offset in pairs(offsets) do
			local grid = room:GetGridEntity(index + offset)
			if grid and grid:GetType() == GridEntityType.GRID_PIT then
				return true
			end
		end
	end
end

function mod:UpdatePits()
    StageAPI.ChangeGrids(nil, false)
end

function mod:CloneColor(color, alpha)
    local newColor = Color.Lerp(color, Color.Default, 0)
    newColor.A = alpha or 1
    return newColor
end

function mod:GatherChildren(npc, type, variant)
    local children = {}
    for _, child in pairs(Isaac.FindByType(type or npc.Type, variant or npc.Variant + 1)) do
        if child.Parent and child.Parent.InitSeed == npc.InitSeed then
            table.insert(children, child)
        end
    end
    return children
end

function mod:FindSafeSpawnSpot(position, radius, fallbackRadius, fallbackToPos, avoidPlayer, avoidSelf)
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
                if gridpos:Distance(position) <= radius and not ((avoidPlayer and game:GetNearestPlayer(gridpos).Position:Distance(gridpos) <= avoidPlayer) or (avoidSelf and gridpos:Distance(position) <= avoidSelf)) then
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

function mod:D10Cleanup(npc, doPoof)
    if doPoof then
        Isaac.Spawn(1000,15,0,npc.Position,Vector.Zero,npc)
    end
    npc:Remove()
    return true
end

function mod:ToggleCollision(npc, solidClass, nonSolidClass)
    solidClass = solidClass or EntityCollisionClass.ENTCOLL_ALL
    nonSolidClass = nonSolidClass or EntityCollisionClass.ENTCOLL_NONE
    if npc.EntityCollisionClass == solidClass then
        npc.EntityCollisionClass = nonSolidClass
        return false
    else
        npc.EntityCollisionClass = solidClass
        return true
    end
end

function ToggleCollisionAndFlags(npc, solidClass, nonSolidClass)
    if mod:ToggleCollision(npc, solidClass, nonSolidClass) then
        npc:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
    else
        npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_HIDE_HP_BAR)
    end
end

function mod:GetNearestObstacleSpawnPos(pos, fallbackPos, avoidScalpelLines)
    local room = game:GetRoom()
    local currentRoom = StageAPI.GetCurrentRoom()
    local spawnPos = fallbackPos or room:GetGridPosition(pos)
    local dist = 9999
    for i = 0, room:GetGridSize() - 1 do
        if room:CanSpawnObstacleAtPosition(i) and not (avoidScalpelLines and currentRoom and currentRoom.Metadata:Has({Name = "ScalpelLine"; Index = i})) then
            local gridPos = room:GetGridPosition(i)
            local newDist = gridPos:Distance(pos)
            if newDist < dist then
                spawnPos = gridPos
                dist = newDist
                if dist < 40 then
                    break
                end
            end
        end
    end
    return spawnPos
end

function mod:HasWaterPits(ignoreFlooded)
    return (game:GetLevel():GetCurrentRoomDesc().Flags & RoomDescriptor.FLAG_HAS_WATER ~= 0 or (game:GetRoom():HasWater() and not IgnoreFlooded))
end

function mod:VecToDir(vec)
    return (math.floor(mod:GetAngleDegreesButGood(-vec)) / 90)
end

function mod:NegateKnockoutDrops(npc)
	if npc:HasEntityFlags(EntityFlag.FLAG_KNOCKED_BACK) then
		npc:ClearEntityFlags(EntityFlag.FLAG_KNOCKED_BACK | EntityFlag.FLAG_CONFUSION)
		npc.Velocity = Vector.Zero
	end
end

function mod:CapsuleCollision(capsuleStart, capsuleEnd, pos, maxDist)
    local span = capsuleEnd - capsuleStart 
    local length = span:LengthSquared()
    if length == 0 then
        return (capsuleStart:Distance(pos) < maxDist)
    else
        local t = mod:BoundValue(span:Dot(pos - capsuleStart)/length, 0, 1)
        local projection = capsuleStart + (t * span)
        return (projection:Distance(pos) < maxDist)
    end
end

function mod:GetAllGridOfType(type, collisionclass) 
    local gridtable = {}
    local room = game:GetRoom()
    for i = 0, room:GetGridSize() - 1 do 
        local grid = room:GetGridEntity(i)
        local customGrid = StageAPI.GetCustomGrid(i)
        if grid and grid:GetType() == type and not (customGrid and customGrid.GridConfig.Name ~= "StageAPIOverridenAltRock") then
            if collisionclass == nil or room:GetGridCollisionAtPos(grid.Position) == collisionclass then
                table.insert(gridtable, grid)
            end
        end
    end
    return gridtable
end

function mod:GetNearestGridOfType(pos, type, collisionclass, badIndex)
    local dist = 99999
    local closegrid
    for _, grid in pairs(mod:GetAllGridOfType(type, collisionclass)) do
        if grid.Position:Distance(pos) < dist and grid:GetGridIndex() ~= badIndex then
            dist = grid.Position:Distance(pos)
            closegrid = grid
        end
    end
    return closegrid
end

function mod:GetNearestPosOfCollisionClassOrLess(position, collisionClass)
    local indextable = {}
    local room = game:GetRoom()
    for i = 0, room:GetGridSize() - 1 do 
        if room:GetGridCollision(i) <= collisionClass then
            table.insert(indextable, i)
        end
    end
    local nearest
    local nearDist = 10000
    for _, index in pairs(indextable) do
        local pos = room:GetGridPosition(index)
        if pos:Distance(position) < nearDist then
            nearest = pos
            nearDist = pos:Distance(position)
        end
    end
    return nearest or position
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

function mod:GetAllDoors()
    local room = game:GetRoom()
    local doors = {}
    for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
        local door = room:GetDoor(i)
        if door then
            table.insert(doors, door)
        end
    end
    return doors
end

function mod:MovePlayer(player, pos)
    player.Position = pos
    for _, familiar in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR)) do
        familiar = familiar:ToFamiliar()
        if familiar.Player and familiar.Player.InitSeed == player.InitSeed then
            familiar.Position = pos
        end
    end
end

function mod:IsPointInElipse(elipsePos, width, height, testPos)
    local one = (testPos.X - elipsePos.X)^2 / width^2
    local two = (testPos.Y - elipsePos.Y)^2 / height^2
    local dist = one + two
    return (dist <= 1), dist
end

function mod:GetWallInDirection(pos, dir)
    local room = game:GetRoom()
    while room:IsPositionInRoom(pos, 0) do
        pos = pos + dir:Resized(40)
    end
    return room:GetGridPosition(room:GetGridIndex(pos))
end

function mod:GetStageAndType()
    local currentstage = StageAPI.GetCurrentStage()
	if currentstage and currentstage.LevelgenStage then
		return currentstage.LevelgenStage.Stage, currentstage.LevelgenStage.StageType
    else
        local level = game:GetLevel()
        return level:GetStage(), level:GetStageType()
	end
end

function mod:AngleLimitVector(vec, targVec, angleLimit)
    local angleDiff = mod:GetAngleDifference(vec, targVec)
    if math.abs(angleDiff) > angleLimit then
        return vec:Rotated((math.abs(angleDiff)/angleDiff) * -angleLimit)
    else
        return targVec
    end
end

function mod:AreOthersInState(npc, state)
    for _, entity in ipairs(Isaac.FindByType(npc.Type, npc.Variant)) do
        if entity.InitSeed ~= npc.InitSeed then
            if entity:GetData().state == state or entity:GetData().State == state then
                return true
            end
        end
    end
end

--Looping sounds management
mod.LoopingSounds = {}

function mod:RegisterLoopingSound(sfx, func, lerp)
    mod.LoopingSounds[sfx] = {
        Func = func,
        Lerp = lerp or 1,
    }
end

mod:AddPriorityCallback(ModCallbacks.MC_POST_UPDATE, CallbackPriority.LATE, function()
    --local roomEntities = mod:GetRoomEntities()
    for id, soundData in pairs(mod.LoopingSounds) do
        local volume, pitch = soundData.Func(--[[roomEntities]])
        sfx:SetAmbientSound(id, mod:Lerp(sfx:GetAmbientSoundVolume(id), volume or 0, soundData.Lerp), pitch or 1)
    end
end)