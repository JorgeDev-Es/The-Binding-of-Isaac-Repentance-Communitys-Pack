--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Limestone carving"),

    ROCK_CHANCE = 35,
    MAX_ROCK = 3,
    MAX_COAL = 5,
    MAX_TINT = 2,

    GRID_WHITELIST = {
        [GridEntityType.GRID_ROCK] = 2,
        [GridEntityType.GRID_ROCKT] = 2,
        [GridEntityType.GRID_ROCK_BOMB] = 2,
        [GridEntityType.GRID_ROCK_ALT] = 2,
        [GridEntityType.GRID_ROCK_SS] = 2,
        [GridEntityType.GRID_ROCK_SPIKED] = 2,
        [GridEntityType.GRID_ROCK_ALT2] = 2,
        [GridEntityType.GRID_ROCK_GOLD] = 2,
    },

    TRAN_SUBTYPES = {
        [0] = 0,
        [1] = 3,
        [2] = 6,
    },

    KEY="LICA",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_GREED_TREASUREL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Limestone Carving", DESC = "Rock spiders are friendly#Rocks may spawn rock spiders when broken" },
	    { LANG = "ru",    NAME = "Резьба по известняку", DESC = "Каменные пауки дружелюбны#Камни могут создать каменных пауков, когда они разбиваются" },
        { LANG = "spa",   NAME = "Piedra Caliza tallada", DESC = "Las arañas con piedras se vuelven amistosas#Las rocas pueden generar arañas con piedras al romperlas" },
	    { LANG = "zh_cn", NAME = "石灰石石雕", DESC = "岩石蜘蛛变得友好#摧毁岩石时有35%的概率生成岩石蜘蛛" },
        { LANG = "ko_kr", NAME = "석회암 조각", DESC = "모든 Rock spiders 몬스터가 아군이 됩니다.#돌 오브젝트 파괴 시 35%의 확률로 아군 Rock spider가 소환됩니다." },
    },
    EID_TRANS = {"collectible", Isaac.GetItemIdByName("Limestone carving"), 13 },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "All rock spiders are replaced with a friendly variant. Unless the player has more than 20 already, then they will be killed instead (tinted rock spiders are excluded)."},
            {str = "Breaking rocks has a 35% chance to spawn friendly rock spiders. If the player has more than 20 rock spiders then none will spawn from breaking rocks (tinted rock spiders are excluded)."},
            {str = "Counts towards the Spider Baby transformation."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function selectSpider(type)
    if type == GridEntityType.GRID_ROCK_SS or type == GridEntityType.GRID_ROCKT then
        return { subtype = 3, max = item.MAX_TINT } -- Tinted
    elseif type == GridEntityType.GRID_ROCK_BOMB then
        return { subtype = 6, max = item.MAX_COAL } -- Coal
    else
        return { subtype = 0, max = item.MAX_ROCK }
    end
end

function item:OnSpawn(NPC)
    NPC:Remove()
    QUACOL.SeedSpawn(3, 3320, item.TRAN_SUBTYPES[NPC.Variant]+math.random(2), NPC.Position, Vector(0,0), NPC)
end

function item:OnBreak(gridEnt)
    if item.GRID_WHITELIST[gridEnt.Desc.Type] == gridEnt.Desc.State then
        local player = Isaac.GetPlayer()
        local data = selectSpider(gridEnt.Desc.Type)
        local RNG = player:GetCollectibleRNG(item.ID)

        if (data.subtype > 0 or RNG:RandomInt(100)+1 <= item.ROCK_CHANCE) then
            for i=1, RNG:RandomInt(data.max)+1 do
                QUACOL.SeedSpawn(3, 3320, data.subtype+math.random(2), gridEnt.Position, Vector(0,0), player)
            end
        end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()  
    QUACOL:AddCallback(ModCallbacks.MC_POST_NPC_INIT, item.OnSpawn, 818)
    TCC_API:AddTCCCallback("TCC_GRID_BREAK", item.OnBreak)
end

function item:Disable()
    QUACOL:RemoveCallback(ModCallbacks.MC_POST_NPC_INIT, item.OnSpawn, 818)
    TCC_API:RemoveTCCCallback("TCC_GRID_BREAK", item.OnBreak)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item