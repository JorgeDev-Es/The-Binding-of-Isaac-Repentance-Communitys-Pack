local ReverseEmpress = {}

local utility = JosephMod.utility
local enums = JosephMod.enums



---@param player EntityPlayer
---@param card Card

function ReverseEmpress:initReverseEmpress(player, card)
    --player:GetEffects():AddNullEffect(NullItemID.ID_REVERSE_EMPRESS)
    player:UseCard(Card.CARD_REVERSE_EMPRESS, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
    local effect = player:GetEffects():GetNullEffect(NullItemID.ID_REVERSE_EMPRESS)
    effect.Cooldown = 2147483646
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, ReverseEmpress.initReverseEmpress, Card.CARD_REVERSE_EMPRESS)


---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseEmpress:removeReverseEmpress(player, card, slot)
    player:GetEffects():RemoveNullEffect(NullItemID.ID_REVERSE_EMPRESS)
    local effect = player:GetEffects():GetNullEffect(NullItemID.ID_REVERSE_EMPRESS)
    if effect then
        effect.Cooldown = 1
    end
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, ReverseEmpress.removeReverseEmpress, Card.CARD_REVERSE_EMPRESS)


function ReverseEmpress:ReapplyReverseHighPriestess()
    for i = 0, Game():GetNumPlayers()-1 do
        local player = Game():GetPlayer(i)
        if utility:HasEnchantment(player, Card.CARD_REVERSE_EMPRESS) and player:GetEffects():HasNullEffect(NullItemID.ID_REVERSE_EMPRESS) then
            local effect = player:GetEffects():GetNullEffect(NullItemID.ID_REVERSE_EMPRESS)
            effect.Cooldown = 2147483646
        end
    end
end
JosephMod:AddCallback(TSIL.Enums.CustomCallback.POST_NEW_ROOM_REORDERED, ReverseEmpress.ReapplyReverseHighPriestess)


function ReverseEmpress:ReduceFireRate(player, flag)
    if not utility:HasEnchantment(player, Card.CARD_REVERSE_EMPRESS) or flag ~= CacheFlag.CACHE_FIREDELAY then return end
    utility:AddTears(player, -0.5)
end
JosephMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ReverseEmpress.ReduceFireRate)


-- JosephMod:AddCallback(TSIL.Enums.CustomCallback.POST_NEW_LEVEL_REORDERED, function ()
--     if gameContinued then 
--         gameContinued = false
--         return
--     end
--     JosephMod.Schedule(1, function ()
--         JosephMod.BaseCardEffects:ReapplyCardEffects()
--     end,{})
-- end)