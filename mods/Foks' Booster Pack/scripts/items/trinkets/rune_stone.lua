local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_POST_GRID_ROCK_DESTROY, function(_, rock, gridType, immediate)
	if gridType == GridEntityType.GRID_ROCKT or gridType == GridEntityType.GRID_ROCK_SS then
		for pickupIdx = 0, PlayerManager.GetTotalTrinketMultiplier(mod.Trinket.RUNE_STONE) - 1 do
			local pickupSubType = game:GetItemPool():GetCard(rock:GetSaveState().SpawnSeed + pickupIdx, false, false, true)
			local pickupVel = EntityPickup.GetRandomPickupVelocity(rock.Position)
			
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, pickupSubType, rock.Position, pickupVel, nil)
		end
	end
end)