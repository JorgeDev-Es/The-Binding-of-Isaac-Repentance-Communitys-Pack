local Mod = RepMMod

local function onCuriousHeart(_, _, rng, player)
	--local rng = player:GetCollectibleRNG(Mod.RepmTypes.COLLECTIBLE_CURIOUS_HEART)
	local roll = rng:RandomInt(100)
	local Nearby = Isaac.GetFreeNearPosition(player.Position, 10)
	if roll < 25 then
		player:AnimateSad()
	elseif roll < 45 then
		Isaac.Spawn(
			EntityType.ENTITY_PICKUP,
			PickupVariant.PICKUP_HEART,
			HeartSubType.HEART_HALF,
			Nearby,
			Vector(0, 0),
			nil
		)
	elseif roll < 55 then
		Isaac.Spawn(
			EntityType.ENTITY_PICKUP,
			PickupVariant.PICKUP_HEART,
			HeartSubType.HEART_FULL,
			Nearby,
			Vector(0, 0),
			nil
		)
	elseif roll < 60 then
		Isaac.Spawn(
			EntityType.ENTITY_PICKUP,
			PickupVariant.PICKUP_HEART,
			HeartSubType.HEART_DOUBLEPACK,
			Nearby,
			Vector(0, 0),
			nil
		)
	elseif roll < 75 then
		Isaac.Spawn(
			EntityType.ENTITY_PICKUP,
			PickupVariant.PICKUP_HEART,
			HeartSubType.HEART_SOUL,
			Nearby,
			Vector(0, 0),
			nil
		)
	elseif roll < 90 then
		Isaac.Spawn(
			EntityType.ENTITY_PICKUP,
			PickupVariant.PICKUP_HEART,
			HeartSubType.HEART_BLACK,
			Nearby,
			Vector(0, 0),
			nil
		)
	else
		Isaac.Spawn(
			EntityType.ENTITY_PICKUP,
			PickupVariant.PICKUP_HEART,
			HeartSubType.HEART_ETERNAL,
			Nearby,
			Vector(0, 0),
			nil
		)
	end
	return {
		Discharge = true,
		Remove = false,
		ShowAnim = true,
	}
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, onCuriousHeart, Mod.RepmTypes.COLLECTIBLE_CURIOUS_HEART) -- , mod.Anm, Items.ID_Anm