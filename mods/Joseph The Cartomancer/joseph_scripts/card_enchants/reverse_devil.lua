local ReverseDevil = {}

local utility = JosephMod.utility
local enums = JosephMod.enums



---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseDevil:initReverseDevil(player, card)
    player:GetEffects():AddNullEffect(NullItemID.ID_REVERSE_DEVIL)
    local effect = player:GetEffects():GetNullEffect(NullItemID.ID_REVERSE_DEVIL)
    effect.Cooldown = 2147483646
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, ReverseDevil.initReverseDevil, Card.CARD_REVERSE_DEVIL)


---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseDevil:removeReverseDevil(player, card, slot)
    player:GetEffects():RemoveNullEffect(NullItemID.ID_REVERSE_DEVIL)
    local effect = player:GetEffects():GetNullEffect(NullItemID.ID_REVERSE_DEVIL)
    if effect then
        effect.Cooldown = 1
    end
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, ReverseDevil.removeReverseDevil, Card.CARD_REVERSE_DEVIL)


function ReverseDevil:ReapplyReverseDevil()
    for i = 0, Game():GetNumPlayers()-1 do
        local player = Game():GetPlayer(i)
        if utility:HasEnchantment(player, Card.CARD_REVERSE_DEVIL) and player:GetEffects():HasNullEffect(NullItemID.ID_REVERSE_DEVIL) then
            local effect = player:GetEffects():GetNullEffect(NullItemID.ID_REVERSE_DEVIL)
            effect.Cooldown = 2147483646
        end
    end
end
JosephMod:AddCallback(TSIL.Enums.CustomCallback.POST_NEW_ROOM_REORDERED, ReverseDevil.ReapplyReverseDevil)


-- JosephMod:AddCallback(TSIL.Enums.CustomCallback.POST_NEW_LEVEL_REORDERED, function ()
--     if gameContinued then 
--         gameContinued = false
--         return
--     end
--     JosephMod.Schedule(1, function ()
--         JosephMod.BaseCardEffects:ReapplyCardEffects()
--     end,{})
-- end)