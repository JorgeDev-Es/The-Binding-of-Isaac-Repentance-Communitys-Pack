--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Cursed dice"),

    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_CURSE,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_CURSE,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Cursed Dice", DESC = "{{HalfBlackHeart}} +½ black heart#Rerolls one of your curses#Grants a curse if none are active" },
        { LANG = "ru",    NAME = "Проклятые кости", DESC = "{{HalfBlackHeart}} +½ черное сердце#Изменяет одно из ваших проклятий#Дает проклятие, если ни одного нет" },
        { LANG = "spa",   NAME = "Dado Maldito", DESC = "{{HalfBlackHeart}} +½ Corazón negro#Cambiará una de las maldiciones que tienes#Garantiza una maldición si no tienes una activa" },
        { LANG = "zh_cn", NAME = "诅咒六面骰", DESC = "{{HalfBlackHeart}} 使用后 +½ 黑心#重随一个当前的诅咒#没有诅咒就赋予一个诅咒#{{Warning}} 持有该道具会摧毁获得的{{Collectible260}}黑蜡烛" },
        { LANG = "ko_kr", NAME = "저주받은 주사위", DESC = "{{HalfBlackHeart}} 블랙하트 +½ #현재 걸린 저주를 다른 저주로 바꿉니다.#!!! Black Candle 아이템이 제거됩니다.#걸린 저주가 없을 경우 랜덤 저주에 새로 걸립니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "When used grants half a black heart to the player."},
            {str = "The item will also replace one of the currently active curses with another randomly selected one. (This includes both vanilla and custom curses)"},
            {str = "If no curses were active when the item was used then a random curse will be granted."},
            {str = "Disabling custom curses via MCM will prevent this item from granting them."},
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
function item:OnUse(_, RNG, player)
    TCC_API:AddRandomCurse(RNG, true)
    CURCOL.tryHoldAFuneral()
    player:AddBlackHearts(1)
    return true
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
CURCOL:AddCallback(ModCallbacks.MC_USE_ITEM, item.OnUse, item.ID)

return item