local Mod = RepMMod

local function TEARFLAG(x)
	return x >= 64 and BitSet128(0, 1 << (x - 64)) or BitSet128(1 << x, 0)
end

---@param player EntityPlayer
function SpawnAxe(player)
	local axe = Isaac.Spawn(1000, Mod.RepmTypes.EFFECT_SIMS_AXE, 0, player.Position, Vector.Zero, player):ToEffect()
	local data = Mod:GetData(player)
	data.ExtraSpins = math.max(0, data.ExtraSpins - 1)
	axe.Parent = player
	axe:FollowParent(player)

	local sprite = axe:GetSprite()

	--sprite:Play("SpinDown", true)
	local headDirection = player:GetHeadDirection()

	if headDirection == Direction.LEFT then
		sprite:Play("SpinLeft", true)
	elseif headDirection == Direction.UP then
		sprite:Play("SpinUp", true)
	elseif headDirection == Direction.RIGHT then
		sprite:Play("SpinRight", true)
	elseif headDirection == Direction.DOWN then
		sprite:Play("SpinDown", true)
	end

	SFXManager():Play(SoundEffect.SOUND_SWORD_SPIN)
end

function ReplaySpin(player, axe)
	local data = Mod:GetData(player)
	local blackList = Mod:GetData(axe)
	data.ExtraSpins = math.max(0, data.ExtraSpins - 1)
	blackList.HitBlacklist = {}
	local sprite = axe:GetSprite()
	sprite:SetFrame(2)

	SFXManager():Play(SoundEffect.SOUND_SWORD_SPIN)
end

local function PostNewRoom()
	-- just in case it gets interrupted
	RepMMod:AnyPlayerDo(function(player)
		Mod:GetData(player).ExtraSpins = 0
	end)
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)

Mod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, function(_, item, player, vardata, maxcharge)
	return maxcharge + vardata
end, Mod.RepmTypes.COLLECTIBLE_AXE_ACTIVE)

Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	Mod:AnyPlayerDo(function(player)
		---@cast player EntityPlayer
		for slot = 0, 2 do
			if player:GetActiveItem(slot) == Mod.RepmTypes.COLLECTIBLE_AXE_ACTIVE then
				player:SetActiveVarData(0, slot)
			end
		end
	end)
end)

---@param player EntityPlayer
local function onUseAxe(_, collectibletype, rng, player, useflags, slot, vardata)
	if useflags & UseFlag.USE_CARBATTERY ~= 0 then
		Mod:GetData(player).ExtraSpins = Mod:GetData(player).ExtraSpins + 1
	end
	local weaponType = player:GetWeapon(1):GetWeaponType()
	if player:GetMultiShotParams(weaponType):GetNumTears() > 1 then
		Mod:GetData(player).ExtraSpins = Mod:GetData(player).ExtraSpins + player:GetMultiShotParams(weaponType):GetNumTears()
	end
	local itemDesc = player:GetActiveItemDesc(slot)
	player:SetActiveVarData(itemDesc.VarData + 25, slot)
	SpawnAxe(player)
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, onUseAxe, Mod.RepmTypes.COLLECTIBLE_AXE_ACTIVE)

