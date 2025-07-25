local AceHearts = {}

local enums = JosephMod.enums
local ace = enums.Collectibles.ACE_OF_HEARTS
local utility = JosephMod.utility

local heartsToSpawn = 0


---@param pickup EntityPickup
function AceHearts:HeartSpawn(pickup)
    if not PlayerManager.AnyoneHasCollectible(ace) then return end
    local rng = PlayerManager.FirstCollectibleOwner(ace):GetCollectibleRNG(ace)
    if heartsToSpawn > 0 then
        heartsToSpawn = heartsToSpawn - 1
        return
    end
    if rng:RandomFloat() < 0.5 then
        pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_NULL, NullPickupSubType.NO_COLLECTIBLE_TRINKET_CHEST, true, true)
        return
    end

    local card = Game():GetItemPool():GetCard(rng:Next(), true, false, false)
    pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, card, true, true)
end
JosephMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, AceHearts.HeartSpawn, PickupVariant.PICKUP_HEART)



function AceHearts:UseHeartCard(card, player, flags)
    if not PlayerManager.AnyoneHasCollectible(ace) then return end
    if card == Card.CARD_LOVERS or card == Card.CARD_HIEROPHANT or card == Card.CARD_REVERSE_HIEROPHANT then
        heartsToSpawn = 2
        if player:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) then
            heartsToSpawn = 3
        end
    end
end
JosephMod:AddCallback(ModCallbacks.MC_PRE_USE_CARD, AceHearts.UseHeartCard)