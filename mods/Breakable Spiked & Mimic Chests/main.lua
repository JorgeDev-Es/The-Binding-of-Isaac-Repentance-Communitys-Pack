local Breakable_Spiked_And_Mimic_Chests = RegisterMod("Breakable Spiked & Mimic Chests",1)
local Mod = Breakable_Spiked_And_Mimic_Chests

--Repentance LUA API Docs: https://moddingofisaac.com/docs/rep/index.html

function Mod:checkBombExplosionEffectCollision(EntityEffect)
				
		local entities = Isaac.GetRoomEntities()
		
		for i, entity in ipairs(entities) do
		
			if entity.Type == EntityType.ENTITY_PICKUP 
			and (entity.Variant == PickupVariant.PICKUP_SPIKEDCHEST or entity.Variant == PickupVariant.PICKUP_MIMICCHEST)
			and entity.SubType == ChestSubType.CHEST_CLOSED then 
				
				if EntityEffect.Position:Distance(entity.Position) < 80 then	--80 is around 2 tiles of distance
					entity:ToPickup():TryOpenChest()
				end
				
			end
			
		end
		
		return nil
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, Mod.checkBombExplosionEffectCollision, EffectVariant.BOMB_EXPLOSION)






































