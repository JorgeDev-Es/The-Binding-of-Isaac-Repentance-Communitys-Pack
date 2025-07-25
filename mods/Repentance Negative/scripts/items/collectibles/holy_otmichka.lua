local Mod = RepMMod
local game = Mod.Game

local function onUpdate_Otmichka(_, rng, spawnpos)
	local spawnpos = game:GetRoom():FindFreeTilePosition(spawnpos, 400)

	if PlayerManager.AnyoneHasCollectible(Mod.RepmTypes.COLLECTIBLE_HOLY_OTMICHKA) then
		if rng:RandomInt(1, 7) == 5 then
			Isaac.Spawn(
				EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_ETERNALCHEST,
				0,
				spawnpos, --Vector(320, 320),
				Vector(0, 0),
				nil
			)
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, onUpdate_Otmichka)