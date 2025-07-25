--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local trinket = {
    ID = Isaac.GetTrinketIdByName("Slot machine handle"),
    
    POS = {
        [1] = Vector(210, 220), -- top left
        [2] = Vector(430, 220), -- top right
        [3] = Vector(210, 380), -- bottom left
        [4] = Vector(430, 380), -- bottom right
        [5] = Vector(320, 220), -- top center
        [6] = Vector(320, 380), -- bottom center
    
        [7] = Vector(210, 300), -- left center
        [8] = Vector(430, 300), -- right center
    
        [9] = Vector(100, 220), -- top left far
        [10] = Vector(540, 220), -- top right far
        [11] = Vector(100, 380), -- bottom left far
        [12] = Vector(540, 380), -- bottom right far
        [13] = Vector(100, 300), -- left center far
        [14] = Vector(540, 300), -- right center far
    },

    KEY="SLMAHA",
    TYPE = 350,
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Slot Machine Handle", DESC = "Spawns slot machines and beggars when entering a new floor" },
        { LANG = "ru",    NAME = "Ручка игрового автомата", DESC = "Создает слоты и попрошаек при входе на новый этаж" },
        { LANG = "spa",   NAME = "Mango de máquina tragaperras", DESC = "Genera mendigos y máquinas tragaperras al entrar a un neuvo piso" },
        { LANG = "zh_cn", NAME = "赌博机拉杆", DESC = "进入新楼层时生成随机机器或乞丐" },
        { LANG = "ko_kr", NAME = "슬롯머신 손잡이", DESC = "스테이지 진입 시 슬롯머신과 거지를 소환합니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "When entering a new floor some slot machines and beggars will be spawned."},
            {str = "The minimum amount spawned is 4 and is increased with +2 for every trinket multiplier."}
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function getCarriedAmount()
    local count = 0
    local numPlayers = GOLCG.GAME:GetNumPlayers()

    for i=1,numPlayers do
        local player = GOLCG.GAME:GetPlayer(i-1)
        local multiplier = player:GetTrinketMultiplier(trinket.ID)

        if multiplier > 0 then
            count = count + multiplier
        end
    end

    return count
end

function trinket:OnNewFloor()
    -- use GetTrinketMultiplier instead of HasGlo because HasGlo won't be updated yet when this callback is called
    local multiplier = getCarriedAmount() --TCC_API:HasGlo(trinket.KEY)

    if multiplier > 0 then
        local room = GOLCG.GAME:GetRoom()

        for i=1, 2+((multiplier*2 > 14) and 14 or multiplier*2) do
            GOLCG.SeedSpawn(EntityType.ENTITY_SLOT, GOLCG.machines[math.random(#GOLCG.machines)], 0, trinket.POS[i], Vector(0, 0), nil)
        end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function trinket:Enable()  GOLCG:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,    trinket.OnNewFloor) end
function trinket:Disable() GOLCG:RemoveCallback(ModCallbacks.MC_POST_NEW_LEVEL, trinket.OnNewFloor) end

TCC_API:AddTCCInvManager(trinket.ID, trinket.TYPE, trinket.KEY, trinket.Enable, trinket.Disable)

return trinket