local Mod = RepMMod

local function collideItemPedestalAbs(_, pickup, collider, low)
	local player = collider:ToPlayer()
	if
		player
		and Isaac.GetChallenge() == Mod.RepmChallenges.CHALLENGE_LOCUST_KING
		and pickup.SubType ~= 0
		and not Isaac.GetItemConfig():GetCollectible(pickup.SubType):HasTags(ItemConfig.TAG_QUEST)
		and pickup.SubType ~= CollectibleType.COLLECTIBLE_MORE_OPTIONS
	then
		SFXManager():Play(SoundEffect.SOUND_FART, 2)
		local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
		local pickupindex = pickup:ToPickup().OptionsPickupIndex
		for i, item in ipairs(items) do
			if item:ToPickup().OptionsPickupIndex == pickupindex and pickupindex ~= 0 then
				item:Remove()
			end
		end
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector(0, 0), nil)
		pickup:Remove()
		return true
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, collideItemPedestalAbs, PickupVariant.PICKUP_COLLECTIBLE)

local function onLevelStart_Locust()
	if Isaac.GetChallenge() == Mod.RepmChallenges.CHALLENGE_LOCUST_KING then
		local itemHere = Isaac.Spawn(
			EntityType.ENTITY_PICKUP,
			PickupVariant.PICKUP_HEART,
			HeartSubType.HEART_BONE,
			Vector(160, 225),
			Vector.Zero,
			nil
		)
		itemHere:ToPickup().ShopItemId = -1
		itemHere:ToPickup().AutoUpdatePrice = false
		itemHere:ToPickup().Price = 4

		if not PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_APOLLYONS_BEST_FRIEND) then
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_TRINKET,
				TrinketType.TRINKET_APOLLYONS_BEST_FRIEND,
				Vector(480, 225),
				Vector.Zero,
				nil
			)
		elseif not PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_LOCUST_OF_FAMINE) then
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_TRINKET,
				TrinketType.TRINKET_LOCUST_OF_FAMINE,
				Vector(480, 225),
				Vector.Zero,
				nil
			)
		elseif not PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_LOCUST_OF_PESTILENCE) then
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_TRINKET,
				TrinketType.TRINKET_LOCUST_OF_PESTILENCE,
				Vector(480, 225),
				Vector.Zero,
				nil
			)
		elseif not PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_LOCUST_OF_WRATH) then
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_TRINKET,
				TrinketType.TRINKET_LOCUST_OF_WRATH,
				Vector(480, 225),
				Vector.Zero,
				nil
			)
		elseif not PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_LOCUST_OF_DEATH) then
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_TRINKET,
				TrinketType.TRINKET_LOCUST_OF_DEATH,
				Vector(480, 225),
				Vector.Zero,
				nil
			)
		elseif not PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_LOCUST_OF_CONQUEST) then
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_TRINKET,
				TrinketType.TRINKET_LOCUST_OF_CONQUEST,
				Vector(480, 225),
				Vector.Zero,
				nil
			)
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, onLevelStart_Locust)

local function ChallengeMarblesInit(_, player)
	if player and Isaac.GetChallenge() == Mod.RepmChallenges.CHALLENGE_LOCUST_KING then
		player:AddCollectible(CollectibleType.COLLECTIBLE_MARBLES, 0, false)
	end
end
Mod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, ChallengeMarblesInit)
