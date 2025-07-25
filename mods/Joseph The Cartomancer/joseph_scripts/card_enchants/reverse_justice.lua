local ReverseJustice = {}
local utility = JosephMod.utility
local enums = JosephMod.enums

local firstTimeReverseJustice = false
local CHEST_REPLACE_CHANCE = 1/4


function ReverseJustice:RoomClear(rng, spawnPos)
    local level = Game():GetLevel()
    local room = Game():GetRoom()
    local roomType = room:GetType()
    local roomDesc = level:GetCurrentRoomDesc()
    local roomConfigRoom = roomDesc.Data

    if not utility:AnyPlayerHasEnchantment(Card.CARD_REVERSE_JUSTICE) then return end

    local spawnedChest = false

    if roomType == RoomType.ROOM_BOSS or level:GetCurrentRoomIndex() == GridRooms.ROOM_EXTRA_BOSS_IDX then return end
    if roomConfigRoom.StageID == 35 and roomType == RoomType.ROOM_DUNGEON then return end
    local enchantCount = utility:GetTotalEnchantmentCount(Card.CARD_REVERSE_JUSTICE)
    for i = 0, enchantCount - 1 do
        if (rng:RandomFloat() <= CHEST_REPLACE_CHANCE or firstTimeReverseJustice == true) then
            firstTimeReverseJustice = false
            SFXManager():Play(SoundEffect.SOUND_THUMBSUP)
            local pos = room:FindFreePickupSpawnPosition(spawnPos)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LOCKEDCHEST, 0, pos, Vector(0, 0), nil)
            spawnedChest = true
        end
    end
    if spawnedChest == true then 
        roomDesc.AwardSeed = rng:GetSeed()
        return true
    end

end
JosephMod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, ReverseJustice.RoomClear)


---@param player EntityPlayer
---@param card Card
---@param firstTime boolean
function ReverseJustice:initReverseJustice(player, card, firstTime)
    if firstTime ~= true then return end
    firstTimeReverseJustice = true
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, ReverseJustice.initReverseJustice, Card.CARD_REVERSE_JUSTICE)



---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseJustice:removeReverseJustice(player, card, slot)
    firstTimeReverseJustice = false
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, ReverseJustice.removeReverseJustice, Card.CARD_REVERSE_JUSTICE)
