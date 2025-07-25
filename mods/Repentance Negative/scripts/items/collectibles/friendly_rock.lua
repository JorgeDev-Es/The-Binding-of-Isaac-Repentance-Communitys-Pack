local Mod = RepMMod

---@param rock GridEntityRock
Mod:AddCallback(ModCallbacks.MC_POST_GRID_ROCK_DESTROY, function(_, rock, type, immediate)
	local players = Mod.Filter(PlayerManager.GetPlayers(), function(_, player) return player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_FRIENDLY_ROCKS) end)
	if rock:ToRock() and rock:GetRNG():RandomFloat() <= 0.4 and #players > 0 then
		Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.DIP, DipSubType.PETRIFIED, rock.Position, Vector.Zero, players[rock:GetRNG():RandomInt(1, #players)])
	end
end)