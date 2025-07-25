local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, amount, flag, source, countdown)
	local player = entity:ToPlayer()
	
	if player and flag & (DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NO_PENALTIES) == 0 then
		if player:HasGoldenTrinket(mod.Trinket.WHITE_FLAG) then
			local pickup = Isaac.Spawn(
				EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, mod.Trinket.WHITE_FLAG | TrinketType.TRINKET_GOLDEN_FLAG, 
				player.Position, Vector.Zero, player):ToPickup()
			pickup.Touched = true
			
			player:TryRemoveTrinket(mod.Trinket.WHITE_FLAG | TrinketType.TRINKET_GOLDEN_FLAG)
			player:UseCard(Card.CARD_STARS, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
			
			return false
		elseif player:HasTrinket(mod.Trinket.WHITE_FLAG) then
			local pickup = Isaac.Spawn(
				EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, mod.Trinket.WHITE_FLAG, 
				player.Position, Vector.Zero, player):ToPickup()
			pickup.Touched = true -- Just in case
			
			player:TryRemoveTrinket(mod.Trinket.WHITE_FLAG)
			player:UseCard(Card.CARD_FOOL, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
			
			return false
		end
	end
end, EntityType.ENTITY_PLAYER)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	if pickup.SubType & ~TrinketType.TRINKET_GOLDEN_FLAG == mod.Trinket.WHITE_FLAG then
		if not game:GetRoom():IsClear() then return false end
	end
end, PickupVariant.PICKUP_TRINKET)