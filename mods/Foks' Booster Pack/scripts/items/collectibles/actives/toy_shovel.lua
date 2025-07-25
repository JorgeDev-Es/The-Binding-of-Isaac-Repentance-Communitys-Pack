local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local WISP_CHANCE = 0.25
local BONE_NUM = {4, 6} -- For the Forgotten unlock dirt patch

local function getTreasureChance(player)
	local room = game:GetRoom()
	local chance = 0.1
	
	local gridEntity = room:GetGridEntityFromPos(player.Position)
	if gridEntity and gridEntity:ToDecoration() then
		chance = chance + 0.4
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TREASURE_MAP) then
		chance = chance + 0.2
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BLUE_MAP) then
		chance = chance + 0.2
	end
	if room:GetType() ~= RoomType.ROOM_DEFAULT then -- Special rooms
		chance = chance + 0.1
	end
	return chance
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, collectible, rng, player, flag, slot, data)
	for _, entity in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.DIRT_PATCH)) do
		local effect = entity:ToEffect()
		
		if effect and effect.Position:Distance(player.Position) <= 20 and effect.State == 0 then
			effect.State = 1
			
			for _ = 1, mod.RandomIntRange(BONE_NUM[1], BONE_NUM[2]) do
				player:AddBoneOrbital(effect.Position)
			end
			return {ShowAnim = true}
		end
	end
	if rng:RandomFloat() <= getTreasureChance(player) then
		local pickupVel = EntityPickup.GetRandomPickupVelocity(player.Position)
		
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_NULL, NullPickupSubType.NO_COLLECTIBLE, player.Position, pickupVel, nil)
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) and rng:RandomFloat() <= WISP_CHANCE then -- Book of Virtues synergy
		local wispPicker = WeightedOutcomePicker()
		
		wispPicker:AddOutcomeFloat(CollectibleType.COLLECTIBLE_YUM_HEART, 1)
		wispPicker:AddOutcomeFloat(CollectibleType.COLLECTIBLE_WOODEN_NICKEL, 1)
		wispPicker:AddOutcomeFloat(CollectibleType.COLLECTIBLE_MR_BOOM, 1)
		wispPicker:AddOutcomeFloat(CollectibleType.COLLECTIBLE_SHARP_KEY, 1)
		wispPicker:AddOutcomeFloat(CollectibleType.COLLECTIBLE_MOMS_BOTTLE_OF_PILLS, 1)
		wispPicker:AddOutcomeFloat(CollectibleType.COLLECTIBLE_DECK_OF_CARDS, 1)
		wispPicker:AddOutcomeFloat(CollectibleType.COLLECTIBLE_SMELTER, 1)
		
		player:AddWisp(wispPicker:PickOutcome(rng), player.Position)
	end
	local effect = Isaac.Spawn(
		EntityType.ENTITY_EFFECT, EffectVariant.DIRT_PILE, 0, 
		player.Position, Vector.Zero, nil):ToEffect()
	effect:SetTimeout(30)
	sfx:Play(SoundEffect.SOUND_SHOVEL_DIG)
	
	return {ShowAnim = true}
end, mod.Collectible.TOY_SHOVEL)