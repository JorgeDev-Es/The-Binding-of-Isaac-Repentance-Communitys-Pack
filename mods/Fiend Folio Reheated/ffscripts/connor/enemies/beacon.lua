-- Formerly known as Tainted Bulb!

local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local STATE = {
	MOVE = 0,
	PRE_CHARGE = 1,
	CHARGE = 2,
	SUCKIN = 3,
	STUNNED = 4,
}

local MOVE_SPEED = 20
local CHARGE_SPEED = 30
local PRE_CHARGE_FRAMES = 10
local POST_SUCK_FRAMES = 25
local STUNNED_FRAMES = 35

local FLY_HEIGHT = 10

local MIN_DASHES = 5
local MAX_DASHES = 15

local function IsValidBeaconTarget(entity)
	if not entity:ToPlayer() then
		if (entity.Type == mod.FF.Craig.ID and entity.Variant == mod.FF.Craig.Var)
				or (entity.Type == mod.FF.TaintedCraig.ID and entity.Variant == mod.FF.TaintedCraig.Var) then
			return true
		end
		return not mod:isFriend(entity) and (entity:IsVulnerableEnemy() or not mod.IsEnemyReallyInvulnerable(entity))
	end
	
	local player = entity:ToPlayer()
	
	for slot=0,2 do
		if player:HasTrinket(FiendFolio.ITEM.ROCK.SALT_LAMP) then
			return true
		end
		local activeInfo = mod:GetActiveItemInfo(player, slot)
		if activeInfo and activeInfo.ChargeType ~= ItemConfig.CHARGE_SPECIAL and activeInfo.MaxCharges > 0 then
			local maxDebt = activeInfo.MaxCharges
			if player:HasCollectible(mod.ITEM.COLLECTIBLE.DADS_BATTERY) then
				maxDebt = mod:getMaxVisibleChargeDebt(player, slot, activeInfo.ChargeType)
			end
			if mod:getChargeDebt(player, slot) < maxDebt then
				return true
			end
		end
	end
end

local function FindBeaconTarget()
	local valid = {}
	for i=0, game:GetNumPlayers()-1 do
		local player = game:GetPlayer(i)
		if player and player:Exists() then
			if IsValidBeaconTarget(player) then
				table.insert(valid, player)
			end
		end
	end
	if #valid > 0 then
		return valid[(Random() % #valid)+1]
	end
end

local function FindCraig(beacon)
	local firstCraig
	
	for _, craig in pairs(Isaac.FindByType(mod.FF.Craig.ID, mod.FF.Craig.Var)) do
		if craig and craig:Exists() and not craig:IsDead() then
			craig = craig:ToNPC()
			if not firstCraig then
				firstCraig = craig
			end
			if not craig:HasEntityFlags(EntityFlag.FLAG_FEAR) then
				craig:AddFear(EntityRef(beacon), 1)
			end
			if craig:GetData().State == "Wander" and craig.StateFrame < 30 then
				craig.StateFrame = 30
			end
			craig:GetData().MovePos = game:GetRoom():GetClampedPosition(craig.Position + (craig.Position - beacon.Position):Resized(100), 10)
		end
		
	end
	
	for _, roy in pairs(Isaac.FindByType(mod.FF.TaintedCraig.ID, mod.FF.TaintedCraig.Var)) do
		if roy and roy:Exists() and not roy:IsDead() then
			return roy
		end
	end
	
	return firstCraig
end

function mod:BeaconInit(npc)
	if npc.Variant ~= mod.FF.Beacon.Var then return end
	
	npc.SplatColor = Color(0,0,0, 0.6, 0.7, 0.7, 0)
	npc.SpriteOffset = Vector(0, -FLY_HEIGHT)
	
	mod:AddSoundmakerFly(npc)
	
	local rng = RNG()
	rng:SetSeed(npc.InitSeed, 35)
	npc:GetData().RNG = rng
	
	-- Alt. Appear animation.
	local ptr = EntityPtr(npc)
	mod.scheduleForUpdate(function()
		if not FindBeaconTarget() and ptr and ptr.Ref and ptr.Ref:Exists() then
			ptr.Ref:GetSprite():Play("AppearDim", true)
		end
	end, 5)
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.BeaconInit, mod.FF.Beacon.ID)

function mod:BeaconDeath(npc)
	if npc.Variant ~= mod.FF.Beacon.Var then return end
	
	sfx:Play(SoundEffect.SOUND_BULB_FLASH, 1, 0, false, 0.75)
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.BeaconDeath, mod.FF.Beacon.ID)

