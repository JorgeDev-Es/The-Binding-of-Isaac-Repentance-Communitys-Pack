--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Cursed flame"),

    LUCK = 1.5,
    SPEED = 0.04,
    DAMAGE = 1,
    SHOTSPEED = 0.05,
    RANGE = 1,
    DELAY = 1,

    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_CURSE,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_CURSE,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Cursed Flame", DESC = "{{ArrowDown}} Grants a curse#{{ArrowUp}} All stats up for every active curse while carried#Replaces a curse if 3 or more are active" },
        { LANG = "ru",    NAME = "Проклятое пламя", DESC = "{{ArrowDown}} Накладывает проклятие#{{ArrowUp}} Повышает все характеристики за каждое проклятия во время ношения#Заменяет проклятие, если наложено 3 или более" },
        { LANG = "spa",   NAME = "Flama maldita", DESC = "{{ArrowDown}} Garantiza una maldición#{{ArrowUp}} Aumentará todos tus stats por cada maldición mientras lo tengas#Reemplazará una maldición si hay 3 o más activas" },
        { LANG = "zh_cn", NAME = "诅咒之火", DESC = "{{ArrowDown}} 使用后赋予一个诅咒#{{ArrowUp}} 每拥有一个诅咒获得一次全属性提升#最多拥有三个诅咒#{{Warning}} 持有该道具会摧毁获得的{{Collectible260}}黑蜡烛" },
        { LANG = "ko_kr", NAME = "저주받은 불꽃", DESC = "{{ArrowDown}} 사용 시 추가로 랜덤 저주에 걸립니다.(최대 3)#!!! Black Candle 아이템이 제거됩니다.#{{ArrowUp}} 소지 시 걸린 저주의 갯수만큼 모든 능력치 증가" },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "When used this item will grant the player a random curse."},
            {str = "If the player has 3 or more curses then the item will replace a curse instead."},
            {str = "For every active curse the item will grant the following stats: 1.5 luck, 0.04 speed, 1 damage, 0.05 shotspeed, 1 range and -1 tear delay."},
        },
        { -- Interactions
            {str = "Interactions", fsize = 2, clr = 3, halign = 0},
            {str = "If the player has black candle when the item attempts to grant a curse then black candle will be given a proper burial."}
        }
    }
}

local stats = {
    [CacheFlag.CACHE_SHOTSPEED] = {key = "SHOTSPEED", name = "ShotSpeed"},
    [CacheFlag.CACHE_RANGE] = {key = "RANGE", name = "TearRange"},
    [CacheFlag.CACHE_SPEED] =  {key = "SPEED", name = "MoveSpeed"},
    [CacheFlag.CACHE_DAMAGE] = {key = "DAMAGE", name = "Damage"},
    [CacheFlag.CACHE_LUCK] = {key = "LUCK", name = "Luck"},
    [CacheFlag.CACHE_FIREDELAY] = {key = "DELAY", name = "MaxFireDelay"}
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function CountOnBits(x)
    local count = 0
    while x ~= 0 do
        if x & 1 ~= 0 then count = count+1 end
        x = x >> 1;
    end
    return count
end

function item:OnUse(_, RNG, player)
    local curses = CURCOL.GAME:GetLevel():GetCurses()
    local amount = CountOnBits(curses)

    TCC_API:AddRandomCurse(player:GetCollectibleRNG(item.ID), amount >= 3)

    if curses == CURCOL.GAME:GetLevel():GetCurses() then
        player:AnimateSad()
    else
        CURCOL.tryHoldAFuneral()
        CURCOL.SFX:Play(SoundEffect.SOUND_FIREDEATH_HISS)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_FIREDELAY)
        return true
    end
end

-- Stolen from Rep+ because i was busy. Thanks for the code :P
local function GetTears(fireDelay)
    return 30 / (fireDelay + 1)
end

local function GetFireDelay(tears)
    return math.max(30 / tears - 1, -0.9999)
end


function item:OnCache(player, flag) -- Reload/Apply room and floor based stats
    if player:HasCollectible(item.ID) and stats[flag] then
        local amount = CountOnBits(CURCOL.GAME:GetLevel():GetCurses())
        local stat = stats[flag]

        if flag == CacheFlag.CACHE_SPEED then
            player[stat.name] = (player[stat.name] + (item[stat.key]*amount)) > 2 and 2 or (player[stat.name] + (item[stat.key]*amount))
        elseif flag == CacheFlag.CACHE_FIREDELAY then
            player[stat.name] = GetFireDelay(GetTears(player.MaxFireDelay) + (item[stat.key]*amount))
        else
            player[stat.name] = (player[stat.name] + (item[stat.key]*amount))
        end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
CURCOL:AddCallback(ModCallbacks.MC_USE_ITEM, item.OnUse, item.ID)
CURCOL:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, item.OnCache)

return item