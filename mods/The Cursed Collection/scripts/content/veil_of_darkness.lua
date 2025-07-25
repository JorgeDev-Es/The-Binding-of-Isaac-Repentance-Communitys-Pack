--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Veil of darkness"),
    CURSE = Isaac.GetCurseIdByName("Curse of Blight"),

    DAMAGE = 0.5,
    ITEMS = {
        259, -- Dark matter
        420, -- Black powder
        433, -- My shadow
        468, -- Shade
        442, -- Dark princes crown
        311, -- Judas's shadow
        159, -- Spirit of the night ???
        399, -- Maw of the void ??? 
    },

    TYPE = 100,
    KEY="VEDA",
    POOLS = {
        ItemPoolType.POOL_DEVIL,
        ItemPoolType.POOL_CURSE,
        ItemPoolType.POOL_GREED_DEVIL,
        ItemPoolType.POOL_GREED_CURSE,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Veil of darkness", DESC = "{{CURCOL_blight}} Grants Curse of Blight#{{BlackHeart}} +3 black hearts#{{ArrowUp}} +0.5 damage#Grants one of the following:#{{Blank}} {{Collectible159}}{{Collectible259}}{{Collectible311}}{{Collectible399}}{{Collectible420}}{{Collectible433}}{{Collectible442}}{{Collectible468}}" },
        { LANG = "ru",    NAME = "Завеса тьмы", DESC = "{{CURCOL_blight}} Дарует проклятие порчи#{{BlackHeart}} +3 черные сердца#{{ArrowUp}} +0.5 урона#Дает одно из следующих:#{{Blank}} {{Collectible159}}{{Collectible259}}{{Collectible311}}{{Collectible399}}{{Collectible420}}{{Collectible433}}{{Collectible442}}{{Collectible468}}" },
        { LANG = "spa",   NAME = "Velo de las tinieblas", DESC = "{{CURCOL_blight}} Otorga la Maldición de la plaga#{{BlackHeart}} +3 black hearts#{{ArrowUp}} {{Damage}} Daño +0.5#Otorga uno de los siguientes efectos:#{{Blank}} {{Collectible159}}{{Collectible259}}{{Collectible311}}{{Collectible399}}{{Collectible420}}{{Collectible433}}{{Collectible442}}{{Collectible468}}" },
        { LANG = "zh_cn", NAME = "黑暗面纱", DESC = "{{CURCOL_blight}} 角色每层都会被赋予“妨害诅咒”#{{BlackHeart}} +3 黑心#{{ArrowUp}} +0.5 攻击#给予下列道具中的一个：#{{Collectible159}}{{Collectible259}}{{Collectible311}}{{Collectible399}}{{Collectible420}}{{Collectible433}}{{Collectible442}}{{Collectible468}}#{{Warning}} 持有该道具会摧毁获得的{{Collectible260}}黑蜡烛" },
        { LANG = "ko_kr", NAME = "어둠의 베일", DESC = "!!! Black Candle 아이템이 제거됩니다.#{{CURCOL_blight}} 항상 황폐의 저주에 걸립니다.#{{BlackHeart}} 블랙하트 +3#{{ArrowUp}} {{Damage}}공격력 +0.5#!!! 획득 시 아래 아이템 중 하나를 추가로 획득:#{{Blank}} {{Collectible159}}{{Collectible259}}{{Collectible311}}{{Collectible399}}{{Collectible420}}{{Collectible433}}{{Collectible442}}{{Collectible468}}" },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "When picked up this item will grant the player 3 black hearts, +1.5 damage and a dark / shadow / black themed item."},
            {str = 'Grants "Curse of Blight" upon pickup and on every new floor.'},
            {str = 'The granted curse may be removed via special means (cursed dice, cursed flame, etc...).'},
            {str = 'Disabling "Curse of Blight" via MCM does not prevent this item from granting the curse.'},
        },
        { -- Interactions
            {str = "Interactions", fsize = 2, clr = 3, halign = 0},
            {str = "If the player has black candle when the item attempts to grant a curse then black candle will be given a proper burial."}
        }
    }
}

local hasLoaded = false
--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function flag(i) return 2^(i-1) end

function item:OnCollect(player, collectible, touched, isTrinket)
    if not isTrinket and not touched then
        local newItem = CURCOL.CONF:GetCollectible(item.ITEMS[player:GetCollectibleRNG(collectible):RandomInt(#item.ITEMS)+1])
        player:AnimateCollectible(newItem.ID)
        player:QueueItem(newItem)

        if item.CURSE > 0 then
            CURCOL.tryHoldAFuneral()
            CURCOL.GAME:GetLevel():AddCurse(flag(item.CURSE))
            TCC_API.ReloadCurses()
        end
    end
end

function item:OnCache(player, flag)
    if TCC_API:Has(item.KEY, player) then
        player.Damage = player.Damage + (item.DAMAGE*TCC_API:Has(item.KEY, player))
    end
end

function item:OnFloor()
    if hasLoaded and item.CURSE > 0 then
        CURCOL.tryHoldAFuneral()
        CURCOL.GAME:GetLevel():AddCurse(flag(item.CURSE))
        TCC_API.ReloadCurses()
    end
end

function item:OnColInit(pickup) if pickup.SubType == item.ID then CURCOL:Blight(pickup) end end
function item:OnColRender(pickup) if pickup.SubType == item.ID then CURCOL:OnBlightRender(pickup, true) end end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()  
    CURCOL:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, item.OnCache, CacheFlag.CACHE_DAMAGE)
    CURCOL:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,  item.OnFloor)
    CURCOL:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function() hasLoaded = false end)

    CURCOL.checkFlags(item.KEY, CacheFlag.CACHE_DAMAGE)

    hasLoaded = true
end

function item:Disable()
    CURCOL:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE, item.OnCache, CacheFlag.CACHE_DAMAGE)
    CURCOL:RemoveCallback(ModCallbacks.MC_POST_NEW_LEVEL,  item.OnFloor)
    CURCOL:RemoveCallback(ModCallbacks.MC_PRE_GAME_EXIT, function() hasLoaded = false end)
end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

CURCOL:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, item.OnColInit, 100)
CURCOL:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, item.OnColRender, 100)

TCC_API:AddTCCCallback("TCC_EXIT_QUEUE", item.OnCollect, item.ID)

return item