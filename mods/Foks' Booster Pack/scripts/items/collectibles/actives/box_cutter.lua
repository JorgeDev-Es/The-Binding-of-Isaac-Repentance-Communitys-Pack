local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local DAMAGE = 2 -- Full Heart Container

local function getRewardNum(player)
	local rewardNum = 6
	
	rewardNum = rewardNum + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BOX) * 2
	rewardNum = rewardNum + #player:GetMovingBoxContents() -- Hehe
	
	return rewardNum
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, collectible, rng, player, flag, slot, data)
	if player:GetMaxHearts() <= 0 then return end
	
	player:AddMaxHearts(-DAMAGE)
	player:TakeDamage(DAMAGE, DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_FAKE, EntityRef(player), 0)
	player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_ANEMIC)
	player:SpawnBloodEffect(3, nil, nil, nil, RandomVector():Resized(10))
	sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
	
	for pickupIdx = 1, getRewardNum(player) do
		local pickupVel = EntityPickup.GetRandomPickupVelocity(player.Position)
		
		if pickupIdx == 1 and player:HasCollectible(CollectibleType.COLLECTIBLE_CRACK_JACKS) then -- Thought it would be a neat interaction :3
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_NULL, player.Position, pickupVel, player)
		else
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_NULL, NullPickupSubType.NO_COLLECTIBLE_CHEST, player.Position, pickupVel, player)
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOX_OF_SPIDERS) then
			player:ThrowBlueSpider(player.Position, player.Position + RandomVector():Resized(80))
		end
	end
	for effectIdx = 1, 10 do
		local effectSubType = effectIdx <= 3 and 0 or 99
		local effectVel = RandomVector():Resized(8)
		
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, effectSubType, player.Position, effectVel, player)
	end
	return {ShowAnim = true}
end, mod.Collectible.BOX_CUTTER)