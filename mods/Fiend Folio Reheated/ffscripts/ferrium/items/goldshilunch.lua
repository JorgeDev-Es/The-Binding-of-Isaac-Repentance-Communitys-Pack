local mod = FiendFolio

function mod:goldShiLunchUpdate(player, data)
    if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.GOLDSHI_LUNCH) then
        if data.GoldShipLunchCleared ~= not FiendFolio.IsActiveRoom() then
            player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_SHOTSPEED)
            player:EvaluateItems()
        end
    end
end