function mod:BeaconUpdate(npc)
	if npc.Variant ~= mod.FF.Beacon.Var then return end
	
	local room = game:GetRoom()
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	local rng = data.RNG
	
	if mod:isFriend(npc) then
		data.Target = FindCraig(npc) or npc:GetPlayerTarget()
	elseif not data.Target or not data.Target:Exists() or not data.Target:ToPlayer() or not IsValidBeaconTarget(data.Target) then
		data.Target = FindBeaconTarget()
	end
	local target = data.Target
	local sad = not data.Target and not data.FullOfChargeYum
	
	npc.StateFrame = npc.StateFrame - 1
	
	if not data.State then
		data.State = STATE.MOVE
	end
	
	if data.State == STATE.SUCKIN then
		local suckingTarget = data.suckinTarget and data.suckinTarget:Exists() and data.suckinTarget
		if suckingTarget then
			mod:BeaconUpdateLatchedPosition(npc, suckingTarget)
		end
		
		if npc.StateFrame < 1 or not suckingTarget then
			if suckingTarget then
				npc.Velocity = (npc.Position - suckingTarget.Position):Resized(MOVE_SPEED)
				if suckingTarget:ToPlayer() then
					suckingTarget:ToPlayer():AnimateAppear()
					suckingTarget:GetSprite():Play("Hit", true)
				elseif mod:isFriend(npc) and mod:isFriend(suckingTarget) and ((suckingTarget.Type == mod.FF.Craig.ID and suckingTarget.Variant == mod.FF.Craig.Var)
						or (suckingTarget.Type == mod.FF.TaintedCraig.ID and suckingTarget.Variant == mod.FF.TaintedCraig.Var)) then
					suckingTarget:Kill()
				end
				if data.suckinSide then
					suckingTarget:GetData().ffBeaconLeft = nil
				else
					suckingTarget:GetData().ffBeaconRight = nil
				end
				Isaac.Spawn(1000, 2, 1, mod:Lerp(suckingTarget.Position, npc.Position, 0.6) + Vector(0, -25), Vector.Zero, nil)
			end
			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.5, 0, false, 2)
			data.suckinTarget = nil
			npc:GetSprite().Rotation = 0
			data.State = STATE.STUNNED
			data.ffBeaconHit = {}
			npc.StateFrame = POST_SUCK_FRAMES
		elseif suckingTarget:ToNPC() then
			local damage = math.max(0.5, suckingTarget.MaxHitPoints / 200)
			
			if suckingTarget.Type == mod.FF.Craig.ID and suckingTarget.Variant == mod.FF.Craig.Var then
				damage = damage * 2
			elseif suckingTarget.Type == mod.FF.TaintedCraig.ID and suckingTarget.Variant == mod.FF.TaintedCraig.Var then
				local laser = suckingTarget.Child and suckingTarget.Child:ToLaser()
				if laser then
					if not laser:GetData().CraigRing then
						laser.Timeout = 4
					elseif laser.Radius > 5 then
						laser.Radius = mod:Lerp(laser.Radius, 5, 0.1)
					end
				end
				damage = damage * 4
			end
			
			suckingTarget:TakeDamage(damage, 0, EntityRef(npc), 0)
			npc:AddHealth(0.5)
		elseif npc.StateFrame % 10 == 0 then
			if suckingTarget:ToPlayer() and mod:addActiveCharge(suckingTarget, -1, true, true) then
				local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, 49, 3, suckingTarget.Position, Vector.Zero, nil):ToEffect()
				eff.PositionOffset = Vector(0, -40) + RandomVector() * 30
				data.FullOfChargeYum = true
			end
		end
	elseif data.suckinTarget then
		data.suckinTarget = nil
	end
	
	if data.State == STATE.CHARGE and (npc.StateFrame < 1 or not data.ChargeVel) then
		data.State = STATE.MOVE
		data.DashCount = 0
	end
	
	-- Detect hitting a wall.
	if npc:CollidesWithGrid() then
		data.lastCollidesWithGrid = game:GetFrameCount()
	end
	
	if data.State == STATE.CHARGE and data.lastCollidesWithGrid and game:GetFrameCount() - data.lastCollidesWithGrid < 2 then
		local angle1 = data.lastVelocity:GetAngleDegrees() % 360
		local angle2 = npc.Velocity:GetAngleDegrees() % 360
		
		local high, low
		
		if angle1 >= angle2 then
			high = angle1
			low = angle2
		else
			high = angle2
			low = angle1
		end
		
		local diff1 = high - low
		local diff2 = (low + 360) - high
		
		local diff = math.min(diff1, diff2)
		
		if diff >= 30 then
			data.State = STATE.STUNNED
			npc.StateFrame = STUNNED_FRAMES
			
			npc:PlaySound(SoundEffect.SOUND_FORESTBOSS_STOMPS, 0.5, 0, false, 2.7 + rng:RandomFloat()*0.6)
			npc:PlaySound(mod.Sounds.FunnyBonk, 0.2, 0, false, 0.8 + rng:RandomFloat()*0.4)
		end
	end
	
	if data.State == STATE.MOVE then
		if npc.StateFrame < 1 then
			local speed = MOVE_SPEED
			if sad then
				speed = speed * 0.5
			end
			
			if target and not mod:isScareOrConfuse(npc) then
				data.DashCount = data.DashCount or 0
				
				if data.DashCount < MIN_DASHES then
					speed = speed * (data.DashCount+1) / (MIN_DASHES+1)
				end
				
				local targetDist = 150 + (Random() % 100)
				local targetOffset = (npc.Position - target.Position):Resized(targetDist)
				local targetPos = target.Position + RandomVector()
				
				npc.StateFrame = 10
				
				for i=1, 10 do
					if not (target:ToPlayer() and mod:isFriend(npc)) and data.DashCount > MIN_DASHES and Random() % MAX_DASHES < data.DashCount then
						targetPos = npc.Position + (npc.Position - target.Position):Normalized()
						data.State = STATE.PRE_CHARGE
						npc.StateFrame = PRE_CHARGE_FRAMES
						npc:PlaySound(mod.Sounds.BeeBuzzPrep, 1, 0, false, 2.8 + rng:RandomFloat()*0.4)
						speed = speed * 0.5
						break
					end
					local newTargetPos = target.Position + targetOffset:Rotated(-45 + Random() % 90)
					if room:IsPositionInRoom(newTargetPos, npc.Size) then
						targetPos = newTargetPos
						break
					end
				end
				
				npc.Velocity = (targetPos - npc.Position):Resized(speed)
				sprite.FlipX = target.Position.X < npc.Position.X
				data.DashCount = data.DashCount + 1
			else
				local player = npc:GetPlayerTarget()
				local n = 30
				local dir = player and (player.Position - npc.Position):Rotated( n + Random() % (360-n)) or RandomVector()
				npc.StateFrame = 20
				npc.Velocity = dir:Resized(speed)
				data.DashCount = 0
				sprite.FlipX = npc.Velocity.X < 0
			end
		end
	end
	
	if data.State == STATE.PRE_CHARGE then
		if npc.StateFrame < 1 then
			if target then
				npc:PlaySound(mod.Sounds.BeeBuzz, 1, 0, false, 2.8 + rng:RandomFloat()*0.4) -- 1.8-2.2
				data.ChargeVel = (target.Position - npc.Position):Resized(CHARGE_SPEED)
				npc.Velocity = data.ChargeVel * 0.1
				data.State = STATE.CHARGE
				npc.StateFrame = 25
				sprite.FlipX = target.Position.X < npc.Position.X
			else
				data.State = STATE.MOVE
			end
		elseif npc.StateFrame % 5 == 0 then
			local c = npc.Color
			local n = 0.75
			c:SetOffset(c.RO + n, c.BO + n, c.GO + n)
			npc:SetColor(c, 4, 1, true)
		end
	end
	
	if data.State == STATE.STUNNED then
		if sprite:GetAnimation() ~= "Stunned" and sprite:GetAnimation() ~= "StunStart" and sprite:GetAnimation() ~= "StunEnd" then
			sprite:Play("StunStart", true)
		elseif sprite:IsFinished("StunStart") then
			sprite:Play("Stunned", true)
		elseif sprite:IsFinished("StunEnd") then
			data.State = STATE.MOVE
			data.DashCount = 0
		elseif not sprite:IsPlaying("StunEnd") and npc.StateFrame < 1 then
			sprite:Play("StunEnd", true)
		end
	else
		local anim
		if data.State == STATE.SUCKIN or data.State == STATE.PRE_CHARGE or data.State == STATE.CHARGE then
			anim = "Dash"
		elseif data.State == STATE.STUNNED then
			anim = "Stunned"
		elseif sad then
			anim = "FlyDim"
		else
			anim = "Fly"
		end
		
		if sprite:GetAnimation() ~= anim then
			sprite:Play(anim, true)
		end
	end
	
	if data.State == STATE.PRE_CHARGE or data.State == STATE.CHARGE then
		mod:MakeAfterimage(npc)
	end
	
	data.lastVelocity = npc.Velocity
	
	local targetVel = (data.State == STATE.CHARGE) and data.ChargeVel or Vector.Zero
	local n = (data.State == STATE.CHARGE or data.State == STATE.STUNNED) and 0.2 or 0.1
	npc.Velocity = mod:Lerp(npc.Velocity, targetVel, n)
	
	if data.State == STATE.MOVE then
		npc.Velocity = npc.Velocity + RandomVector() * (sad and 1.5 or 3)
	end
	
	local targetHeight = (data.State == STATE.STUNNED) and 0 or FLY_HEIGHT
	npc.SpriteOffset = mod:Lerp(npc.SpriteOffset, Vector(0, -targetHeight), 0.2)
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.BeaconUpdate, mod.FF.Beacon.ID)

