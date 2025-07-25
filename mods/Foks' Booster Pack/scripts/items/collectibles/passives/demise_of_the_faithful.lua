local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local BONE_HEART_NUM = 1
local DAMAGE_MULT = 1.3 -- Would grant +0.5 damage if it was possible
local TEAR_HEIGHT = -24
local PICKUP_NUM = 3

mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, function(_, collectible, charge, firstTime, slot, data, player)
	if firstTime then player:AddBoneHearts(BONE_HEART_NUM) end
end, mod.Collectible.DEMISE_OF_THE_FAITHFUL)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag)
	if player:HasCollectible(mod.Collectible.DEMISE_OF_THE_FAITHFUL) then -- Doesn't stack
		if flag & CacheFlag.CACHE_DAMAGE > 0 then
			player.Damage = player.Damage * DAMAGE_MULT
		end
		if flag & CacheFlag.CACHE_RANGE > 0 then
			player.TearHeight = player.TearHeight + TEAR_HEIGHT
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
	local player = mod.GetPlayerFromEntity(tear)
	
	if player and player:HasCollectible(mod.Collectible.DEMISE_OF_THE_FAITHFUL) then
		local variant = mod.GetBloodTearVariant(tear)
		
		if variant then tear:ChangeVariant(variant) end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	local itemNum = PlayerManager.GetNumCollectibles(mod.Collectible.DEMISE_OF_THE_FAITHFUL)
	local room = game:GetRoom()
	
	if itemNum > 0 and room:GetType() == RoomType.ROOM_BOSS and room:GetAliveBossesCount() <= 1 then
		if npc:IsBoss() and GetPtrHash(npc:GetLastParent()) == GetPtrHash(npc:GetLastChild()) then
			for pickupIdx = 1, PICKUP_NUM + itemNum - 1 do
				local pickupVel = EntityPickup.GetRandomPickupVelocity(npc.Position)
				
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_NULL, NullPickupSubType.NO_COLLECTIBLE_CHEST, npc.Position, pickupVel, npc)
			end
		end
	end
end)

-------------------
-- << COSTUME >> --
-------------------
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	if player:HasCollectible(mod.Collectible.DEMISE_OF_THE_FAITHFUL) then
		local costumeMap = player:GetCostumeLayerMap()
		local costumeDescs = player:GetCostumeSpriteDescs()
		
		for costumeLayer, costumeData in pairs(costumeMap) do
			if costumeData.costumeIndex ~= -1 and not costumeData.isBodyLayer then
				local costumeSprite = costumeDescs[costumeData.costumeIndex + 1]:GetSprite()
				
				costumeSprite.Offset.Y = -4 + math.sin(player.FrameCount * 0.1) * 2 + mod.Lerp(costumeSprite.Offset.Y, -player.Velocity.Y, 0.5)
				costumeSprite.Rotation = mod.Lerp(costumeSprite.Rotation, -player.Velocity.X * 2, 0.5)
			end
		end
	end
end)