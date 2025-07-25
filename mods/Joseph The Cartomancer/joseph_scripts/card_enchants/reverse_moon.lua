local ReverseMoon = {}

local utility = JosephMod.utility
local enums = JosephMod.enums


---@param player EntityPlayer
---@param card Card
function ReverseMoon:initReverseMoon(player, card)

end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, ReverseMoon.initReverseMoon, Card.CARD_REVERSE_MOON)

---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseMoon:removeReverseMoon(player, card, slot)

end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, ReverseMoon.removeReverseMoon, Card.CARD_REVERSE_MOON)


function ReverseMoon:roomClear(rng)
    if not utility:AnyPlayerHasEnchantment(Card.CARD_REVERSE_MOON) then return end
    local level = Game():GetLevel()
    local descriptor = level:GetCurrentRoomDesc()

    if descriptor.Flags & RoomDescriptor.FLAG_RED_ROOM == RoomDescriptor.FLAG_RED_ROOM then
        if rng:RandomFloat() < 0.5 then return end --50% chance to not spawn door if already in a red room
    end
    local availableDoors = {}

    for doorSlot = DoorSlot.LEFT0, DoorSlot.DOWN1 do
        if level:CanSpawnDoorOutline(level:GetCurrentRoomIndex(), doorSlot) then
            table.insert(availableDoors, doorSlot)
        end
    end

    local doorToOpen = TSIL.Random.GetRandomElementsFromTable(availableDoors, 1, rng)
    if doorToOpen[1] then
        level:MakeRedRoomDoor(level:GetCurrentRoomIndex() , doorToOpen[1]) 
    end
end
JosephMod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, ReverseMoon.roomClear)