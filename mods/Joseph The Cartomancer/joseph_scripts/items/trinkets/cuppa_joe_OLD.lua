local CuppaJoe = {}

local enums = JosephMod.enums
local coffeya = enums.Trinkets.CUPPA_JOE

local originalDamage = 0
local originalFireDelay = 0
local originalRange = 0
local originalShotSpeed = 0
local originalSpeed = 0
local originalLuck = 0


TSIL.SaveManager.AddPersistentPlayerVariable(
    JosephMod,
    "CuppaJoeStatUp",
    {
        [1] = 0, --Damage
        [2] = 0, --FireDelay
        [3] = 0, --ShotSpeed
        [4] = 0, --Range
        [5] = 0, --Speed
        [6] = 0, --Luck
    },
    TSIL.Enums.VariablePersistenceMode.RESET_RUN,
    false
)


local checkStats = false
---@param player EntityPlayer
function CuppaJoe:PreItemPickup(item, charge, firstTime, slot, varData, player)
    if not player:HasTrinket(coffeya) then return end
    local itemConfig = Isaac.GetItemConfig():GetCollectible(item)
    local itemCache = itemConfig.CacheFlags
    if itemCache == 0 then return end
    local statCacheFlags = CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK

    if not (itemCache & statCacheFlags > 0) then return end
    
    originalDamage = player.Damage
    originalFireDelay = player.MaxFireDelay
    originalShotSpeed = player.ShotSpeed
    originalRange = player.TearRange
    originalSpeed = player.MoveSpeed
    originalLuck = player.Luck
    checkStats = true
end
JosephMod:AddCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, CuppaJoe.PreItemPickup)



---@param player EntityPlayer
function CuppaJoe:PostItemPickup(item, charge, firstTime, slot, varData, player)
    if not player:HasTrinket(coffeya) then return end
    if checkStats == false then return end
    checkStats = false

    local coffeyaStatUps = TSIL.SaveManager.GetPersistentPlayerVariable(JosephMod, "CuppaJoeStatUp", player)

    local damageDiff = player.Damage - originalDamage
    local fireDelayDiff = player.MaxFireDelay - originalFireDelay
    local rangeDiff = player.TearRange - originalRange
    local shotSpeedDiff = player.ShotSpeed - originalShotSpeed
    local speedDiff = player.MoveSpeed - originalSpeed
    local luckDiff = player.Luck - originalLuck

    -- print(damageDiff)
    -- print(fireDelayDiff)
    -- print(rangeDiff)
    -- print(shotSpeedDiff)
    -- print(speedDiff)
    -- print(luckDiff)
    

    if damageDiff + fireDelayDiff + rangeDiff + shotSpeedDiff + speedDiff + luckDiff == 0 then return end

    coffeyaStatUps[1] = coffeyaStatUps[1] + damageDiff
    coffeyaStatUps[2] = coffeyaStatUps[2] + fireDelayDiff
    coffeyaStatUps[3] = coffeyaStatUps[3] + shotSpeedDiff
    coffeyaStatUps[4] = coffeyaStatUps[4] + rangeDiff
    coffeyaStatUps[5] = coffeyaStatUps[5] + speedDiff
    coffeyaStatUps[6] = coffeyaStatUps[6] + luckDiff


    TSIL.SaveManager.SetPersistentPlayerVariable(JosephMod, "CuppaJoeStatUp", player, coffeyaStatUps)
    checkStats = false

    originalDamage = 0
    originalFireDelay = 0
    originalRange = 0
    originalShotSpeed = 0
    originalSpeed = 0
    originalLuck = 0

    player:TryRemoveTrinket(coffeya)
    player:AddCacheFlags(CacheFlag.CACHE_ALL, true)

end
JosephMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, CuppaJoe.PostItemPickup)



---@param player EntityPlayer
---@cache CacheFlag
function CuppaJoe:AddStats(player, cache)
    local joeStatUps = TSIL.SaveManager.GetPersistentPlayerVariable(JosephMod, "CuppaJoeStatUp", player)

    if cache == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + joeStatUps[1]

    elseif cache == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = player.MaxFireDelay + joeStatUps[2]

    elseif cache == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + joeStatUps[3]

    elseif cache == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange + joeStatUps[4]

    elseif cache == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + joeStatUps[5]

    elseif cache == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + joeStatUps[6]

    end

end
JosephMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, CuppaJoe.AddStats)
