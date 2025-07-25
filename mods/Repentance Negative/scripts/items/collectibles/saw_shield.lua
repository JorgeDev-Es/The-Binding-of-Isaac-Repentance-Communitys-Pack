local Mod = RepMMod

local shieldStates = {
	IDLE = 0,
	NO_BOUNCES = 1,
	BOUNCES = 2,
	RETURNING = 3,
}

local customShieldFlags = {
	[CollectibleType.COLLECTIBLE_BRIMSTONE] = TearFlags.TEAR_BRIMSTONE_BOMB,
	[CollectibleType.COLLECTIBLE_IPECAC] = TearFlags.TEAR_POISON | TearFlags.TEAR_EXPLOSIVE,
	[CollectibleType.COLLECTIBLE_TOXIC_SHOCK] = TearFlags.TEAR_POISON,
	[CollectibleType.COLLECTIBLE_FIRE_MIND] = TearFlags.TEAR_BURN,
	[CollectibleType.COLLECTIBLE_PYROMANIAC] = TearFlags.TEAR_BURN | TearFlags.TEAR_EXPLOSIVE,
	[CollectibleType.COLLECTIBLE_SPIDER_BITE] = TearFlags.TEAR_SLOW,
	[CollectibleType.COLLECTIBLE_SULFURIC_ACID] = TearFlags.TEAR_ACID,
	[CollectibleType.COLLECTIBLE_BALL_OF_TAR] = TearFlags.TEAR_GISH,
	[CollectibleType.COLLECTIBLE_MOMS_KNIFE] = TearFlags.TEAR_NEEDLE,
	[CollectibleType.COLLECTIBLE_MOMS_RAZOR] = TearFlags.TEAR_NEEDLE,
	[CollectibleType.COLLECTIBLE_RAZOR_BLADE] = TearFlags.TEAR_NEEDLE,
	[CollectibleType.COLLECTIBLE_LODESTONE] = TearFlags.TEAR_MAGNETIZE,
	[CollectibleType.COLLECTIBLE_STRANGE_ATTRACTOR] = TearFlags.TEAR_MAGNETIZE,
	[CollectibleType.COLLECTIBLE_EXPLOSIVO] = TearFlags.TEAR_EXPLOSIVE,
	[CollectibleType.COLLECTIBLE_TRINITY_SHIELD] = TearFlags.TEAR_SHIELDED,
	[CollectibleType.COLLECTIBLE_LOST_CONTACT] = TearFlags.TEAR_SHIELDED,
}

function Mod:AddCustomSawShieldFlag(collectible, flag)
	if not customShieldFlags[collectible] then
		customShieldFlags[collectible] = 0
	end
	customShieldFlags[collectible] = customShieldFlags[collectible] | flag
end

---@param player EntityPlayer
---@param cache CacheFlag | integer
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cache)
	local num = (player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_SAW_SHIELD) and player:GetData().HoldsSawShield == nil)
			and 1
		or 0
	player:CheckFamiliar(
		Mod.RepmTypes.FAMILIAR_SAW_SHIELD,
		num,
		player:GetCollectibleRNG(Mod.RepmTypes.COLLECTIBLE_SAW_SHIELD),
		Isaac.GetItemConfig():GetCollectible(Mod.RepmTypes.COLLECTIBLE_SAW_SHIELD)
	)
end, CacheFlag.CACHE_FAMILIARS)

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	for _, shield in ipairs(Isaac.FindByType(3, Mod.RepmTypes.FAMILIAR_SAW_SHIELD)) do
		shield:ToFamiliar().State = shieldStates.IDLE
		shield:ToFamiliar().FireCooldown = 0
		shield.PositionOffset.Y = 0
		shield.Velocity = Vector.Zero
		shield:GetSprite():Stop()
	end
end)

Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	if not Game():GetLevel():IsAscent() then
		return
	end
	for _, shield in ipairs(Isaac.FindByType(3, Mod.RepmTypes.FAMILIAR_SAW_SHIELD)) do
		shield:ToFamiliar().FireCooldown = 5
	end
