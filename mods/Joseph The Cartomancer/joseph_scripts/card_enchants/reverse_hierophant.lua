local ReverseHierophant = {}
local utility = JosephMod.utility
local enums = JosephMod.enums

local firstTimeReverseHierophant = false
local BONE_HEART_REPLACE_CHANCE = 1/7


function ReverseHierophant:RoomClear(rng, spawnPos)
    local level = Game():GetLevel()
    local room = Game():GetRoom()
    local roomType = room:GetType()

    if not utility:AnyPlayerHasEnchantment(Card.CARD_REVERSE_HIEROPHANT) then return end

    if roomType == RoomType.ROOM_BOSS or level:GetCurrentRoomIndex() == GridRooms.ROOM_EXTRA_BOSS_IDX then return end
    local enchantCount = utility:GetTotalEnchantmentCount(Card.CARD_REVERSE_HIEROPHANT)
    for i = 0, enchantCount - 1 do
        if (rng:RandomFloat() <= BONE_HEART_REPLACE_CHANCE or firstTimeReverseHierophant == true) then
            firstTimeReverseHierophant = false
            SFXManager():Play(SoundEffect.SOUND_THUMBSUP)
            local pos = room:FindFreePickupSpawnPosition(spawnPos)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BONE, pos, Vector(0, 0), nil)
        end
    end

end
JosephMod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, ReverseHierophant.RoomClear)


---@param player EntityPlayer
---@param card Card
---@param firstTime boolean
function ReverseHierophant:initReverseHierophant(player, card, firstTime)
    if firstTime ~= true then return end
    firstTimeReverseHierophant = true
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, ReverseHierophant.initReverseHierophant, Card.CARD_REVERSE_HIEROPHANT)



---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseHierophant:removeReverseHierophant(player, card, slot)
    firstTimeReverseHierophant = false
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, ReverseHierophant.removeReverseHierophant, Card.CARD_REVERSE_HIEROPHANT)
