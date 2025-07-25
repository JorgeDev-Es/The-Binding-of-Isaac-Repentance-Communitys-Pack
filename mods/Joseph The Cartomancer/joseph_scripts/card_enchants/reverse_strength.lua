local ReverseStrength = {}

local utility = JosephMod.utility
local enums = JosephMod.enums
local strength = Card.CARD_REVERSE_STRENGTH

local WEAKNESS_DURATION = 30 * 15


---@param player EntityPlayer
---@param card Card
function ReverseStrength:initReverseStrength(player, card)

end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, ReverseStrength.initReverseStrength, strength)


---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseStrength:removeReverseStrength(player, card, slot)

end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, ReverseStrength.removeReverseStrength, strength)


---@param npc EntityNPC
function ReverseStrength:NPCInit(npc)
    if npc.FrameCount > 1 then return end

        -- local active = "false"
        -- local vulnerable = "false"
        -- local invincible = "false"
    
        -- if npc:IsVulnerableEnemy() then vulnerable = "true" end
        -- if npc:IsActiveEnemy() then active = "true" end
        -- if npc:IsInvincible() then invincible = "true" end
        -- print("Active: " .. active)
        -- print("vulnerable: " .. vulnerable)
        -- print("invincible: " .. invincible)

        if not (npc:IsVulnerableEnemy() and npc:IsActiveEnemy()) then return end
    
        local numStrength = utility:GetTotalEnchantmentCount(strength)
        if numStrength and numStrength > 0 then
            npc:AddWeakness(EntityRef(npc), WEAKNESS_DURATION * numStrength)
            npc:SetWeaknessCountdown(WEAKNESS_DURATION * numStrength)
        end
end
JosephMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, ReverseStrength.NPCInit)