function mod:BeaconUpdateLatchedPosition(bulb, entity)
	local data = bulb:GetData()
	
	local w, h
	if entity:ToPlayer() then
		w = 10 + 20 * entity.SpriteScale.X
		h = 30 * entity.SpriteScale.Y
	else
		w = 15 + entity.Size
		h = 10 + entity.Size
	end
	local targetOffset = data.suckinSide and Vector(w, -h) or Vector(-w, -h)
	local startOffset = data.suckinStartOffset or targetOffset
	
	local dur1 = 10
	local dur2 = 4
	local thing = 0.25
	local frame = math.min(Isaac.GetFrameCount() - data.suckinStartFrame, dur1 + dur2)
	
	local x = math.min(frame/dur1, 1)
	local y = math.sin(math.pi * x / 2) * (1+thing)
	local n = y
	
	if frame > dur1 then
		local a = math.min((frame - dur1) / dur2, 1)
		local b = math.sin(math.pi * a / 2) * thing
		n = n - b
	end
	
	local offset = mod:Lerp(startOffset, targetOffset, n)
	local rot = mod:Lerp(25, 0, n)
	bulb:GetSprite().Rotation = rot
	
	bulb.Position = entity.Position + offset
	bulb.Velocity = Vector.Zero
end

function mod:LatchedBeaconUpdate(entity)
	if not entity:Exists() or entity:IsDead() then return end
	
	local data = entity:GetData()
	
	for _, key in pairs({"ffBeaconLeft", "ffBeaconRight"}) do
		local bulb = data[key]
		if bulb then
			if bulb:Exists() and bulb:GetData().State == STATE.SUCKIN then
				mod:BeaconUpdateLatchedPosition(bulb, entity)
			else
				data[key] = nil
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.LatchedBeaconUpdate)
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.LatchedBeaconUpdate)

