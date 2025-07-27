local mod = TaintedTreasure
local game = Game()

mod.NoOptionsBlacklist = {
    [CollectibleType.COLLECTIBLE_POLAROID] = true,
    [CollectibleType.COLLECTIBLE_NEGATIVE] = true,
    [CollectibleType.COLLECTIBLE_DADS_NOTE] = true,
}

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, collectible)
	if mod:GetPlayersHoldingCollectible(TaintedCollectibles.NO_OPTIONS) and game:GetRoom():GetType() == RoomType.ROOM_BOSS and not mod.NoOptionsBlacklist[collectible.SubType] then
        for _, player in pairs(mod:GetAllPlayers()) do
            local savedata = mod.GetPersistentPlayerData(player)
            savedata.NoOptionsDamage = savedata.NoOptionsDamage or 0
            savedata.NoOptionsDamage = savedata.NoOptionsDamage + (0.8 * mod:GetTotalCollectibleNum(TaintedCollectibles.NO_OPTIONS))
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
            player:AnimateHappy()
        end
        collectible.Visible = false
        collectible:Remove()
	end
end, PickupVariant.PICKUP_COLLECTIBLE)