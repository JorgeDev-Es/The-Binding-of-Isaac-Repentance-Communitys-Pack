local ReverseWheelOfFortune = {}

local utility = JosephMod.utility
local enums = JosephMod.enums

local game = Game()

local ALLOW_MULTIPLE_DOORS = true
local ALLOW_SPECIAL_NEIGHBORS = false

local ONLY_NEIGHBOR_BLACKLIST = {
    [RoomType.ROOM_SECRET] = true,
    [RoomType.ROOM_SUPERSECRET] = true,
    [RoomType.ROOM_ULTRASECRET] = true,
}


function ReverseWheelOfFortune:AddDiceRoom()
    local level = Game():GetLevel()
    local dimension = Dimension.CURRENT
    local seed = level:GetDungeonPlacementSeed()
    local diff = 0

    local roomConfig = RoomConfigHolder.GetRandomRoom(
        seed,
        true,
        StbType.SPECIAL_ROOMS,
        RoomType.ROOM_DICE,
        RoomShape.ROOMSHAPE_1x1
    )

    if roomConfig then
        local options = level:FindValidRoomPlacementLocations(roomConfig, dimension, ALLOW_MULTIPLE_DOORS, ALLOW_SPECIAL_NEIGHBORS)

        for _, gridIndex in pairs(options) do
            local neighbors = level:GetNeighboringRooms(gridIndex, roomConfig.Shape, dimension)
            local hasValidNeighbor

            for _, desc in pairs(neighbors) do
                if desc.Data and not ONLY_NEIGHBOR_BLACKLIST[desc.Data.Type] then
                    hasValidNeighbor = true
                    break
                end
            end

            if hasValidNeighbor then
                ---@diagnostic disable-next-line: param-type-mismatch
                local room = level:TryPlaceRoom(roomConfig, gridIndex, dimension, seed, ALLOW_MULTIPLE_DOORS, ALLOW_SPECIAL_NEIGHBORS)

                if room then
                    Game():GetLevel():UpdateVisibility()
                    break
                end
            end
        end
    end

end


function ReverseWheelOfFortune:NewLevel()
    local num = utility:GetTotalEnchantmentCount(Card.CARD_REVERSE_WHEEL_OF_FORTUNE)
    if num == 0 then return end

    if Game():GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH) then return end

    for i = 1, num do
        ReverseWheelOfFortune:AddDiceRoom()
    end
end
JosephMod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, -300, ReverseWheelOfFortune.NewLevel)


---@param player EntityPlayer
---@param card Card
function ReverseWheelOfFortune:initReverseWheelOfFortune(player, card, firstTime)
    if not firstTime then return end
    if Game():GetStateFlag(GameStateFlag.STATE_BACKWARDS_PATH) then return end

    ReverseWheelOfFortune:AddDiceRoom()

end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, ReverseWheelOfFortune.initReverseWheelOfFortune, Card.CARD_REVERSE_WHEEL_OF_FORTUNE)