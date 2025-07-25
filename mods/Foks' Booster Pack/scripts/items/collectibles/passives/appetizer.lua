local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local HEALTH_LIMIT = 2
local SPEED = -0.03
local RANGE = 100 -- 2.5
local LUCK = 1

mod:AddCallback(ModCallbacks.MC_PLAYER_GET_HEART_LIMIT, function(_, player, limit, isKeeper)
	return limit + HEALTH_LIMIT * player:GetCollectibleNum(mod.Collectible.APPETIZER)
end)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flag) -- Binge Eater synergy
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) then
		local itemNum = player:GetCollectibleNum(mod.Collectible.APPETIZER)
		
		if flag & CacheFlag.CACHE_SPEED > 0 then
			player.MoveSpeed = player.MoveSpeed + SPEED * itemNum
		end
		if flag & CacheFlag.CACHE_RANGE > 0 then
			player.TearRange = player.TearRange + RANGE * itemNum
		end
		if flag & CacheFlag.CACHE_LUCK > 0 then
			player.Luck = player.Luck + LUCK * itemNum
		end
	end
end)