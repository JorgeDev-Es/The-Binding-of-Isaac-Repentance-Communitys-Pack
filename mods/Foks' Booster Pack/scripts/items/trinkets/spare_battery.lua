local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local BATTERY_CHANCE = 0.05
local microBatteryAmount = {
	[BatterySubType.BATTERY_NORMAL] = 3, -- 6 charges
	[BatterySubType.BATTERY_MEGA] = 6, -- 12 charges (not including overcharge, may prove to be more or less useful depending on the item's charge)
	[BatterySubType.BATTERY_GOLDEN] = 3, -- 6 charges
}

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	if PlayerManager.AnyoneHasTrinket(mod.Trinket.SPARE_BATTERY) then
		local batteryAmount = microBatteryAmount[pickup.SubType]
		
		if not pickup:IsDead() and not pickup:IsShopItem() and batteryAmount then
			for _ = 1, batteryAmount do
				local pickupVel = pickup.Velocity + EntityPickup.GetRandomPickupVelocity(pickup.Position) * 0.3
				
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO, pickup.Position, pickupVel, pickup)
			end
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, pickup)
			pickup:Remove()
		end
	end
end, PickupVariant.PICKUP_LIL_BATTERY)

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function(_, rng, pos)
	local trinketMult = PlayerManager.GetTotalTrinketMultiplier(mod.Trinket.SPARE_BATTERY)
	
	if trinketMult > 0 and rng:RandomFloat() <= BATTERY_CHANCE * trinketMult then
		local pickupPos = game:GetRoom():FindFreePickupSpawnPosition(pos)
		
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, 0, pickupPos, Vector.Zero, nil)
	end
end)