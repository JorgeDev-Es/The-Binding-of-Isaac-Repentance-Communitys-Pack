local PokerMat = {}
local mod = JosephMod

local enums = JosephMod.enums
local utility = JosephMod.utility

local POKER_MAT = enums.Collectibles.POKER_MAT


local dontUse = false

---@param card Card
---@param player EntityPlayer
---@param flags UseFlag
function PokerMat:UseCard(card, player, flags)
    if not player:HasCollectible(POKER_MAT) then return end
    if flags & UseFlag.USE_CARBATTERY > 0 then return end

    if dontUse == true then
        dontUse = false
        return
    end

    if card == Card.CARD_CLUBS_2 then
        dontUse = true
        player:UseCard(Card.CARD_CLUBS_2, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)

    elseif card == Card.CARD_HEARTS_2 then
        dontUse = true
        player:UseCard(Card.CARD_HEARTS_2, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)

    elseif card == Card.CARD_SPADES_2 then
        dontUse = true
        player:UseCard(Card.CARD_SPADES_2, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        
    elseif card == Card.CARD_DIAMONDS_2 then
        dontUse = true
        player:UseCard(Card.CARD_DIAMONDS_2, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)

    elseif card == Card.CARD_ACE_OF_DIAMONDS then
        local coins = Isaac.FindByType(5, PickupVariant.PICKUP_COIN)
        for _, coin in ipairs(coins) do
            if coin.SubType == CoinSubType.COIN_PENNY then
                coin:ToPickup():Morph(5, 20, CoinSubType.COIN_DOUBLEPACK, true)
            elseif coin.SubType == CoinSubType.COIN_NICKEL then
                coin:ToPickup():Morph(5, 20, CoinSubType.COIN_DIME, true)
            end
        end

    elseif card == Card.CARD_ACE_OF_CLUBS then
        local bombs = Isaac.FindByType(5, PickupVariant.PICKUP_BOMB)
        for _, bomb in ipairs(bombs) do
            if bomb.SubType == BombSubType.BOMB_NORMAL then
                bomb:ToPickup():Morph(5, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_DOUBLEPACK, true)
            elseif bomb.SubType == BombSubType.BOMB_TROLL then
                bomb:ToPickup():Morph(5, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_SUPERTROLL, true)
            end
        end

    elseif card == Card.CARD_ACE_OF_SPADES then
        local keys = Isaac.FindByType(5, PickupVariant.PICKUP_KEY)
        for _, key in ipairs(keys) do
            if key.SubType == KeySubType.KEY_NORMAL then
                key:ToPickup():Morph(5, PickupVariant.PICKUP_KEY, KeySubType.KEY_DOUBLEPACK, true)
            end
        end

    elseif card == Card.CARD_ACE_OF_HEARTS then
        local hearts = Isaac.FindByType(5, PickupVariant.PICKUP_HEART)
        for _, heart in ipairs(hearts) do
            if heart.SubType == HeartSubType.HEART_FULL then
                heart:ToPickup():Morph(5, PickupVariant.PICKUP_HEART, HeartSubType.HEART_DOUBLEPACK, true)

            elseif heart.SubType == HeartSubType.HEART_HALF then
                heart:ToPickup():Morph(5, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, true)

            elseif heart.SubType == HeartSubType.HEART_HALF_SOUL then
                heart:ToPickup():Morph(5, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, true)
            end
        end

    elseif card == Card.CARD_QUEEN_OF_HEARTS then
        dontUse = true
        player:UseCard(Card.CARD_QUEEN_OF_HEARTS, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)

    elseif card == Card.CARD_SUICIDE_KING then
        dontUse = true
        player:UseCard(Card.CARD_SUICIDE_KING, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)

    elseif card == Card.CARD_RULES then
        Isaac.CreateTimer(function()
            dontUse = true
            player:UseCard(Card.CARD_RULES, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        end, 30, 1, true)

    end

end
mod:AddCallback(ModCallbacks.MC_USE_CARD, PokerMat.UseCard)




function PokerMat:GetItem(item, charge, firstTime, slot, varData, player)
    if not firstTime then return end
    local card, attempts = 0, 0
    while not utility:IsPlayingCard(card) and attempts < 100 do
        card = Game():GetItemPool():GetCard(player:GetCollectibleRNG(POKER_MAT):Next(), true, false, false)
        attempts = attempts + 1
    end
    if not utility:IsPlayingCard(card) then card = Card.CARD_RULES end
    Isaac.Spawn(5, PickupVariant.PICKUP_TAROTCARD, card, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, player)
end
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, PokerMat.GetItem, POKER_MAT)