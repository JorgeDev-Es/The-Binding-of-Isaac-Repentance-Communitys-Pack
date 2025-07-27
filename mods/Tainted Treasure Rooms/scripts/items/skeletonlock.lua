local mod = TaintedTreasure
local game = Game()

mod.SkeletonLockStats = {
	[1] = {"Speed", 0.15, CacheFlag.CACHE_SPEED},
	[2] = {"Tears", 0.2, CacheFlag.CACHE_FIREDELAY},
	[3] = {"Damage", 0.5, CacheFlag.CACHE_DAMAGE},
	[4] = {"Range", 30, CacheFlag.CACHE_RANGE},
	[5] = {"ShotSpeed", 0.1, CacheFlag.CACHE_SHOTSPEED},
	[6] = {"Luck", 1, CacheFlag.CACHE_LUCK},
}

function mod:SkeletonLockOnUseKey(player, savedata) --Add random stats when opening a lock
    local rng = player:GetCollectibleRNG(TaintedCollectibles.SKELETON_LOCK)
    savedata.SkeletonLockBuffs = savedata.SkeletonLockBuffs or {}

    for i = 1, player:GetCollectibleNum(TaintedCollectibles.SKELETON_LOCK) do
        local roll = mod:RandomInt(1,6,rng)
        local stats = mod.SkeletonLockStats[roll]

        savedata.SkeletonLockBuffs[stats[1]] = savedata.SkeletonLockBuffs[stats[1]] or 0
        savedata.SkeletonLockBuffs[stats[1]] = savedata.SkeletonLockBuffs[stats[1]] + stats[2]
        --print(stats[1].." "..savedata.SkeletonLockBuffs[stats[1]])

        player:AddCacheFlags(stats[3])
        player:EvaluateItems()
    end
end

function mod:SkeletonLockKeyLimiting(player) --If more than 5 keys, yeet em!
    local keys = player:GetNumKeys()
    if keys > 5 and player.FrameCount % 5 == 0 then 
        if keys - 5 > 15 then --Spawn Key Rings to speed things up if they have over 20
            local key = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_KEY,KeySubType.KEY_DOUBLEPACK,player.Position,RandomVector()*mod:RandomInt(5,10),player)
            player:AddKeys(-2)
        else
            local key = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_KEY,KeySubType.KEY_NORMAL,player.Position,RandomVector()*mod:RandomInt(5,10),player)
            player:AddKeys(-1)
        end
    end
end

function mod:SkeletonLockKeyColl(pickup, player) --If you're at the key cap, you can't pick up keys!		
    if player:GetNumKeys() >= 5 and pickup.SubType ~= 2 then --TO-DO, add "IsKey" function that also checks for FF Spicy Key >:)
        return false
    end
end