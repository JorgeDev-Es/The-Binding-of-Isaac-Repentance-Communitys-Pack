local Mod = RepMMod

local function onCache(_, player, flag)
	if player:HasTrinket(Mod.RepmTypes.TRINKET_HAMMER) then
		player.TearFlags = player.TearFlags | TearFlags.TEAR_ACID
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCache, CacheFlag.CACHE_TEARFLAG)