--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetTrinketIdByName("Tuff cookie"),

    CHANCE = 30,
    CHECKS = 20,

    WHITELIST = {
        [GridEntityType.GRID_ROCK] = true,
        -- [GridEntityType.GRID_ROCKB] = true,
        [GridEntityType.GRID_ROCKT] = true,
        -- [GridEntityType.GRID_ROCK_BOMB] = true, What if you enter a room full of these rocks and they instantly explode....
        [GridEntityType.GRID_ROCK_ALT] = true,
        [GridEntityType.GRID_ROCK_SS] = true,
    },

    EID = {
        en_us = {
            ["Name"] = "{{QUACOL_grimace}} Tuff bomb grimace",
            ["Description"] = "{{Warning}} Breaks when the room is left",
        },
        spa =  {
            ["Name"] = "{{QUACOL_grimace}} Mueca de bombas",
            ["Description"] = "{{Warning}} Se destruirá al abandonar la sala",
        },
        zh_cn =  {
            ["Name"] = "{{QUACOL_grimace}} 凝灰岩炸弹石鬼面",
            ["Description"] = "{{Warning}} 将在离开房间后消失",
        },
        ko_kr = {
            ["Name"] = "{{QUACOL_grimace}} 터프한 바위",
            ["Description"] = "{{Warning}} 방을 나가면 사라집니다.",
        },
    },

    KEY="TUCO",
    TYPE = 350,
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Tuff Cookie", DESC = "May spawn a temporary bomb grimace on first visits of rooms" },
	    { LANG = "ru",    NAME = "Туф Печенька", DESC = "Может вызвать временную бомбовую гримасу при первом посещении комнат." },
        { LANG = "spa",   NAME = "Galleta maciza", DESC = "Posibilidad de generar una mueca de bombas al entrar a una nueva habitación" },
        { LANG = "zh_cn", NAME = "凝灰岩曲奇", DESC = "进入未探索的房间时有30%的概率生成一个临时的炸弹石鬼面" },
        { LANG = "ko_kr", NAME = "터프한 쿠키", DESC = "방 진입 시 30%의 확률로 랜덤 돌 오브젝트를 터프한 바위(Tuff bomb grimace)로 바꿉니다.#방 안에 돌이 없을 경우 방 중앙에 소환됩니다.#터프한 바위는 방을 나가면 사라집니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Has a 30% chance to replace a rock with a temporary bomb grimace when entering a room for the first time."},
            {str = "If no rock is found then it will spawn this grimace on a free position close to the center of the room."},
            {str = "This chance is +30% for every trinket multiplier."},
            {str = "The bomb grimace dissapears when exiting a room."},
        }
    }
}

if EID then
    local mySprite = Sprite()
    mySprite:Load("gfx/ui/QUACOL_grimace_icon.anm2", true)
    EID:addIcon("QUACOL_grimace", "Idle", -1, 9, 9, -1, 0, mySprite)
end

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function initGrimace(pos)
    if not pos then return end
    local player = Isaac.GetPlayer()
    local grimace = QUACOL.SeedSpawn(809, 0, 0, pos, Vector(0,0), player)
    grimace.TargetPosition = pos

    local sprite =  grimace:GetSprite()

    sprite:ReplaceSpritesheet(0, 'gfx/monsters/QUACOL_tuff_bomb_grimace.png')
    sprite:LoadGraphics()
    grimace:Update()

    if EID then
        grimace:GetData().EID_Description = (item.EID[EID.UserConfig.Language] or item.EID.en_us)
    end

    Isaac.Spawn(EntityType.ENTITY_EFFECT, 149, 0, pos, Vector(0,0), player)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, 16, 67, pos, Vector(0,0), player)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, 147, 3, pos, Vector(0,0), player)
end

function item:OnEnter()
    if QUACOL.GAME:GetRoom():IsFirstVisit() 
    and Isaac.GetPlayer():GetCollectibleRNG(item.ID):RandomInt(100)+1 <= item.CHANCE*TCC_API:HasGlo(item.KEY) 
    and QUACOL.GAME:GetLevel():GetStartingRoomIndex() ~= QUACOL.GAME:GetLevel():GetCurrentRoomIndex() then
        for i=1, item.CHECKS do
            local room = QUACOL.GAME:GetRoom()
            local pos = room:GetRandomPosition(0)
            local gridEnt = room:GetGridEntityFromPos(pos)

            if gridEnt and item.WHITELIST[gridEnt:GetType()] and not room:GetGridEntityFromPos(pos+Vector(0,30)) and gridEnt:ToRock() then
                pos = room:GetGridPosition(gridEnt:GetGridIndex())
                gridEnt:Hurt(99)
                gridEnt:Destroy()

                initGrimace(pos)

                return
            end
        end

        local room = QUACOL.GAME:GetRoom()
        initGrimace(room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true, false))
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:PostLoad()
    if FiendFolio and FiendFolio.GolemTrinketWhitelist then
        FiendFolio.GolemTrinketWhitelist[item.ID] = 1
    end

    QUACOL:RemoveCallback(ModCallbacks.MC_INPUT_ACTION, item.PostLoad)
end

QUACOL:AddCallback(ModCallbacks.MC_INPUT_ACTION, item.PostLoad)

function item:Enable() 
    QUACOL:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, item.OnEnter)
end

function item:Disable()
    QUACOL:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, item.OnEnter)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item