local json = require("json")

--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Anathema"),

    DAMAGE = 1.6,

    TYPE = 100,
    KEY="ANA",
    POOLS = {
        ItemPoolType.POOL_DEVIL,
        ItemPoolType.POOL_CURSE,
        ItemPoolType.POOL_ULTRA_SECRET,
        ItemPoolType.POOL_GREED_DEVIL,
        ItemPoolType.POOL_GREED_CURSE,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Anathema", DESC = "{{ArrowUp}} x1.6 damage#Guarantees a curse every floor" },
        { LANG = "ru",    NAME = "Анафема", DESC = "{{ArrowUp}} x1.6 урон#Гарантирует проклятие на каждом этаже" },
        { LANG = "spa",   NAME = "Anatema", DESC = "{{ArrowUp}} Daño x1.6#Otorga una maldición por cada piso" },
        { LANG = "zh_cn", NAME = "咒逐", DESC = "{{ArrowUp}} ×1.6 攻击倍率#角色每层都会被赋予诅咒#{{Warning}} 持有该道具会摧毁获得的{{Collectible260}}黑蜡烛" },
        { LANG = "ko_kr", NAME = "저주", DESC = "{{ArrowUp}} {{Damage}}공격력 배율 x1.6#!!! Black Candle 아이템이 제거됩니다.#!!! 매 층마다 저주가 항상 발동합니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Grants the player a x1.6 damage multiplier"},
            {str = "Every floor including the floor on which the item was taken will have a curse."}
        },
        { -- Interactions
            {str = "Interactions", fsize = 2, clr = 3, halign = 0},
            {str = "If the player has black candle when the item attempts to grant a curse then black candle will be given a proper burial."}
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function item:OnCollect(player, collectible, touched, isTrinket)
    if not isTrinket and not touched then
        local curses = CURCOL.GAME:GetLevel():GetCurses()

        if curses == LevelCurse.CURSE_NONE then
            CURCOL.tryHoldAFuneral()
            TCC_API:AddRandomCurse()
        end
    end
end

function item:OnFloor()
    local curses = CURCOL.GAME:GetLevel():GetCurses()

    if curses == LevelCurse.CURSE_NONE then
        CURCOL.tryHoldAFuneral()
        TCC_API:AddRandomCurse()
    end
end

function item:OnCache(player)
    if TCC_API:Has(item.KEY, player) > 0 then
        player.Damage = player.Damage*item.DAMAGE
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    CURCOL:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,  item.OnCache, CacheFlag.CACHE_DAMAGE)
    CURCOL:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,  item.OnFloor)
    CURCOL.checkFlags(item.KEY, CacheFlag.CACHE_DAMAGE)
end

function item:Disable()
    CURCOL:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE,  item.OnCache, CacheFlag.CACHE_DAMAGE)
    CURCOL:RemoveCallback(ModCallbacks.MC_POST_NEW_LEVEL,  item.OnFloor)
end

TCC_API:AddTCCCallback("TCC_EXIT_QUEUE", item.OnCollect, item.ID)
TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item