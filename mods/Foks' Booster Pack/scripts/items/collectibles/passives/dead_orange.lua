local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local ROTTEN_HEART_NUM = 4
local FIRERATE = 0.5

mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function(_, collectible, charge, firstTime, slot, data, player)
	if firstTime then player:AddRottenHearts(ROTTEN_HEART_NUM) end
end, mod.Collectible.DEAD_ORANGE)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
	player.MaxFireDelay = mod.AddTears(player.MaxFireDelay, FIRERATE * player:GetCollectibleNum(mod.Collectible.DEAD_ORANGE))
end, CacheFlag.CACHE_FIREDELAY)

mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	if PlayerManager.AnyoneHasCollectible(mod.Collectible.DEAD_ORANGE) then
		local room = game:GetRoom()
		
		if room:GetType() == RoomType.ROOM_BOSS and room:GetAliveBossesCount() <= 1 then
			if npc:IsBoss() and GetPtrHash(npc:GetLastParent()) == GetPtrHash(npc:GetLastChild()) then
				local pickupVel = EntityPickup.GetRandomPickupVelocity(npc.Position)
				local pickup = Isaac.Spawn(
					EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN, 
					npc.Position, pickupVel, npc):ToPickup()
			end
		end
	end
end)