local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local SHARD_SHOTSPEED = 18
local SHARD_DAMAGE = 5
local SHARD_DAMAGE_MULT = 5
local SHARD_BLEED_DURATION = 90 -- 3 seconds
local pickupSprite = Sprite("gfx/pickup_mirrorshard.anm2")
pickupSprite:Play("Idle")

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	if pickup:GetSprite():IsEventTriggered("DropSound") then
		sfx:Play(SoundEffect.SOUND_BONE_BOUNCE, nil, nil, nil, 2)
	end
end, mod.Pickup.MIRROR_SHARD)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local player = collider:ToPlayer()
	
	if player and player:CanPickupItem() and not player:IsHoldingItem() then
		player:GetEffects():AddCollectibleEffect(mod.Collectible.CRACKED_MIRROR, false)
		
		pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		pickup:GetSprite():Play("Collect", true)
		pickup:Die()
		
		sfx:Play(SoundEffect.SOUND_SCYTHE_BREAK, nil, nil, nil, 2)
		
		return true
	end
end, mod.Pickup.MIRROR_SHARD)

------------------
-- << PLAYER >> --
------------------
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	local playerFx = player:GetEffects()
	
	if playerFx:HasCollectibleEffect(mod.Collectible.CRACKED_MIRROR) then
		local fireDirection = player:GetFireDirection()
		
		if fireDirection ~= Direction.NO_DIRECTION then
			local tearDir = Isaac.GetAxisAlignedUnitVectorFromDir(fireDirection)
			local tear = Isaac.Spawn(
				EntityType.ENTITY_TEAR, mod.Tear.MIRROR_SHARD, 0, 
				player.Position, tearDir:Resized(SHARD_SHOTSPEED), player):ToTear()
			tear:AddVelocity(player:GetTearMovementInheritance(tear.Velocity))
			tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL)
			tear.CollisionDamage = SHARD_DAMAGE + player.Damage * SHARD_DAMAGE_MULT
			tear.CanTriggerStreakEnd = false
			tear.Parent = player
			tear:Update()
			
			sfx:Play(SoundEffect.SOUND_SHELLGAME)
			sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
			
			player:AnimatePickup(pickupSprite, nil, "HideItem")
			playerFx:RemoveCollectibleEffect(mod.Collectible.CRACKED_MIRROR, -1)
		end
		if player:CanPickupItem() and not player:IsHoldingItem() then
			player:AnimatePickup(pickupSprite, nil, "LiftItem")
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, collectible, rng, player, flag, slot, data)
	local playerFx = player:GetEffects()
	
	if playerFx:HasCollectibleEffect(mod.Collectible.CRACKED_MIRROR) then
		playerFx:RemoveCollectibleEffect(mod.Collectible.CRACKED_MIRROR, -1)
	end
end)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, card, player, flag)
	local playerFx = player:GetEffects()
	
	if playerFx:HasCollectibleEffect(mod.Collectible.CRACKED_MIRROR) then
		playerFx:RemoveCollectibleEffect(mod.Collectible.CRACKED_MIRROR, -1)
	end
end)

mod:AddCallback(ModCallbacks.MC_USE_PILL, function(_, pill, player, flag)
	local playerFx = player:GetEffects()
	
	if playerFx:HasCollectibleEffect(mod.Collectible.CRACKED_MIRROR) then
		playerFx:RemoveCollectibleEffect(mod.Collectible.CRACKED_MIRROR, -1)
	end
end)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flag, source, countdown)
	local player = entity:ToPlayer()
	
	if player then
		local playerFx = player:GetEffects()
		
		if playerFx:HasCollectibleEffect(mod.Collectible.CRACKED_MIRROR) then
			playerFx:RemoveCollectibleEffect(mod.Collectible.CRACKED_MIRROR, -1)
		end
	end
end, EntityType.ENTITY_PLAYER)

----------------
-- << TEAR >> --
----------------
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
	local tearAngle = tear.Velocity:GetAngleDegrees() - 90
	
	tear.Rotation = tearAngle
	tear.SpriteRotation = tearAngle
end, mod.Tear.MIRROR_SHARD)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_COLLISION, function(_, tear, collider)
	local npc = collider:ToNPC()
	
	if npc and not npc:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) and npc:GetBossStatusEffectCooldown() <= 0 then
		npc:AddBleeding(EntityRef(tear), SHARD_BLEED_DURATION)
	end
end, mod.Tear.MIRROR_SHARD)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, function(_, tear)
	local effect = Isaac.Spawn(
		EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, 
		tear.Position, Vector.Zero, tear):ToEffect()
	effect.SpriteScale = effect.SpriteScale * 0.75
	effect:Update()
	
	sfx:Play(mod.Sound.GLASS_BREAK)
end, mod.Tear.MIRROR_SHARD)