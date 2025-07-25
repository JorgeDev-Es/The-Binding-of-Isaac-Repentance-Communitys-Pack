local RottenFlesh = {}

CollectibleType.COLLECTIBLE_ROTTEN_FLESH = Isaac.GetItemIdByName("Cadaver's Left Eye")

local DAMAGE_UP = 2

function RottenFlesh.ModifyStats(player, cacheFlag)
  if player:HasCollectible(CollectibleType.COLLECTIBLE_ROTTEN_FLESH) then
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
      player.Damage = player.Damage + DAMAGE_UP
    end
  end
end

return RottenFlesh
