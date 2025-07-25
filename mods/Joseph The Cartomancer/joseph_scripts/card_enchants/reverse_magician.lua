local ReverseMagician = {}

local utility = JosephMod.utility
local enums = JosephMod.enums


---@param player EntityPlayer
---@param card Card
function ReverseMagician:initReverseMagician(player, card)
    player:AddInnateCollectible(CollectibleType.COLLECTIBLE_SOUL, 1)
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, ReverseMagician.initReverseMagician, Card.CARD_REVERSE_MAGICIAN)
JosephMod:AddCallback(enums.Callbacks.JOSEPH_GAME_START_ENCHANT_REFRESH, ReverseMagician.initReverseMagician, Card.CARD_REVERSE_MAGICIAN)

---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseMagician:removeReverseMagician(player, card, slot)
    utility:RemoveInnateItem(player, CollectibleType.COLLECTIBLE_SOUL)
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, ReverseMagician.removeReverseMagician, Card.CARD_REVERSE_MAGICIAN)