end)

---@param fam EntityFamiliar
Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, fam)
	fam:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	fam:RemoveFromDelayed()
	fam:RemoveFromFollowers()
	fam:RemoveFromOrbit()
	fam.State = shieldStates.IDLE
	fam:GetSprite().PlaybackSpeed = 0
	local d = fam:GetData()
	d.Bounces = Mod.sawShieldBounces
	d.CollidesWithEntity = false
	d.Speed = d.Speed or 0
	d.ReturnCooldown = Mod.sawShieldReturnCooldown
	d.CustomShieldFlags = d.CustomShieldFlags or 0
	d.ThrowPlayer = d.ThrowPlayer or fam.Player
	fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
	fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
end, Mod.RepmTypes.FAMILIAR_SAW_SHIELD)

local function CollisionWithEntity(fam)
	return fam:GetData().CollidesWithEntity and 2 or 1
end

---@param shield EntityFamiliar
---@param player any
Mod:AddCallback("ON_SAW_SHIELD_UPDATE", function(shield, player)
	if shield.FrameCount % shield:GetDropRNG():RandomInt(2, 5) == 0 then
		local eff = Isaac.Spawn(
			EntityType.ENTITY_EFFECT,
			EffectVariant.PLAYER_CREEP_BLACK,
			0,
			shield.Position,
			Vector.Zero,
			shield
		):ToEffect()
		eff:GetSprite():Play("SmallBlood0" .. eff:GetDropRNG():RandomInt(1, 6), true)
		eff.Timeout = 90
		eff:SetTimeout(90)
	end
end, TearFlags.TEAR_GISH)

---@param fam EntityFamiliar
Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
	local sprite = fam:GetSprite()
	local d = fam:GetData()
	local player = d.ThrowPlayer or fam.Player
	fam.FireCooldown = math.max(0, fam.FireCooldown - 1)
	if d.CustomShieldFlags > 0 then
		for _, callback in pairs(Isaac.GetCallbacks("ON_SAW_SHIELD_UPDATE")) do
			if callback.Param > 0 and d.CustomShieldFlags & callback.Param > 0 then
				callback.Function(fam, player)
			end
		end
	end
	if fam.State ~= shieldStates.RETURNING then
		if fam.State ~= shieldStates.BOUNCES then
			d.Speed = math.max(0, d.Speed - 0.15)
			fam.PositionOffset.Y = Mod.Lerp(fam.PositionOffset.Y, 0, 0.03)
		end

		if fam.Velocity:Length() < 0.1 then
			d.ReturnCooldown = math.max(0, d.ReturnCooldown - 1)
			if fam.State ~= shieldStates.IDLE then
				fam.State = shieldStates.IDLE
			end
		end

		fam.Velocity = fam.Velocity:Resized(d.Speed / CollisionWithEntity(fam))
		sprite.PlaybackSpeed = math.min(1.5, d.Speed)
		if d.Bounces <= 0 and fam.State == shieldStates.BOUNCES then
			fam.State = shieldStates.NO_BOUNCES
		end
		if fam:CollidesWithGrid() then
			if fam.Velocity:Length() > 0.1 then
				SFXManager():Play(Mod.RepmTypes.SFX_SAW_SHIELD_BOUNCE, 0.7, 0)
			end
			if d.Bounces > 0 then
				d.Bounces = d.Bounces - 1
			else
				d.Speed = d.Speed * 0.85
			end
		end
		if d.ReturnCooldown <= 0 then
			fam.State = shieldStates.RETURNING
		end
	elseif fam.State == shieldStates.RETURNING then
		local speed = (player.Position - fam.Position):Resized(30)
		fam.Velocity = Mod.Lerp(fam.Velocity, speed, 0.1)
		fam.PositionOffset.Y = -math.max(0, fam.Velocity:Length())
		fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	end
	fam.CollisionDamage = (fam.State ~= shieldStates.IDLE and fam.State ~= shieldStates.RETURNING) and player.Damage * 2
		or 0
	d.CollidesWithEntity = false
