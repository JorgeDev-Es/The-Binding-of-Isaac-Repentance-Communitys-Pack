local CardSleeve = {}

local enums = JosephMod.enums
local utility = JosephMod.utility

local CARD_SLEEVE = Isaac.GetItemIdByName("Card Sleeve")


---@param player EntityPlayer
function CardSleeve:UseCardSleeve(item, rng, player, flags, slot, varData)
    if player == nil then return end

    local heldCard = player:GetCard(PillCardSlot.PRIMARY)
    local pocket = false

    if slot == ActiveSlot.SLOT_POCKET then
        heldCard = player:GetCard(PillCardSlot.SECONDARY)
        pocket = true
    end

    if not heldCard or heldCard == 0 or not enums.CardAnims[heldCard] then 
        return {Discharge = false, ShowAnim = true}
    end


    local oldCard = player:GetActiveItemDesc(slot).VarData

    CardSleeve:EnchantCard(player, heldCard, oldCard)
    if pocket then
        player:RemovePocketItem(PillCardSlot.SECONDARY)
    else
        player:RemovePocketItem(PillCardSlot.PRIMARY)
    end
    
    player:GetActiveItemDesc(slot).VarData = heldCard

    return {
        Remove = false,
        ShowAnim = true,
    }
end
JosephMod:AddCallback(ModCallbacks.MC_USE_ITEM, CardSleeve.UseCardSleeve, CARD_SLEEVE)

---@param player EntityPlayer
---@param card Card
---@param oldCard Card | nil 
function CardSleeve:EnchantCard(player, card, oldCard)

    player:AnimateCard(card)
    SFXManager():Play(SoundEffect.SOUND_POWERUP_SPEWER, 1)

    local enchantedCards = TSIL.SaveManager.GetPersistentPlayerVariable(JosephMod, "EnchantedCards", player)
    if oldCard then
        for i=3, 6, 1 do
            if enchantedCards[i] == oldCard then
                enchantedCards[i] = 0
                break
            end
        end
        JosephMod.BaseCardEffects:RemoveCardEffect(player, oldCard)
        Isaac.RunCallbackWithParam(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, oldCard, player, oldCard, nil)
    end

    for i=3, 6, 1 do
        if enchantedCards[i] == 0 or enchantedCards[i] == nil then
            enchantedCards[i] = card
            break
        end
    end

    JosephMod.BaseCardEffects:InitCardEffect(player, card, true)
    Isaac.RunCallbackWithParam(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, card, player, card, true)

end



function CardSleeve:PickupCardSleeve(type, charge, firstTime, slot, varData, player)
    if not varData or varData == 0 then return end

    local enchantedCards = TSIL.SaveManager.GetPersistentPlayerVariable(JosephMod, "EnchantedCards", player)
    for i=3, 6, 1 do
        if enchantedCards[i] == 0 or enchantedCards[i] == nil then
            enchantedCards[i] = varData
            JosephMod.BaseCardEffects:InitCardEffect(player, varData, false)
            Isaac.RunCallbackWithParam(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, varData, player, varData, false)
            break
        end
    end

end
JosephMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, CardSleeve.PickupCardSleeve, CARD_SLEEVE)



local function tableHasValue(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

function CardSleeve:DropCardSleeve(player, type)
    local enchantedCards = TSIL.SaveManager.GetPersistentPlayerVariable(JosephMod, "EnchantedCards", player)
    local storedSleeveEnchants = {enchantedCards[3], enchantedCards[4], enchantedCards[5]}
    local activeItemCards = {}

    for key, slot in pairs(ActiveSlot) do
        if player:GetActiveItem(slot) == CARD_SLEEVE then
            table.insert(activeItemCards, player:GetActiveItemDesc(slot).VarData)
        end
    end

    local cardToDisenchant, slotToDisenchant

    for key, card in pairs(storedSleeveEnchants) do
        if not tableHasValue(activeItemCards, card) and card ~= 0 then
            cardToDisenchant = card
            slotToDisenchant = key + 2
        end
    end

    if cardToDisenchant and cardToDisenchant ~= 0 and slotToDisenchant and slotToDisenchant ~= 0 then
        enchantedCards[slotToDisenchant] = 0
        JosephMod.BaseCardEffects:RemoveCardEffect(player, cardToDisenchant)
        Isaac.RunCallbackWithParam(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, cardToDisenchant, player, cardToDisenchant, nil)
    end
end
JosephMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, CardSleeve.DropCardSleeve, CARD_SLEEVE)




local enchantmentDisplay = Sprite()
enchantmentDisplay:Load("gfx/ui/enchanted_card_displays.anm2",true)

function CardSleeve:RenderEnchantedCard(player, slot, offset, alpha, scale, chargeBarOffset)

    if player:GetActiveItem(slot) ~= CARD_SLEEVE then return end

    local enchantedCard = player:GetActiveItemDesc(slot).VarData
    if enchantedCard and enchantedCard ~= 0 then

        enchantmentDisplay.Color = Color(1, 1, 1, 1)
        enchantmentDisplay.Scale = Vector(scale, scale)
        local displayPos = Vector(16, 16)

        local pocketItem = player:GetPocketItem(PillCardSlot.PRIMARY)
        local isSelectedPocketItem = pocketItem:GetType() == PocketItemType.ACTIVE_ITEM and pocketItem:GetSlot()-1 == ActiveSlot.SLOT_POCKET
        local isSelectedPocket2Item = pocketItem:GetType() == PocketItemType.ACTIVE_ITEM and pocketItem:GetSlot()-1 == ActiveSlot.SLOT_POCKET2

		if slot == ActiveSlot.SLOT_SECONDARY
        or (slot == ActiveSlot.SLOT_POCKET and not isSelectedPocketItem)
        or (slot == ActiveSlot.SLOT_POCKET2 and not isSelectedPocket2Item) then
			displayPos = displayPos / 2
		end

        enchantmentDisplay:SetFrame("CardFronts", enchantedCard)

        enchantmentDisplay:LoadGraphics()
        enchantmentDisplay:Render(displayPos + offset)
    end

end

JosephMod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, CardSleeve.RenderEnchantedCard)



return CardSleeve