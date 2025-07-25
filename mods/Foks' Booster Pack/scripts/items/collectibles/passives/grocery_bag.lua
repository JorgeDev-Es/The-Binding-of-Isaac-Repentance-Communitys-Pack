local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local CAP_BONUS = 50
local GROCERY_SHOP_SUBTYPE = 150
local GROCERY_CHANCE = 0.2

mod:AddCallback(ModCallbacks.MC_EVALUATE_CUSTOM_CACHE, function(_, player, cache, value)
	if cache == "maxcoins" or cache == "maxbombs" or cache == "maxkeys" then
		return value + CAP_BONUS * player:GetCollectibleNum(mod.Collectible.GROCERY_BAG)
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, function(_, roomSlot, roomData, seed)
	if PlayerManager.AnyoneHasCollectible(mod.Collectible.GROCERY_BAG) then
		if roomData and roomData.Type == RoomType.ROOM_SHOP then
			return RoomConfigHolder.GetRandomRoom(seed, false, StbType.SPECIAL_ROOMS, RoomType.ROOM_SHOP, roomSlot:Shape(), nil, nil, nil, nil, roomSlot:DoorMask(), GROCERY_SHOP_SUBTYPE)
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup) -- Always replaces Grab Bags, Hearts, Bombs, Keys, Batteries, Pills and Cards have 20% chance to be replaced
	if PlayerManager.AnyoneHasCollectible(mod.Collectible.GROCERY_BAG) and pickup:IsShopItem() then
		if pickup.Variant == PickupVariant.PICKUP_GRAB_BAG or ((pickup.Variant == PickupVariant.PICKUP_HEART 
		or pickup.Variant == PickupVariant.PICKUP_KEY or pickup.Variant == PickupVariant.PICKUP_BOMB 
		or pickup.Variant == PickupVariant.PICKUP_PILL or pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY 
		or pickup.Variant == PickupVariant.PICKUP_TAROTCARD) and RNG(pickup.InitSeed):RandomFloat() <= GROCERY_CHANCE) 
		then
			local pickupSubType = game:GetItemPool():GetCollectible(mod.ItemPool.GROCERY_SHOP)
			
			pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, pickupSubType, true, true, true)
		end
	end
end)

--[[ -- Crashes with Tainted Keeper????
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function(_, collectible, charge, firstTime, slot, data, player)
	local level = game:GetLevel()
	local seed = level:GetDungeonPlacementSeed()
	local roomIdx = level:QueryRoomTypeIndex(RoomType.ROOM_SHOP, false, RNG(seed))
	local roomDesc = level:GetRoomByIdx(roomIdx)
	
	if roomDesc and roomDesc.Data and roomDesc.VisitedCount == 0 then
		roomDesc.Data = RoomConfigHolder.GetRandomRoom(seed, false, StbType.SPECIAL_ROOMS, roomDesc.Data.Type, roomDesc.Data.Shape, nil, nil, nil, nil, roomDesc.Data.Doors, GROCERY_SHOP_SUBTYPE)
	end
end, mod.Collectible.GROCERY_BAG)
--]]