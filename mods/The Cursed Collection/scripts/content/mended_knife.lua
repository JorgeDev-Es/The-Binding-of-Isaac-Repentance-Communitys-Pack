--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Mended knife"),
    NPC = FamiliarVariant.KNIFE_FULL,

    KEY="MEKN",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_BABY_SHOP,
        ItemPoolType.POOL_GREED_TREASUREL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Mended Knife", DESC = "Grants a full knife familiar#Damages enemies#Can open the flesh door" },
        { LANG = "ru",    NAME = "Починенный нож", DESC = "Дает спутника с полным ножом#Наносит урон врагам#Может открыть дверь плоти" },
        { LANG = "spa",   NAME = "Cuchillo remendado", DESC = "Otorga un cuchillo familiar completo#Daña a los enemigos" },
        { LANG = "zh_cn", NAME = "修好的菜刀", DESC = "获得一只完整菜刀跟班#可以打开肉门" },
        { LANG = "ko_kr", NAME = "완성된 칼 조각", DESC = "공격하는 방향으로 칼을 날릴 수 있습니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Grants a knife familiar that launches itself in the direction Isaac shoots, Dealing 25 damage to and piercing enemies it hits."},
            {str = "The knife is able to open the red door at the end of mausoleum / gehenna II without dissapearing afterwards."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:checkKnifes(player)
    local num = math.floor((player:GetCollectibleNum(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1) + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2)) / 2) + player:GetCollectibleNum(item.ID)+player:GetEffects():GetCollectibleEffectNum(item.ID)
    player:CheckFamiliar(
        item.NPC, 
        num, 
        player:GetCollectibleRNG(item.ID)
    )
end

local function checkPlayers()
    for i=1, CURCOL.GAME:GetNumPlayers() do
        local player = CURCOL.GAME:GetPlayer(tostring((i-1)))
        item:checkKnifes(player)
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    CURCOL:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, item.checkKnifes, CacheFlag.CACHE_FAMILIARS)
    checkPlayers()
end

function item:Disable()
    CURCOL:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE, item.checkKnifes, CacheFlag.CACHE_FAMILIARS)
    checkPlayers()
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item
