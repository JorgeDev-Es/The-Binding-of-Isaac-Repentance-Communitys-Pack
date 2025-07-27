



local creditcardmod = RegisterMod("Mom's Debit Card", 1)
creditcardmod.SOUND_MOM_CARD = Isaac.GetSoundIdByName("cash sound lol")

local moneycarditem = Isaac.GetItemIdByName("Mom's Debit Card")
local game = Game()
local sfxm = SFXManager()

if EID then
    EID:addCollectible(moneycarditem, "Upon use, removes all of your coins and spawns an item of a random item pool.#The item's quality varies depending on the amount of coins removed.#0-10 coins will grant you a quality 0 item.#11-20 coins will grant you a quality 1 item.#21-30 coins will grant you a quality 2 item.#31-40 coins will grant you a quality 3 item.#41 or more coins will grant you a quality 4 item.")
end


local itemPool = game:GetItemPool()
local itemConfig = Isaac.GetItemConfig()

local MAX_ROLL_COUNT = 200

local function ItemOfQuality(minQuality, maxQuality, pool, fallback, removeItems)
    minQuality = minQuality or 0
    maxQuality = maxQuality or 4
    pool = pool or ItemPoolType.POOL_TREASURE
    fallback = fallback or CollectibleType.COLLECTIBLE_BREAKFAST
    removeItems = removeItems or false

    local failCounter = 0
    while failCounter < MAX_ROLL_COUNT do
        local item = itemPool:GetCollectible(pool, removeItems)
        local config = itemConfig:GetCollectible(item)
        if config and config.Quality >= minQuality and config.Quality <= maxQuality then
            return item
        end
        failCounter = failCounter + 1
    end
    return fallback
end



function creditcardmod:UseMoneyCard(item, rng, player, useFlags, activeSlot, customData)
    local character = player:GetPlayerType()
    local tkeeper = PlayerType.PLAYER_KEEPER_B
    local coinAmount = player:GetNumCoins()
    local playerPos = player.Position
    local itemQuality = 0
    if character == tkeeper and coinAmount < 21 then
        itemQuality = 0
    elseif character == tkeeper and coinAmount < 41 then
        itemQuality = 1
    elseif character == tkeeper and coinAmount < 61 then
        itemQuality = 2
    elseif character == tkeeper and coinAmount < 81 then
        itemQuality = 3
    elseif character == tkeeper and coinAmount >= 81 then
        itemQuality = 4
    elseif character ~= tkeeper and coinAmount < 11 then
        itemQuality = 0
    elseif character ~= tkeeper and coinAmount < 21 then
        itemQuality = 1
    elseif character ~= tkeeper and coinAmount < 31 then
        itemQuality = 2
    elseif character ~= tkeeper and coinAmount < 41 then
        itemQuality = 3
    elseif character ~= tkeeper and coinAmount >= 41 then
        itemQuality = 4
    end
    local item = ItemOfQuality(itemQuality, itemQuality)
    local carditemgen =  Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, item, Game():GetRoom():FindFreePickupSpawnPosition(playerPos + Vector(0,-40)), Vector(0,0), nil)
    player:AddCoins(-999)
    sfxm:Play(creditcardmod.SOUND_MOM_CARD)
    return true
end




creditcardmod:AddCallback(ModCallbacks.MC_USE_ITEM, creditcardmod.UseMoneyCard, moneycarditem)



