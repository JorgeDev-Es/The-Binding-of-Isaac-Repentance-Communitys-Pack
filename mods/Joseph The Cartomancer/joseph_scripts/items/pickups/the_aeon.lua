local Aeon = {}

local mod = JosephMod
local enums = JosephMod.enums
local utility = JosephMod.utility


TSIL.SaveManager.AddPersistentPlayerVariable(JosephMod, "UsedAeon", nil, TSIL.Enums.VariablePersistenceMode.RESET_RUN, false, true)

---@param card Card
---@param player EntityPlayer
---@param flags UseFlag
function mod:UseAeon(card, player, flags)
    TSIL.SaveManager.SetPersistentPlayerVariable(JosephMod, "UsedAeon", player, flags)

    player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, UseFlag.USE_NOANIM)

end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.UseAeon, enums.Cards.THE_AEON)

---@param player EntityPlayer
function mod:RemoveAeon(player)
    if not player then return end
    local aeonFlags = TSIL.SaveManager.GetPersistentPlayerVariable(JosephMod, "UsedAeon", player)
    if not aeonFlags then return end
    TSIL.SaveManager.SetPersistentPlayerVariable(JosephMod, "UsedAeon", player, nil)
    -- player:StopExtraAnimation()
    -- player:AnimateCard(enums.Cards.THE_AEON, "UseItem")
    if aeonFlags & UseFlag.USE_MIMIC > 0 then
        for key, slot in pairs(ActiveSlot) do
            if player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_BLANK_CARD then
                player:GetActiveItemDesc(slot).Charge = 0
                player:GetActiveItemDesc(slot).VarData = 4
                break
            end
        end
    else
        if player:GetCard(0) and player:GetCard(0) == enums.Cards.THE_AEON then
            player:RemovePocketItem(0)
        elseif player:GetCard(1) and player:GetCard(1) == enums.Cards.THE_AEON then
            player:RemovePocketItem(1)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, mod.RemoveAeon)


-- ---@param player EntityPlayer
-- function mod:ChangeBlankCardCharge(item, player, varData, currentCharge)
--     if not player then return end
--     local aeonFlags = TSIL.SaveManager.GetPersistentPlayerVariable(JosephMod, "UsedAeon", player)
--     if not aeonFlags then return end
--     return 4
-- end
-- mod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, mod.ChangeBlankCardCharge, CollectibleType.COLLECTIBLE_BLANK_CARD)