local function AxeSpin(_, axe)
	local player = axe.SpawnerEntity or axe.Parent
	if not player and not player:ToPlayer() then
		axe:Remove()
	end
	player = player:ToPlayer()
	local data = Mod:GetData(player)
	local blackList = Mod:GetData(axe)
	local sprite = axe:GetSprite()
	data.ExtraSpins = data.ExtraSpins or 0
	-- We are going to use this table as a way to make sure enemies are only hurt once in a swing.
	-- This line will either set the hit blacklist to itself, or create one if it doesn't exist.
	blackList.HitBlacklist = blackList.HitBlacklist or {}

	-- Handle removing the pipe when the spin is done.
	if sprite:GetFrame() >= 9 and data.ExtraSpins > 0 then
		ReplaySpin(player, axe)
	end
	if sprite:IsFinished() then
		axe:Remove()
		return
	end

	-- We're doing a for loop before because the effect is based off of Spirit Sword's anm2.
	-- Spirit Sword's anm2 has two hitboxes with the same name with a different number at the ending, so we use a for loop to avoid repeating code.
	local axeDamage = (player.Damage * 3) + 5
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
		axeDamage = (player.Damage * 6) + 5
	end

	local flags = 0
	for _, callback in ipairs(Isaac.GetCallbacks("SIM_AXE_DAMAGE_FLAGS")) do
		local flag = callback.Function(callback.Mod, player)
		flag = type(flag) == "number" and math.max(0, math.floor(flag)) or 0
		flags = flags | flag
	end

	for i = 1, 2 do
		-- Get the "null capsule", which is the hitbox defined by the null layer in the anm2.
		local capsule = axe:GetNullCapsule("Hit" .. i)
		-- Search for all enemies within the capsule.
		for _, enemy in ipairs(Isaac.FindInCapsule(capsule, EntityPartition.ENEMY)) do
			-- Make sure it can be hurt.
			if
				enemy:IsVulnerableEnemy()
				and enemy:IsActiveEnemy()
				and not blackList.HitBlacklist[GetPtrHash(enemy)]
			then
				-- Now hurt it.
				enemy:TakeDamage(axeDamage, flags, EntityRef(axe), 0)
				-- Add it to the blacklist, so it can't be hurt again.
				blackList.HitBlacklist[GetPtrHash(enemy)] = true

				-- Do some fancy effects, while we're at it.
				enemy:BloodExplode()
				enemy:MakeBloodPoof(enemy.Position, nil, 0.5)
				SFXManager():Play(SoundEffect.SOUND_MEATY_DEATHS)
				enemy:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
			end
		end
		for i, entity in pairs(Isaac.FindInCapsule(capsule, EntityPartition.BULLET)) do
			local projectile = entity:ToProjectile()
			if not projectile:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
				projectile:Die()
			end
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, AxeSpin, Mod.RepmTypes.EFFECT_SIMS_AXE)

Mod:AddCallback("SIM_AXE_DAMAGE_FLAGS", function(_, player)
	local flags = 0
	if player:HasCollectible(CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER) then
		flags = flags | DamageFlag.DAMAGE_SPAWN_COIN
	end
	for col, chance in pairs({
		[CollectibleType.COLLECTIBLE_BLOODY_LUST] = 0.14289,
		[CollectibleType.COLLECTIBLE_BLOOD_BAG] = 0.125,
		[CollectibleType.COLLECTIBLE_IMMACULATE_HEART] = 0.25,
	}) do
		if player:HasCollectible(col) and player:GetCollectibleRNG(col):RandomFloat() <= chance then
			flags = flags | DamageFlag.DAMAGE_SPAWN_RED_HEART
		end
	end
	return flags
end)

---@param Entity Entity
---@param DamageAmount number
---@param DamageFlags DamageFlag | integer
---@param DamageSource EntityRef
---@param DamageCountdownFrames integer
local function ExemptHalfCircle(_, Entity, DamageAmount, DamageFlags, DamageSource, DamageCountdownFrames)
	if
		DamageSource.Entity
		and DamageSource.Entity:ToEffect()
		and DamageSource.Entity.Variant == Mod.RepmTypes.EFFECT_SIMS_AXE
	then
		local parent = DamageSource.Entity:ToEffect().SpawnerEntity or DamageSource.Entity:ToEffect().Parent
		Isaac.RunCallback(
			"SIM_AXE_POST_TAKE_DMG",
			Entity,
			DamageFlags,
			DamageSource.Entity:ToEffect(),
			parent:ToPlayer()
		)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, ExemptHalfCircle)

---@param entity Entity
---@param flags DamageFlag | integer
---@param axe EntityEffect
---@param player EntityPlayer
Mod:AddCallback("SIM_AXE_POST_TAKE_DMG", function(_, entity, flags, axe, player)
	if player then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) then
			entity:AddPoison(EntityRef(player), 60, player.Damage)
		end

		if player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_LIGHT) then
			local eff = Isaac.Spawn(
				EntityType.ENTITY_EFFECT,
				EffectVariant.CRACK_THE_SKY,
				1,
				entity.Position,
				Vector.Zero,
				player
			)
				:ToEffect()
			eff.CollisionDamage = player.Damage * 3
		end
		if entity:HasMortalDamage() then
			if player:HasCollectible(CollectibleType.COLLECTIBLE_URANUS) then
				entity:AddEntityFlags(EntityFlag.FLAG_ICE)
			end
		end
	end
end)