function mod:BeaconOtherCollision(entity, beacon)
	if beacon.Type ~= mod.FF.Beacon.ID or beacon.Variant ~= mod.FF.Beacon.Var then return end
	
	beacon = beacon:ToNPC()
	local data = beacon:GetData()
	local targetIsPlayer = entity:ToPlayer() ~= nil
	
	if targetIsPlayer and mod:isFriend(beacon) then
		return true
	elseif not targetIsPlayer and not mod:isFriend(beacon) then
		return
	elseif mod:isFriend(beacon) and data.State == STATE.CHARGE and entity.MaxHitPoints <= 6.5
			 and (entity:IsVulnerableEnemy() or not mod.IsEnemyReallyInvulnerable(entity)) then
		if not data.ffBeaconHit then
			data.ffBeaconHit = {}
		end
		if not data.ffBeaconHit[GetPtrHash(entity)] then
			entity:TakeDamage(10, 0, EntityRef(beacon), 0)
		end
		data.ffBeaconHit[GetPtrHash(entity)] = true
		return
	end
	
	if IsValidBeaconTarget(entity) and (data.State == STATE.CHARGE or (targetIsPlayer and data.State == STATE.MOVE)) and not mod:isScareOrConfuse(beacon) then
		if data.suckinTarget and data.suckinTarget:Exists() then
			return true
		end
		
		local targetData = entity:GetData()
		targetData.ffBeaconLatched = beacon
		local side = entity.Position.X < beacon.Position.X
		if side and not (targetData.ffBeaconLeft and targetData.ffBeaconLeft:Exists()) then
			targetData.ffBeaconLeft = beacon
			data.suckinSide = true
		elseif not (targetData.ffBeaconRight and targetData.ffBeaconRight:Exists()) then
			targetData.ffBeaconRight = beacon
			data.suckinSide = false
		else
			return
		end
		data.suckinTarget = entity
		data.suckinStartOffset = beacon.Position - entity.Position
		data.suckinStartFrame = Isaac.GetFrameCount()
		data.State = STATE.SUCKIN
		beacon.StateFrame = 31
		if targetIsPlayer then
			entity:ToPlayer():AnimateAppear()
			entity:GetSprite():Play("Hit", true)
		else
			entity:AddSlowing(EntityRef(beacon), 30 * 5, 0.5, Color(0.5, 0.5, 0.5, 1))
		end
		sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 1.0, 0, false, 2.5)
		beacon:PlaySound(mod.Sounds.BeaconSlurp, 1, 0, false, 0.95 + data.RNG:RandomFloat()*0.1)
		beacon:PlaySound(mod.Sounds.Boink, 3, 0, false, 0.95 + data.RNG:RandomFloat()*0.1)
		beacon:GetSprite().FlipX = data.suckinSide
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, CallbackPriority.LATE, mod.BeaconOtherCollision)
mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_COLLISION, CallbackPriority.LATE, mod.BeaconOtherCollision)

