local Mod = RepMMod

local function updateCache_Buter(_, player, cacheFlag)
	if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_SANDWICH) then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + 0.5
		end
		if cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = Mod.TearsUp(player.MaxFireDelay, 0.35)
		end
		if cacheFlag == CacheFlag.CACHE_TEARFLAG then
			if math.random(1, 5) == 4 then
				player.TearFlags = player.TearFlags | TearFlags.TEAR_BAIT
				if math.random(1, 5) == 3 then
					player.TearFlags = player.TearFlags | TearFlags.TEAR_POISON
				end
			end
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, updateCache_Buter)
