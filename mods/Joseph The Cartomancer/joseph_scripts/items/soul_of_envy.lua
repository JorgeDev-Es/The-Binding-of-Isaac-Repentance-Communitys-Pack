local SoulOfEnvy = {}
local mod = JosephMod

local enums = JosephMod.enums
local utility = JosephMod.utility

local SOUL_OF_ENVY = enums.Collectibles.SOUL_OF_ENVY


local oldBombCount
local oldKeyCount
local oldCoinCount

---@param player EntityPlayer
function SoulOfEnvy:Update(player)
    if not player:HasCollectible(SOUL_OF_ENVY) then return end
    local bombCount = player:GetNumBombs()
    local keyCount = player:GetNumKeys()
    local coinCount = player:GetNumCoins()

    if oldBombCount and oldBombCount ~= bombCount then
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
    end

    if oldKeyCount and oldKeyCount ~= keyCount then
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
    end

    if oldCoinCount and oldCoinCount ~= coinCount then
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
    end

    oldBombCount = bombCount
    oldKeyCount = keyCount
    oldCoinCount = coinCount

end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, SoulOfEnvy.Update)

function SoulOfEnvy:Start()
    oldBombCount = 0
    oldKeyCount = 0
    oldCoinCount = 0
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, SoulOfEnvy.Start)

---@param player EntityPlayer
function SoulOfEnvy:Cache(player, flag)
    if flag ~= CacheFlag.CACHE_DAMAGE then return end
    if not player:HasCollectible(SOUL_OF_ENVY) then return end
    
    local bombDMG = math.max(0, 5 - player:GetNumBombs()) * 0.2
    local keyDMG = math.max(0, 5 - player:GetNumKeys()) * 0.2
    local coinDMG = math.max(0, 15 - player:GetNumCoins()) * 0.0666
    utility:AddDamage(player, bombDMG + keyDMG + coinDMG)

end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SoulOfEnvy.Cache)

