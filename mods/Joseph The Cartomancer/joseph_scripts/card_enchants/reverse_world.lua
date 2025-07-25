local ReverseWorld = {}
local enums = JosephMod.enums
local utility = JosephMod.utility


function ReverseWorld:ReplaceCrawlspace()


end

---@param player EntityPlayer
---@param card Card
function ReverseWorld:initReverseWorld(player, card)
    if Game():GetLevel():GetCurrentRoomIndex() == 84 then
        Isaac.GridSpawn(
            GridEntityType.GRID_STAIRS,
            0,
            Game():GetRoom():FindFreePickupSpawnPosition(Vector(440, 160))
        )
    end
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, ReverseWorld.initReverseWorld, Card.CARD_REVERSE_WORLD)

---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseWorld:removeReverseWorld(player, card, slot)
    ReverseWorld:RemoveTrapdoor()
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, ReverseWorld.removeReverseWorld, Card.CARD_REVERSE_WORLD)



function ReverseWorld:NewRoom()
    if not utility:AnyPlayerHasEnchantment(Card.CARD_REVERSE_WORLD) then return end
    if Game():GetLevel():GetCurrentRoomIndex() ~= 84 then return end
    local crawlSpaces = TSIL.GridSpecific.GetStairs(TSIL.Enums.StairsVariant.NORMAL)
    if #crawlSpaces > 0 then return end
    
    Isaac.GridSpawn(
        GridEntityType.GRID_STAIRS,
        0,
        Game():GetRoom():FindFreePickupSpawnPosition(Vector(440, 160))
    )

end
JosephMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ReverseWorld.NewRoom)


function ReverseWorld:RemoveTrapdoor()
    if Game():GetLevel():GetCurrentRoomIndex() ~= 84 then return end
    if utility:AnyPlayerHasEnchantment(Card.CARD_REVERSE_WORLD) then return end
    local crawlSpaces = TSIL.GridSpecific.GetStairs(TSIL.Enums.StairsVariant.NORMAL)
    if #crawlSpaces ~= 0 then
        local trapDoor = crawlSpaces[1]
        Isaac.Spawn(1000, 15, 0, trapDoor.Position, Vector(0, 0), nil)
        TSIL.GridEntities.RemoveGridEntity(trapDoor)
    end
end
