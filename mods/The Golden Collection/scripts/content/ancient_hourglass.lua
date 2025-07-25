local json = require("json")

--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Ancient hourglass"),

    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_SHOP,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Ancient Hourglass", DESC = "!!! 50% CHANCE TO BREAK !#Teleports you to the starter room#Rerolls all rooms previously visited#Reroll has the following effects: #{{Blank}} {{Collectible105}} D6, {{Collectible437}} D7, {{Collectible166}} D20" },
        { LANG = "ru",    NAME = "Древние песочные часы", DESC = "!!! 50% ШАНС НА РАЗРЫВ !#Телепортирует вас в стартовую комнату#Изменяет все ранее посещенные комнаты#Изменения имеют следующие эффекты: #{{Blank}} {{Collectible105}} D6, {{Collectible437}} D7, {{Collectible166}} D20" },
        { LANG = "spa",   NAME = "Reloj de arena antiguo", DESC = "!!! ¡50% DE POSIBILIDAD DE ROMPERSE!#Te teletransporta a la habitación inicial#Rerolea todas las habitaciones ya visitadas#El reroll tiene los siguientes efectos: #{{Blank}} {{Collectible105}} D6, {{Collectible437}} D7, {{Collectible166}} D20" },
        { LANG = "zh_cn", NAME = "古代沙漏", DESC = "!!! 使用时有50%的概率损坏 (变成{{Collectible66}}沙漏)#使用后传送回本层初始房间#重随所有探索过的房间 (触发{{Collectible437}}七面骰、{{Collectible105}}六面骰和{{Collectible166}}二十面骰的效果)" },
        { LANG = "ko_kr", NAME = "고대의 모래시계", DESC = "!!! 사용 시 50%의 확률로 파괴됨 !!!#시작 방으로 텔레포트합니다.#클리어한 모든 방을 초기화합니다.#초기화된 방에 이하 효과 발동: #{{Blank}} {{Collectible105}} D6, {{Collectible437}} D7, {{Collectible166}} D20" },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Ancient hourglass is an active item that has a 50% chance to break when used."},
            {str = 'When broken the item will grant "The hourglass".'},
            {str = "When used teleports the player to the starting room of the floor."},
            {str = "Any rooms that had already been cleared will be rerolled."},
            {str = "This reroll triggers the D6, D7 and D20 in the room."},
            {str = "Rooms that haven't been visited will remain unaffected."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnUse(_, RNG, player, _, _, _)
    GOLCG.SAVEDATA.HOURGLASS.IsActive = true
    GOLCG.SAVEDATA.HOURGLASS.Rooms = {}

    -- local curRoom = game:GetLevel():GetCurrentRoomIndex ()
    local startRoom = GOLCG.GAME:GetLevel():GetStartingRoomIndex()

    player:AnimateTeleport(false)
    GOLCG.GAME:StartRoomTransition(
        startRoom, 
        Direction.NO_DIRECTION,
        RoomTransitionAnim.TELEPORT,
        player
    )

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then 
        player:AddWisp(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, player.Position)
        player:AddWisp(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, player.Position)
        player:AddWisp(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, player.Position)
        player:AddWisp(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, player.Position)
        player:AddWisp(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, player.Position)
    end

    GOLCG:SaveData(json.encode(GOLCG.SAVEDATA))

    if player:GetCollectibleRNG(item.ID):RandomInt(100)+1 <= 50 then
        player:RemoveCollectible(item.ID)
        player:AddCollectible(CollectibleType.COLLECTIBLE_HOURGLASS)
    end
end

function item:OnNewRoom()
    if GOLCG.SAVEDATA.HOURGLASS.IsActive then
        local room = GOLCG.GAME:GetRoom()
        local level = GOLCG.GAME:GetLevel()
        local roomIndex = level:GetCurrentRoomDesc().SafeGridIndex

        if not GOLCG.SAVEDATA.HOURGLASS.Rooms["R"..roomIndex] and not room:IsFirstVisit() then
            local player = GOLCG.GAME:GetPlayer(0)
            local roomType = room:GetType()
            local roomdesc = level:GetCurrentRoomDesc()

            -- Dogma room pre-fight: stageID: 35, type: 1, variant: 4, subtype: 3
            -- Dogma room fight: stageID: 35, type: 1, variant: 1000, subtype: 3
            -- Beast room fight: stageID: 35, type: 16, variant: 666, subtype: 4

            if not (roomdesc.Data.StageID == 35 and (roomdesc.Data.Variant == 1000 or roomdesc.Data.Variant == 666))
            and roomType ~= RoomType.ROOM_BOSS and roomType ~= RoomType.ROOM_DEVIL and roomType ~= RoomType.ROOM_ANGEL then    -- Dogma and beast excluded for glitch related reasons
                player:UseActiveItem(CollectibleType.COLLECTIBLE_D7, false, true, false, false) -- Reroll room
            end

            player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, false, true, false, false) -- Reroll pedestals
            player:UseActiveItem(CollectibleType.COLLECTIBLE_D20, false, true, false, false) -- Reroll pickups
        end

        GOLCG.SAVEDATA.HOURGLASS.Rooms["R"..roomIndex] = true
        GOLCG:SaveData(json.encode(GOLCG.SAVEDATA))
    end
end

function item:OnNewFloor()
    if GOLCG.SAVEDATA.HOURGLASS.IsActive then
        GOLCG.SAVEDATA.HOURGLASS = { IsActive = false, Rooms = {} }
        GOLCG:SaveData(json.encode(GOLCG.SAVEDATA))
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
GOLCG:AddCallback(ModCallbacks.MC_USE_ITEM,          item.OnUse,     item.ID)
GOLCG:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,     item.OnNewRoom         )
GOLCG:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,    item.OnNewFloor        )

return item