end, Mod.RepmTypes.FAMILIAR_SAW_SHIELD)

---@param shield EntityFamiliar
---@param sprite Sprite
Mod:AddCallback("ON_SAW_SHIELD_RENDER", function(shield, sprite)
	sprite.Color:SetColorize(0, 1, 0, 1.2)
end, TearFlags.TEAR_POISON)

---@param shield EntityFamiliar
Mod:AddCallback("ON_SAW_SHIELD_INIT", function(shield)
	local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, Mod.RepmTypes.EFFECT_SAW_SHIELD_FIRE, 0, shield.Position, Vector.Zero, shield)
		:ToEffect()
	effect.Parent = shield
	effect:FollowParent(shield)
end, TearFlags.TEAR_BURN)

---@param effect EntityEffect
Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	local shield = effect.SpawnerEntity
	if not shield or shield:ToFamiliar() and (shield.Variant ~= Mod.RepmTypes.FAMILIAR_SAW_SHIELD) then
		effect:Remove()
		return
	end
	shield = shield:ToFamiliar()
	effect.SpriteRotation = shield.Velocity:Length() > 0.2 and (shield.Velocity):GetAngleDegrees()
		or Mod.Lerp(effect.SpriteRotation, 90, 0.2)
	effect.SpriteScale = Vector(1.5, 1.5)
	effect.DepthOffset = -1
	--effect.SpriteOffset = Vector(0, -5)
end, Mod.RepmTypes.EFFECT_SAW_SHIELD_FIRE)

---@param fam EntityFamiliar
Mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, function(_, fam, offset)
	local famSprite = fam:GetSprite()
	local d = fam:GetData()
	if d.CustomShieldFlags and d.CustomShieldFlags > 0 then
		for _, callback in pairs(Isaac.GetCallbacks("ON_SAW_SHIELD_RENDER")) do
			if callback.Param > 0 and d.CustomShieldFlags & callback.Param > 0 then
				callback.Function(fam, famSprite)
			end
		end
	end
end, Mod.RepmTypes.FAMILIAR_SAW_SHIELD)

---@param ent Entity
---@param damage integer
---@param flags DamageFlag | integer
---@param source EntityRef
---@param cd integer
Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function(_, ent, damage, flags, source, cd)
	if
		source
		and source.Entity
		and source.Entity.Type == EntityType.ENTITY_FAMILIAR
		and source.Entity.Variant == Mod.RepmTypes.FAMILIAR_SAW_SHIELD
	then
		SFXManager():Play(Mod.RepmTypes.SFX_SAW_SHIELD_DAMAGE, 1, 0)
		local shield = source.Entity:ToFamiliar()
		local player = shield:GetData().ThrowPlayer or shield.Player
		--ent:AddBleeding(source, 30)
		local d = shield:GetData()
		local shlFlags = d.CustomShieldFlags or 0
		local rng = RNG()
		rng:SetSeed(ent.InitSeed, 35)
		if shlFlags > 0 then
			for _, callback in pairs(Isaac.GetCallbacks("ON_SAW_SHIELD_HIT")) do
				if callback.Param > 0 and shlFlags & callback.Param > 0 then
					callback.Function(ent, rng, shield, player)
				end
			end
			if ent:HasMortalDamage() then
				for _, callback in ipairs(Isaac.GetCallbacks("ON_SAW_SHIELD_DEATH")) do
					if callback.Param > 0 and shlFlags & callback.Param > 0 then
						callback.Function(ent, rng, shield, player)
					end
				end
			end
		end
		if shield:GetDropRNG():RandomInt(25) == 1 then
			ent:AddBleeding(EntityRef(shield), 150)
		end
	end
end)

Mod:AddCallback("ON_SAW_SHIELD_HIT", function(entity, rng, shield, player)
	entity:AddPoison(EntityRef(player), 30, player.Damage / 4)
end, TearFlags.TEAR_POISON)

