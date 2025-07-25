local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

--------------------------
-- << MATH FUNCTIONS >> --
--------------------------
function mod.Round(num, decimals)
	return tonumber(string.format("%." .. (decimals or 0) .. "f", num))
end

function mod.Clamp(num, minimum, maximum)
	return math.min(math.max(num, minimum), maximum)
end

function mod.ClampVector(vec, minimum, maximum)
	return vec:Resized(math.min(math.max(vec:Length(), minimum), maximum))
end

function mod.Lerp(from, to, fraction)
	return from + (to - from) * fraction
end

function mod.ShortAngleDis(from, to, onlyPositive)
    local maxAngle = 360
    local disAngle = (to - from) % maxAngle
    
	if onlyPositive then
		return (disAngle + maxAngle) % maxAngle
	else
		return ((2 * disAngle) % maxAngle) - disAngle
	end
end

function mod.LerpAngle(from, to, fraction, onlyPositive)
    return (from + mod.ShortAngleDis(from, to, onlyPositive) * fraction) % 360
end

-------------------------
-- << RNG FUNCTIONS >> --
-------------------------
function mod.RandomIntRange(minimum, maximum, rng)
	rng = rng or RNG(math.max(Random(), 1))
	
	return rng:RandomInt(minimum, maximum)
end

function mod.RandomFloatRange(minimum, maximum, rng)
	rng = rng or RNG(math.max(Random(), 1))
	
	return minimum + rng:RandomFloat() * (maximum - minimum)
end

--------------------------
-- << GAME FUNCTIONS >> --
--------------------------
function mod.Fart(position, radius, source, scale, subtype, color, func)
	local hasGiganteBean = PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_GIGANTE_BEAN)
	
	radius = (radius or 85) * (hasGiganteBean and 2 or 1)
	scale = (scale or 1) * (hasGiganteBean and 2 or 1)
	
	local effect = Isaac.Spawn(
		EntityType.ENTITY_EFFECT, EffectVariant.FART, subtype or 0, 
		position, Vector.Zero, nil):ToEffect()
	effect.SpriteScale = Vector.One * scale
	effect.Color = color or Color.Default
	
	if scale > 1.8 then
		sfx:Stop(SoundEffect.SOUND_FART)
		sfx:Play(SoundEffect.SOUND_FART, 1, 0, false, 1)
		sfx:Play(SoundEffect.SOUND_FART, 1.2, 20, false, 0.5)
		game:ShakeScreen(3)
	end
	if source and source:ToPlayer() then
		local moveVec = source:GetMovementVector()
		local hasBirdsEye = source:HasCollectible(CollectibleType.COLLECTIBLE_BIRDS_EYE)
		local hasGhostPepper = source:HasCollectible(CollectibleType.COLLECTIBLE_GHOST_PEPPER)
		
		moveVec = moveVec:Length() == 0 and Vector(0, -1) or -moveVec
		
		if hasBirdsEye and (not hasGhostPepper or Random() % 2 == 0) then
			source:ShootRedCandle(moveVec)
		elseif hasGhostPepper then
			source:ShootBlueCandle(moveVec)
		end
	end
	for _, entity in pairs(Isaac.FindInRadius(position, radius, EntityPartition.ENEMY)) do
		if entity:IsVulnerableEnemy() and entity:IsActiveEnemy() then
			if type(func) == "function" then func(entity) end
		end
	end
end

----------------------------
-- << ENTITY FUNCTIONS >> --
----------------------------
function mod.GetPlayerFromEntity(entity)
	if entity.Parent then
		local player = entity.Parent:ToPlayer()
		local fam = entity.Parent:ToFamiliar()
		
		return fam and fam.Player or player
	end
	if entity.SpawnerEntity then
		local player = entity.SpawnerEntity:ToPlayer()
		local fam = entity.SpawnerEntity:ToFamiliar()
		
		return fam and fam.Player or player
	end
	return entity:ToPlayer()
end

function mod.GetFamiliarFromEntity(entity)
	if entity.Parent then
		return entity.Parent:ToFamiliar()
	end
	if entity.SpawnerEntity then
		return entity.SpawnerEntity:ToFamiliar()
	end
	return entity:ToFamiliar()
end

function mod.GetEntityData(entity) -- To mitigate issues with other mods
	local entityData = entity:GetData()
	
	entityData[mod.Name] = entityData[mod.Name] or {}
	
	return entityData[mod.Name]
end

function mod.GetPredictedTargetPos(entity, target, delay) -- Use this until the real one is fixed
    return target.Velocity * (target.Position - entity.Position):Length() * (delay or 1) + target.Position
end

function mod.IsActiveVulnerableEnemy(entity)
	if not entity then return end
	
	local isFriendly = entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
	
	return entity:IsVulnerableEnemy() and entity:IsActiveEnemy() and not isFriendly
end

function mod.IsLastVulnerableEnemy(npc)
    local count = 0
	
    for _, entity in pairs(Isaac.GetRoomEntities()) do
        if entity:IsEnemy() and entity:IsActiveEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
            if GetPtrHash(entity) ~= GetPtrHash(npc) then
                count = count + 1
            end
        end
    end
    return count == 0
end

