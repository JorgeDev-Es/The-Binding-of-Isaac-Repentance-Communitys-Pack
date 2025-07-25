local Mod = RepMMod

local function updateCache_FlowTea(_, player, cacheFlag)
	if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_FLOWER_TEA) then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + 0.60
		end
		if cacheFlag == CacheFlag.CACHE_RANGE then
			player.TearRange = player.TearRange + 40 * 0.5
		end
		if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed - 0.20
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, updateCache_FlowTea)