Mod:AddCallback("ON_SAW_SHIELD_HIT", function(entity, rng, shield, player)
	entity:AddSlowing(EntityRef(player), 30, 0.2, Color(0.3, 0.3, 0.3, 1))
end, TearFlags.TEAR_GISH)

Mod:AddCallback("ON_SAW_SHIELD_HIT", function(entity, rng, shield, player)
	entity:AddBurn(EntityRef(player), 30, player.Damage / 4)
end, TearFlags.TEAR_BURN)

Mod:AddCallback("ON_SAW_SHIELD_HIT", function(entity, rng, shield, player)
	entity:AddSlowing(EntityRef(player), 30, 0.5, Color(0.9, 0.9, 0.9, 1))
end, TearFlags.TEAR_SLOW)

Mod:AddCallback("ON_SAW_SHIELD_HIT", function(entity, rng, shield, player)
	entity:AddMagnetized(EntityRef(player), 30)
end, TearFlags.TEAR_MAGNETIZE)

Mod:AddCallback("ON_SAW_SHIELD_HIT", function(entity, rng, shield, player)
	entity:AddBleeding(EntityRef(player), 10)
end, TearFlags.TEAR_NEEDLE)

Mod:AddCallback("ON_SAW_SHIELD_DEATH", function(entity, rng, shield, player)
	if rng:RandomFloat() <= 0.1 then
		Isaac.Explode(entity.Position, player, 100)
		rng:Next()
	end
end, TearFlags.TEAR_EXPLOSIVE)

Mod:AddCallback("ON_SAW_SHIELD_DEATH", function(entity, rng, shield, player)
	if rng:RandomFloat() <= 0.2 then
		for _, angle in ipairs({ 0, 90, 180, 270 }) do
			local laser = EntityLaser.ShootAngle(
				LaserVariant.THICK_RED,
				entity.Position,
				angle,
				30,
				Vector.FromAngle(angle):Resized(10),
				player
			)
			laser.DisableFollowParent = true
		end
		rng:Next()
	end
end, TearFlags.TEAR_BRIMSTONE_BOMB)

Mod:AddCallback("ON_SAW_SHIELD_GRID_COLLISION", function(grid, rng, shield, player)
	if rng:RandomFloat() <= 0.2 then
		grid:Destroy(true)
	end
end, TearFlags.TEAR_ACID)

Mod:AddCallback("ON_SAW_SHIELD_COLLISION", function(shield, entity)
	if entity:ToProjectile() then
		entity:Die()
	end
end, TearFlags.TEAR_SHIELDED)

---@param fam EntityFamiliar
---@param gridIdx integer
---@param grid GridEntity
---@return boolean | nil
Mod:AddCallback(ModCallbacks.MC_FAMILIAR_GRID_COLLISION, function(_, fam, gridIdx, grid)
	if fam.Variant == Mod.RepmTypes.FAMILIAR_SAW_SHIELD then
		if
			grid
			and fam.Velocity:Length() > 0.1
			and fam.State < shieldStates.RETURNING
			and fam.State > shieldStates.IDLE
		then
			if grid:ToPoop() then
				grid:Hurt(4)
			end
			if grid:ToTNT() then
				grid:ToTNT():Destroy()
			end
			if fam:GetData().CustomShieldFlags and fam:GetData().CustomShieldFlags > 0 then
				for _, callback in ipairs(Isaac.GetCallbacks("ON_SAW_SHIELD_GRID_COLLISION")) do
					if callback.Param > 0 and fam:GetData().CustomShieldFlags & callback.Param > 0 then
						callback.Function(grid, fam:GetDropRNG(), fam, player)
					end
				end
			end
		end
	end
end)