function mod.MakeBloodSplat(entity, position, scale, color, offset)
	local effect = Isaac.Spawn(
		EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, 
		position or entity.Position, Vector.Zero, entity):ToEffect()
	
	if scale then effect.SpriteScale = scale * Vector.One end
	if color then effect.Color = color end
	if offset then effect.PositionOffset = offset end
	
	effect:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR | EntityFlag.FLAG_RENDER_WALL)
	effect:Update()
	
	return effect
end

function mod.AttachTrail(entity, length, size, color, offset)
	length = length or 0.15
	size = size or 1
	
	local effect = Isaac.Spawn(
		EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, 
		entity.Position, Vector.Zero, entity):ToEffect()
	effect:FollowParent(entity)
	effect.ParentOffset = offset or Vector.Zero
	effect:SetColor(color or Color.Default, -1, 1, false, false)
	effect.SpriteScale = Vector(size, size)
	effect:SetRadii(length, length)
	effect.RenderZOffset = 0
	effect:Update()
	
	return effect
end

function mod.GetNearestEntity(source, func)
	local nearestDistance = math.huge
	local nearestEntity = nil
	
	for _, entity in pairs(Isaac.GetRoomEntities()) do
		if entity and type(func) == "function" and func(entity) then
			local distanceSqr = source.Position:DistanceSquared(entity.Position)
			
			if distanceSqr < nearestDistance then
				nearestDistance = distanceSqr
				nearestEntity = entity
			end
		end
	end
	return nearestEntity
end

----------------------------
-- << PLAYER FUNCTIONS >> --
----------------------------
function mod.GetExpectedFamiliarNum(player, collectible)
	return player:GetCollectibleNum(collectible) + player:GetEffects():GetCollectibleEffectNum(collectible)
end

function mod.AddPebbleOrbital(player, position)
	return Isaac.Spawn(EntityType.ENTITY_FAMILIAR, mod.Familiar.PEBBLE, 0, position or player.Position, Vector.Zero, player):ToFamiliar()
end

function mod.AddBellGhostFamiliar(player, position)
	return Isaac.Spawn(EntityType.ENTITY_FAMILIAR, mod.Familiar.BELL_GHOST, 0, position or player.Position, Vector.Zero, player):ToFamiliar()
end

function mod.AddTears(fireDelay, value)
    local currentTears = 30 / (fireDelay + 1)
    local newTears = currentTears + value
	
    return math.max((30 / newTears) - 1, -0.99)
end

------------------------------------
-- << PLAYER MANAGER FUNCTIONS >> --
------------------------------------
function mod.AnyoneHasCollectibleEffect(collectible)
	for _, player in pairs(PlayerManager.GetPlayers()) do
		if player and player:GetEffects():HasCollectibleEffect(collectible) then
			return true
		end
	end
	return false
end

function mod.RandomTrinketOwner(trinket, seed, rng)
	rng = rng or RNG(seed or math.max(Random(), 1))
	
	local playerList = {}
	for _, player in pairs(PlayerManager.GetPlayers()) do
		if player.Variant == PlayerVariant.PLAYER and player:GetTrinketMultiplier(trinket) > 0 then
			table.insert(playerList, player)
		end
	end
	return playerList[rng:RandomInt(#playerList) + 1]
end

------------------------------
-- << FAMILIAR FUNCTIONS >> --
------------------------------
function mod.GetModifiedFireRate(fam, value, mult)
	if fam.Player:GetTrinketMultiplier(TrinketType.TRINKET_FORGOTTEN_LULLABY) > 0 then
		value = value * (mult or 0.5)
	end
	return value
end

--------------------------
-- << TEAR FUNCTIONS >> --
--------------------------
function mod.GetBloodTearVariant(tear)
	local bloodVariant = {
		[TearVariant.BLUE] = TearVariant.BLOOD,
		[TearVariant.CUPID_BLUE] = TearVariant.CUPID_BLOOD,
		[TearVariant.NAIL] = TearVariant.NAIL_BLOOD,
		[TearVariant.PUPULA] = TearVariant.PUPULA_BLOOD,
		[TearVariant.GODS_FLESH] = TearVariant.GODS_FLESH_BLOOD,
		[TearVariant.GLAUCOMA] = TearVariant.GLAUCOMA_BLOOD,
		[TearVariant.EYE] = TearVariant.EYE_BLOOD,
		--[TearVariant.KEY] = TearVariant.KEY_BLOOD, -- Not in the vanilla function
	}
	return bloodVariant[tear.Variant]
end

----------------------------
-- << PICKUP FUNCTIONS >> --
----------------------------
function mod.IsDealPrice(price)
	if price == PickupPrice.PRICE_ONE_HEART 
	or price == PickupPrice.PRICE_TWO_HEARTS 
	or price == PickupPrice.PRICE_THREE_SOULHEARTS 
	or price == PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS 
	or price == PickupPrice.PRICE_ONE_SOUL_HEART 
	or price == PickupPrice.PRICE_TWO_SOUL_HEARTS 
	or price == PickupPrice.PRICE_ONE_HEART_AND_ONE_SOUL_HEART 
	then
		return true
	end
	return false
end

---------------------------
-- << LEVEL FUNCTIONS >> --
---------------------------
function mod.RevealLastBossRoom(level) -- Should be similar to the Sol item
	local roomDesc = level:GetRooms():Get(level:GetLastBossRoomListIndex())
	
	roomDesc.DisplayFlags = roomDesc.DisplayFlags | 4 -- Reveals the icon only
	level:UpdateVisibility()
end