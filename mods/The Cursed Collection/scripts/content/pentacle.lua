local json = require("json")

--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Pentacle"),

    CHANCE = 50,

    TYPE = 100,
    KEY="PEN",
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_ANGEL,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_ANGEL,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Pentacle", DESC = "{{Collectible712}} Picking up items may also grant an item wisp of the same type" },
        { LANG = "ru",    NAME = "Пентакль", DESC = "{{Collectible712}} Подбирая артефакты, вы также можете получить огонёк артефакта того же типа." },
        { LANG = "spa",   NAME = "Pentagrama", DESC = "{{Collectible712}} Tomar objetos podrá generar un fuego del su mismo tipo" },
        { LANG = "zh_cn", NAME = "五星召唤阵", DESC = "{{Collectible712}} 拾取道具时有50%的概率生成一个拾取的道具的灵火" },
        { LANG = "ko_kr", NAME = "별 모양의 마법", DESC = "{{Collectible712}} 가능한 경우, 패시브 아이템 획득 시 해당 아이템에 대응되는 레메게톤 불꽃을 추가로 소환합니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Grabbing collectibles from their pedestal has a 50% chance to also grant an item wisp of the aforementioned item."},
            {str = "Items that are not summonable as wisps are excluded from this effect."},
        }
    }
}

--TODO: Make texture look more like a pentacle?
--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnCollect(player, collectible, touched, isTrinket)
    if not isTrinket and not touched and TCC_API:Has(item.KEY, player) and player:GetCollectibleRNG(item.ID):RandomInt(100)+1 <= item.CHANCE then
        local conf = CURCOL.CONF:GetCollectible(collectible)

        if conf and conf.Tags % (ItemConfig.TAG_SUMMONABLE+ItemConfig.TAG_SUMMONABLE) >= ItemConfig.TAG_SUMMONABLE then
            player:AddItemWisp(collectible, player.Position, true)
        end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable() TCC_API:AddTCCCallback("TCC_EXIT_QUEUE",  item.OnCollect) end
function item:Disable() TCC_API:RemoveTCCCallback("TCC_EXIT_QUEUE",  item.OnCollect) end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item