---@param fam EntityFamiliar
---@param coll Entity
---@param low boolean
---@return boolean | nil
Mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, fam, coll, low)
	if coll then
		if coll:ToPlayer() then
			local player = coll:ToPlayer()
			---@cast player EntityPlayer
			if
				player:GetHeldEntity() == nil
				and not player:IsHoldingItem()
				and player:IsExtraAnimationFinished()
				and fam.FireCooldown <= 0
			then
				-- Isaac Rebalanced code part from Mom's Bracelet
				local helper = Isaac.Spawn(
					EntityType.ENTITY_EFFECT,
					EffectVariant.GRID_ENTITY_PROJECTILE_HELPER,
					0,
					fam.Position,
					Vector.Zero,
					player
				)
				helper.Parent = player
				local helperSp = helper:GetSprite()
				local famSp = fam:GetSprite()
				player:TryHoldEntity(helper)
				player:GetData().HoldsSawShield = {
					Type = 3,
					Variant = Mod.RepmTypes.FAMILIAR_SAW_SHIELD,
					Frame = famSp:GetFrame(),
				}
				helperSp:Load(famSp:GetFilename(), true)
				helperSp:SetFrame(famSp:GetAnimation(), famSp:GetFrame())
				helperSp.PlaybackSpeed = 0
				--helper.PositionOffset = fam.PositionOffset
				for i, layer in ipairs(helperSp:GetAllLayers()) do
					helperSp:ReplaceSpritesheet(i - 1, layer:GetSpritesheetPath())
				end
				helperSp:LoadGraphics()
				fam:Remove()
				SFXManager():Play(Mod.RepmTypes.SFX_PICKUP_SAW_SHIELD, 0.7, 0)
				return true
			end
		end
		fam:GetData().CollidesWithEntity = coll:IsEnemy()
			and coll:IsActiveEnemy()
			and coll:IsVulnerableEnemy()
			and fam.Velocity:Length() > 0.1
	end
end, Mod.RepmTypes.FAMILIAR_SAW_SHIELD)

---@param fam EntityFamiliar
---@param coll Entity
---@param low boolean
---@return boolean | nil
Mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, function(_, fam, coll, low)
	if coll then
		if fam:GetData().CustomShieldFlags and fam:GetData().CustomShieldFlags > 0 then
			for _, callback in ipairs(Isaac.GetCallbacks("ON_SAW_SHIELD_COLLISION")) do
				if callback.Param > 0 and fam:GetData().CustomShieldFlags & callback.Param > 0 then
					callback.Function(fam, coll)
				end
			end
		end
	end
end, Mod.RepmTypes.FAMILIAR_SAW_SHIELD)

---@param player EntityPlayer
---@param ent Entity
---@param vel Vector
Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_THROW, function(_, player, ent, vel)
	local d = player:GetData().HoldsSawShield
	if d ~= nil and d.Type == EntityType.ENTITY_FAMILIAR and d.Variant == Mod.RepmTypes.FAMILIAR_SAW_SHIELD then
		local shl = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, Mod.RepmTypes.FAMILIAR_SAW_SHIELD, 0, ent.Position, vel, player)
			:ToFamiliar()
		shl.FireCooldown = 40
		local shlData = shl:GetData()
		shl:GetSprite():SetFrame(d.Frame)
		player:GetData().HoldsSawShield = nil
		if vel:Length() > 0.2 then
			shlData.Speed = 17
			shl.State = shieldStates.BOUNCES
		else
			shlData.Speed = vel:Length()
			shl.State = shieldStates.NO_BOUNCES
		end
		shlData.ThrowPlayer = player
		shlData.CustomShieldFlags = 0

		if player:HasPlayerForm(PlayerForm.PLAYERFORM_BOB) then
			shlData.CustomShieldFlags = shlData.CustomShieldFlags | TearFlags.TEAR_POISON
		end

		for col, flag in pairs(customShieldFlags) do
			if player:HasCollectible(col) then
				shlData.CustomShieldFlags = shlData.CustomShieldFlags | flag
			end
		end
		if shlData.CustomShieldFlags > 0 then
			for _, callback in pairs(Isaac.GetCallbacks("ON_SAW_SHIELD_INIT")) do
				if callback.Param > 0 and shlData.CustomShieldFlags & callback.Param > 0 then
					callback.Function(shl)
				end
			end
		end
		shl.PositionOffset = ent.PositionOffset
		ent:Remove()
	end
end)