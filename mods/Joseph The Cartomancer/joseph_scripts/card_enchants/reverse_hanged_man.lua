local ReverseHangedMan = {}

local utility = JosephMod.utility
local enums = JosephMod.enums



---@param player EntityPlayer
---@param card Card
function ReverseHangedMan:initReverseHangedMan(player, card)
    player:GetEffects():AddNullEffect(NullItemID.ID_REVERSE_HANGED_MAN)
    local effect = player:GetEffects():GetNullEffect(NullItemID.ID_REVERSE_HANGED_MAN)
    effect.Cooldown = 2147483646
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, ReverseHangedMan.initReverseHangedMan, Card.CARD_REVERSE_HANGED_MAN)


---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseHangedMan:removeReverseHangedMan(player, card, slot)
    player:GetEffects():RemoveNullEffect(NullItemID.ID_REVERSE_HANGED_MAN)
    local effect = player:GetEffects():GetNullEffect(NullItemID.ID_REVERSE_HANGED_MAN)
    if effect then
        effect.Cooldown = 1
    end
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, ReverseHangedMan.removeReverseHangedMan, Card.CARD_REVERSE_HANGED_MAN)


function ReverseHangedMan:ReapplyReverseHangedMan()
    for i = 0, Game():GetNumPlayers()-1 do
        local player = Game():GetPlayer(i)
        if utility:HasEnchantment(player, Card.CARD_REVERSE_HANGED_MAN) and player:GetEffects():HasNullEffect(NullItemID.ID_REVERSE_HANGED_MAN) then
            local effect = player:GetEffects():GetNullEffect(NullItemID.ID_REVERSE_HANGED_MAN)
            effect.Cooldown = 2147483646
        end
    end
end
JosephMod:AddCallback(TSIL.Enums.CustomCallback.POST_NEW_ROOM_REORDERED, ReverseHangedMan.ReapplyReverseHangedMan)


function ReverseHangedMan:onEntityDie(entity, amount, flags, source)
    if not (entity:IsEnemy() and entity:HasMortalDamage() and entity:IsActiveEnemy() and source.Entity) then return end

    local player = TSIL.Players.GetPlayerFromEntity(source.Entity)
    if not (player and utility:HasEnchantment(player, Card.CARD_REVERSE_HANGED_MAN)) then return end

    Isaac.CreateTimer(function ()
        local pickup = (utility:GetNearestEntity(entity.Position, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN)):ToPickup()
        if not (pickup and pickup.Position:DistanceSquared(entity.Position) < 100 ) then return end
        pickup.Timeout = 60
        pickup.Velocity = 3*RandomVector()
    end, 3, 1, false)

end
JosephMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, ReverseHangedMan.onEntityDie)


-- JosephMod:AddCallback(TSIL.Enums.CustomCallback.POST_NEW_LEVEL_REORDERED, function ()
--     if gameContinued then 
--         gameContinued = false
--         return
--     end
--     JosephMod.Schedule(1, function ()
--         JosephMod.BaseCardEffects:ReapplyCardEffects()
--     end,{})
-- end)