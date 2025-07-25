local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local BLEED_DURATION = 90
local JAR_SHOTSPEED = 10

local function getClayJarDamage(player)
	return 18 + 4 * player:GetTrinketMultiplier(TrinketType.TRINKET_MODELING_CLAY)
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, collectible, rng, player, flag, slot, data)
	if player:GetItemState() == collectible then
		sfx:Play(SoundEffect.SOUND_URN_CLOSE, nil, nil, nil, 0.75)
		player:AnimateCollectible(collectible, "HideItem")
		player:ResetItemState()
	else
		sfx:Play(SoundEffect.SOUND_URN_OPEN, nil, nil, nil, 0.75)
		player:AnimateCollectible(collectible, "LiftItem")
		player:SetItemState(collectible)
	end
	return {Discharge = false}
end, mod.Collectible.CLAY_JAR)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	if player:GetItemState() == mod.Collectible.CLAY_JAR then
		local fireDirection = player:GetFireDirection()
		
		if fireDirection ~= Direction.NO_DIRECTION then
			local tearDir = Isaac.GetAxisAlignedUnitVectorFromDir(fireDirection)
			local tear = Isaac.Spawn(
				EntityType.ENTITY_TEAR, mod.Tear.CLAY_JAR, 0, 
				player.Position, tearDir:Resized(JAR_SHOTSPEED), player):ToTear()
			tear.CollisionDamage = getClayJarDamage(player)
			tear.Height = tear.Height - 30
			tear.FallingSpeed = tear.FallingSpeed - 10
			tear.FallingAcceleration = tear.FallingAcceleration + 1
			tear:AddVelocity(player:GetTearMovementInheritance(tear.Velocity))
			tear:AddTearFlags(TearFlags.TEAR_BOUNCE)
			tear.CanTriggerStreakEnd = false
			tear.Parent = player
			tear:Update()
			
			sfx:Play(SoundEffect.SOUND_SHELLGAME)
			sfx:Play(SoundEffect.SOUND_URN_CLOSE, nil, nil, nil, 0.9)
			sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
			
			player:DischargeActiveItem() -- Doesn't work as a pocket active (which is consistent with other similar actives lol)
			player:AnimateCollectible(mod.Collectible.CLAY_JAR, "HideItem")
			player:ResetItemState()
		end
	end
end)

----------------
-- << TEAR >> --
----------------
function mod.JarTearCollisionEffects(_, tear)
	sfx:Play(SoundEffect.SOUND_BONE_BOUNCE, 0.5, 5, nil, mod.RandomFloatRange(1, 1.2))
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_COLLISION, mod.JarTearCollisionEffects, mod.Tear.CLAY_JAR)
mod:AddCallback(ModCallbacks.MC_TEAR_GRID_COLLISION, mod.JarTearCollisionEffects, mod.Tear.CLAY_JAR)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, function(_, tear)
	local player = mod.GetPlayerFromEntity(tear)
	
	if player and player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then -- Book of Virtues synergy
		local fam = player:AddWisp(mod.Collectible.CLAY_JAR, tear.Position)
		
		fam:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
	end
	local effect = Isaac.Spawn(
		EntityType.ENTITY_EFFECT, mod.Effect.CLAY_JAR, 0, 
		tear.Position, Vector.Zero, tear):ToEffect()
	effect:SetSpriteFrame("Idle", mod.RandomIntRange(0, 1))
	effect.SortingLayer = SortingLayer.SORTING_BACKGROUND
	
	local effect = Isaac.Spawn(
		EntityType.ENTITY_EFFECT, EffectVariant.DUST_CLOUD, 0, 
		tear.Position, Vector.Zero, tear):ToEffect()
	effect:SetTimeout(mod.RandomIntRange(12, 21))
	effect.SpriteScale = Vector(1.2, 1.2)
	effect.Color = Color(1, 1, 1, 0.5)
	
	for effectIdx = 1, mod.RandomIntRange(2, 4) do
		local effect = Isaac.Spawn(
			EntityType.ENTITY_EFFECT, EffectVariant.POOP_PARTICLE, 0, 
			tear.Position, RandomVector() * mod.RandomFloatRange(1, 4), tear):ToEffect()
		effect:GetSprite():Load("gfx/effect_clayjargibs.anm2")
		effect:GetSprite():PlayRandom(effect.InitSeed)
		effect.SpriteRotation = RandomVector():GetAngleDegrees()
		effect.FallingSpeed = -mod.RandomFloatRange(8, 12)
	end
	sfx:Play(SoundEffect.SOUND_POT_BREAK_2, 0.8, nil, nil, 0.9)
end, mod.Tear.CLAY_JAR)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	local entityConfig = EntityConfig.GetEntity(effect.Type, effect.Variant, effect.SubType)
	
	for _, entity in pairs(Isaac.FindInCapsule(effect:GetCollisionCapsule(), EntityPartition.ENEMY)) do
		if mod.IsActiveVulnerableEnemy(entity) and not entity:IsFlying() then
			local damage = entityConfig:GetCollisionDamage()
			local countdown = entityConfig:GetCollisionInterval()
			
			entity:TakeDamage(damage, DamageFlag.DAMAGE_COUNTDOWN, EntityRef(effect), countdown)
			entity:AddBleeding(EntityRef(effect), BLEED_DURATION)
		end
	end
end, mod.Effect.CLAY_JAR)

----------------
-- << WISP >> --
----------------
mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_FIRE_PROJECTILE, function(_, tear)
	local fam = mod.GetFamiliarFromEntity(tear)
	
	if fam and fam.SubType == mod.Collectible.CLAY_JAR then
		tear.FallingSpeed = tear.FallingSpeed - 10
		tear.FallingAcceleration = tear.FallingAcceleration + 1
	end
end, FamiliarVariant.WISP)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam) -- Removes the BOV wisp, also MC_POST_FAMILIAR_NEW_ROOM when?
	if game:GetRoom():GetFrameCount() ~= 0 then return end
	
	if fam.SubType == mod.Collectible.CLAY_JAR then fam:RemoveFromPlayer() end
end, FamiliarVariant.WISP)