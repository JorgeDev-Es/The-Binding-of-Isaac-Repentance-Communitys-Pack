local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local PICKUP_NUM = 2

mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function(_, collectible, charge, firstTime, slot, data, player)
	if not firstTime then return end
	local pickupPos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true)
	
	Isaac.Spawn(EntityType.ENTITY_PICKUP, mod.Pickup.PLASTIC_BRICK, 0, pickupPos, Vector.Zero, player)
end, mod.Collectible.PLASTIC_BRICK)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	local player = PlayerManager.FirstCollectibleOwner(mod.Collectible.PLASTIC_BRICK)
	local room = game:GetRoom()
	
	if player and room:IsFirstVisit() then
		for pickupIdx = 1, RNG(room:GetSpawnSeed()):RandomInt(PICKUP_NUM + 1) do
			local pickupPos = room:FindFreePickupSpawnPosition(Isaac.GetRandomPosition(), nil, true)
			
			Isaac.Spawn(EntityType.ENTITY_PICKUP, mod.Pickup.PLASTIC_BRICK, 0, pickupPos, Vector.Zero, player)
		end
	end
end)