function mod:BeaconCollision(npc, collider)
	if npc.Variant == mod.FF.Beacon.Var and npc:GetData().suckinTarget and npc:GetData().suckinTarget:Exists() then
		return true
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_COLLISION, CallbackPriority.LATE, mod.BeaconCollision, mod.FF.Beacon.ID)

function mod:BeaconDamage(npc)
	if mod:isFriend(npc) and (npc:GetData().State == STATE.CHARGE or npc:GetData().State == STATE.SUCKIN) then
		return false
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, mod.BeaconDamage, mod.FF.Beacon.ID)

local function ContainsBulb(roomDesc)
	local spawnList = roomDesc.Data.Spawns
	for i=0, spawnList.Size - 1 do
		local spawn = spawnList:Get(i)
		
		if spawn then
			local sumWeight = spawn.SumWeights
			local weight = 0
			
			for j = 1, spawn.EntryCount do
				local entry = spawn:PickEntry(weight)
				if entry.Type == EntityType.ENTITY_SUCKER and entry.Variant == 5 then
					return true
				end
				weight = weight + entry.Weight / sumWeight
			end
		end
	end
end

-- During ascent, set any Treasure Rooms that had Bulbs in them as "not clear".
-- This allows Beacons to spawn even if the Treasure Room was cleared previously.
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	local level = game:GetLevel()
	
	if not level:IsAscent() then return end
	
	local rooms = level:GetRooms()
	for i=0, rooms.Size-1 do
		local constRoomDesc = rooms:Get(i)
		if constRoomDesc.Data.Type == RoomType.ROOM_TREASURE and ContainsBulb(constRoomDesc) then
			local mutableRoomDesc = level:GetRoomByIdx(constRoomDesc.GridIndex)
			mutableRoomDesc.Clear = false
		end
	end
end)

-- Replace Bulbs with Beacons in Ascent treasure rooms.
function mod:BeaconReplacement(id, var, subt, gidx, seed)
	if id == EntityType.ENTITY_SUCKER and var == 5 and game:GetLevel():IsAscent()
			and game:GetRoom():GetType() == RoomType.ROOM_TREASURE then
		return { mod.FF.Beacon.ID, mod.FF.Beacon.Var, mod.FF.Beacon.Sub }
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, mod.BeaconReplacement)
