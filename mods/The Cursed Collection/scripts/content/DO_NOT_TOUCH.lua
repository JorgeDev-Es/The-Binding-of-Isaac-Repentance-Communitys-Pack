local json = require("json")

--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("DO NOT TOUCH"),

    CHANCE = 11,

    TYPE = 100,
    KEY="DONOTO",
    POOLS = {
        ItemPoolType.POOL_TREASURE,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "DO NOT TOUCH", DESC = "Chance to spawn red buttons in rooms#Special rooms are excluded" },
        { LANG = "ru",    NAME = "НЕ ТРОГАТЬ", DESC = "Шанс появления красных кнопок в комнатах#Специальные комнаты исключены" },
        { LANG = "spa",   NAME = "NO TOCAR", DESC = "Posibilidad de generar botones rojos#Se excluyen salas especiales" },
        { LANG = "zh_cn", NAME = "千 万 别 碰", DESC = "进入有怪物的未探索房间时有11%的概率生成秒杀按钮#只在普通房间生效" },
        { LANG = "ko_kr", NAME = "취급주의", DESC = "일반 방 진입 시 11%의 확률로 랜덤 위치에 빨간 버튼이 생성됩니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "When entering a room with enemies in it for the first time this item has a 11% chance to spawn a red button at a random position within the room."}
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnRoom()
    local room = CURCOL.GAME:GetRoom()

    if room:IsFirstVisit() and room:GetAliveEnemiesCount() > 0 and room:GetType() == RoomType.ROOM_DEFAULT then
        local RNG = RNG()
        local level = CURCOL.GAME:GetLevel()

        RNG:SetSeed(room:GetSpawnSeed(), 35)

        if RNG:RandomInt(100)+1 <= item.CHANCE then
            Isaac.ExecuteCommand ('gridspawn 4500.9')
        end
    end
end
-- 4500 9 0

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable() CURCOL:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, item.OnRoom) end
function item:Disable() CURCOL:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, item.OnRoom) end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item