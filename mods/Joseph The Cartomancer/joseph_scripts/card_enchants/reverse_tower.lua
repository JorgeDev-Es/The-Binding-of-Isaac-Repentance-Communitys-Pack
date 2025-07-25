local ReverseTower = {}
local enums = JosephMod.enums
local utility = JosephMod.utility


---@param entity Entity
function ReverseTower:OnHit(entity, amount, flags, source, countDown)
    local player = entity:ToPlayer()
    if not player then return end
    if not utility:HasEnchantment(player, Card.CARD_REVERSE_TOWER) then return end

    player:UseCard(Card.CARD_REVERSE_TOWER, UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOHUD | UseFlag.USE_NOANIM)
end
JosephMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ReverseTower.OnHit, EntityType.ENTITY_PLAYER)