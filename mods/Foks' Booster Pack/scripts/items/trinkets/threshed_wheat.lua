local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local PLAYER_KNOCKBACK_STRENGTH = 4
local ENEMY_KNOCKBACK_STRENGTH = 12
local PROP_KNOCKBACK_STRENGTH = 20
local KNOCKBACK_DURATION = 3
local COOLDOWN = 60 -- Every second
local DAMAGE = 1.5

local pickupBlasklist = {
	[PickupVariant.PICKUP_COLLECTIBLE] = true,
	[PickupVariant.PICKUP_SHOPITEM] = true,
	[PickupVariant.PICKUP_BROKEN_SHOVEL] = true,
	[PickupVariant.PICKUP_BIGCHEST] = true,
	[PickupVariant.PICKUP_TROPHY] = true,
	[PickupVariant.PICKUP_BED] = true,
	[PickupVariant.PICKUP_MOMSCHEST] = true,
}

mod:AddCallback(ModCallbacks.MC_POST_WEAPON_FIRE, function(_, weapon, direction, isShooting, isInterpolated)
	local player = weapon:GetOwner() and weapon:GetOwner():ToPlayer()
	if not player then return end
	
	local playerData = mod.GetEntityData(player)
	local trinketMult = player:GetTrinketMultiplier(mod.Trinket.THRESHED_WHEAT)
	
	if trinketMult > 0 and isShooting and not playerData.WheatCooldown then
		local effect = Isaac.Spawn(
			EntityType.ENTITY_EFFECT, mod.Effect.WHEAT, 0, 
			player.Position, Vector.Zero, player):ToEffect()
		effect.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		effect:FollowParent(player)
		effect.ParentOffset = direction:Resized(4)
		effect.SpriteRotation = direction:GetAngleDegrees() - 90
		effect.SpriteOffset = Vector(0, -4)
		effect:GetSprite():Play("Swing")
		
		sfx:Play(SoundEffect.SOUND_BIRD_FLAP)
		playerData.WheatCooldown = COOLDOWN // trinketMult
	end
	if playerData.WheatCooldown then
		playerData.WheatCooldown = playerData.WheatCooldown - 1
		
		if playerData.WheatCooldown <= 0 then
			playerData.WheatCooldown = nil
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	local player = effect.Parent and effect.Parent:ToPlayer()
	if not player then return end
	
	local effectConfig = EntityConfig.GetEntity(effect.Type, effect.Variant, effect.SubType)
	local effectHitbox = effect:GetNullCapsule("hitbox")
	local effectData = mod.GetEntityData(effect)
	effectData.HitList = effectData.HitList or {}
	
	if game:GetDebugFlags() & DebugFlag.HITSPHERES > 0 then
		DebugRenderer.Get(effect.InitSeed, true):Capsule(effectHitbox)
	end
	
	local gridEntity = game:GetRoom():GetGridEntityFromPos(effectHitbox:GetPosition()) -- Middle point
	if gridEntity then gridEntity:Hurt(1) end
	
	local pointNum = effectConfig:GetGridCollisionPoints()
	for pointIdx = 0, pointNum - 1 do
		local pointRadius = Vector.FromAngle(pointIdx * (360 / pointNum)):Resized(effectHitbox:GetF1())
		local gridEntity = game:GetRoom():GetGridEntityFromPos(effectHitbox:GetPosition() + pointRadius)
		
		if gridEntity then gridEntity:Hurt(1) end
	end
	
	for _, entity in pairs(Isaac.FindInCapsule(effectHitbox, EntityPartition.BULLET)) do -- Block projectiles
		if entity and entity:ToProjectile() then entity:Die() end
	end
	for _, entity in pairs(Isaac.FindInCapsule(effectHitbox, EntityPartition.PICKUP)) do -- Collect and push pickups
		if entity then
			local pickup = entity:ToPickup()
			
			if pickup and not pickupBlasklist[pickup.Variant] and not pickup:IsShopItem() then
				if not effectData.HitList[GetPtrHash(pickup)] and not player:ForceCollide(pickup) then
					local knockbackVelocity = (pickup.Position - effect.Position):Resized(PROP_KNOCKBACK_STRENGTH)
					
					pickup:AddKnockback(EntityRef(player), knockbackVelocity, KNOCKBACK_DURATION, false)
					effectData.HitList[GetPtrHash(pickup)] = true
				end
			end
		end
	end
	for _, entity in pairs(Isaac.FindInCapsule(effectHitbox, EntityPartition.ENEMY)) do -- Damage enemies and destroy obstacles
		if entity then
			if entity.Type == EntityType.ENTITY_FIREPLACE 
			or entity.Type == EntityType.ENTITY_MOVABLE_TNT 
			or entity.Type == EntityType.ENTITY_POOP 
			then
				entity:TakeDamage(1, 0, EntityRef(player), 0)
			end
			if not effectData.HitList[GetPtrHash(entity)] then
				if entity:IsVulnerableEnemy() and entity:IsActiveEnemy() then
					local knockbackVelocity = (entity.Position - effect.Position):Resized(ENEMY_KNOCKBACK_STRENGTH)
					local damage = DAMAGE + player.Damage
					
					if entity.HitPoints > damage then -- Imitates the Forgotten's Bone Club
						local playerKnockbackVelocity = (player.Position - entity.Position):Resized(PLAYER_KNOCKBACK_STRENGTH)
						
						player:AddKnockback(EntityRef(entity), playerKnockbackVelocity, KNOCKBACK_DURATION, false)
					end
					sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, nil, nil, nil, 1.5)
					entity:TakeDamage(damage, 0, EntityRef(player), 0)
					entity:AddKnockback(EntityRef(player), knockbackVelocity, KNOCKBACK_DURATION, false)
					effectData.HitList[GetPtrHash(entity)] = true
				end
				if entity:ToBomb() then
					local knockbackVelocity = (entity.Position - effect.Position):Resized(PROP_KNOCKBACK_STRENGTH)
					
					entity:AddKnockback(EntityRef(player), knockbackVelocity, KNOCKBACK_DURATION, false)
					effectData.HitList[GetPtrHash(entity)] = true
				end
			end
		end
	end
	if effect:GetSprite():IsFinished("Swing") then
		effect:Remove()
	end
end, mod.Effect.WHEAT)