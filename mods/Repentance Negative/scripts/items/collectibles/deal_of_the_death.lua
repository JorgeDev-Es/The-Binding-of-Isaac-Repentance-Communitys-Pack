local Mod = RepMMod

local function updateCache_Kozol(_, player, cacheFlag)
	if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_DEAL_OF_THE_DEATH) then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + 1
		end
		if cacheFlag == CacheFlag.CACHE_FLYING then
			player.CanFly = true
		end
		if cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = Mod.TearsUp(player.MaxFireDelay, 2)
		end
		if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed - 0.1
		end
		if cacheFlag == CacheFlag.CACHE_LUCK then
			player.Luck = player.Luck + 5
		end
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + 0.30
		end
		if cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, updateCache_Kozol)

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    Mod:AnyPlayerDo(function(player)
        if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_DEAL_OF_THE_DEATH) then
            player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
        end
    end)
end)

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, amount, flag)
	if
		ent:ToPlayer()
		and ent:ToPlayer():HasCollectible(Mod.RepmTypes.COLLECTIBLE_DEAL_OF_THE_DEATH)
		and flag & DamageFlag.DAMAGE_NO_PENALTIES == 0
	then
		ent:Kill()
	end
end, 1)