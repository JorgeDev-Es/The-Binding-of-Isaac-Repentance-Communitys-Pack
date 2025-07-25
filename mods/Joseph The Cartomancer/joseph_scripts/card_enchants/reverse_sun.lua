local ReverseSun = {}

local utility = JosephMod.utility
local enums = JosephMod.enums



---@param player EntityPlayer
---@param card Card
function ReverseSun:initReverseSun(player, card)
    player:UseCard(Card.CARD_REVERSE_SUN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
    local effect = player:GetEffects():GetNullEffect(NullItemID.ID_REVERSE_SUN)
    effect.Cooldown = 2147483646
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, ReverseSun.initReverseSun, Card.CARD_REVERSE_SUN)


---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseSun:removeReverseSun(player, card, slot)
    player:GetEffects():RemoveNullEffect(NullItemID.ID_REVERSE_SUN)
    local effect = player:GetEffects():GetNullEffect(NullItemID.ID_REVERSE_SUN)
    if effect then
        effect.Cooldown = 1
    end
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, ReverseSun.removeReverseSun, Card.CARD_REVERSE_SUN)


function ReverseSun:ReduceDamage(player, flag)
    if not (flag == CacheFlag.CACHE_DAMAGE and utility:HasEnchantment(player, Card.CARD_REVERSE_SUN)) then return end
    utility:AddDamage(player, -0.5)
end
JosephMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ReverseSun.ReduceDamage)


function ReverseSun:ReapplyReverseSun()
    for i = 0, Game():GetNumPlayers()-1 do
        local player = Game():GetPlayer(i)
        if utility:HasEnchantment(player, Card.CARD_REVERSE_SUN) and not player:GetEffects():HasNullEffect(NullItemID.ID_REVERSE_SUN) then
            player:UseCard(Card.CARD_REVERSE_SUN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOHUD | UseFlag.USE_MIMIC)
        end
    end
end
JosephMod:AddCallback(TSIL.Enums.CustomCallback.POST_NEW_ROOM_REORDERED, ReverseSun.ReapplyReverseSun)


JosephMod:AddCallback(TSIL.Enums.CustomCallback.POST_NEW_LEVEL_REORDERED, function ()
    JosephMod.Schedule(1, function ()
        ReverseSun:ReapplyReverseSun()
    end,{})
end)