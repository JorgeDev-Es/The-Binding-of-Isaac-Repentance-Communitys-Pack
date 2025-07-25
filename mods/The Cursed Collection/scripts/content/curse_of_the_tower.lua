local json = require("json")

--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Reverse of the tower"),
    CURSE = Isaac.GetCurseIdByName("Curse of Creation"),

    CHANCE = 15,
    GRID_LIST = {
        [GridEntityType.GRID_ROCK] = true,
        [GridEntityType.GRID_ROCKT] = true,
        [GridEntityType.GRID_ROCK_BOMB] = true,
        [GridEntityType.GRID_ROCK_ALT] = true,
        [GridEntityType.GRID_ROCK_SS] = true,
        [GridEntityType.GRID_ROCK_SPIKED] = true,
        [GridEntityType.GRID_ROCK_ALT2] = true,
        [GridEntityType.GRID_ROCK_GOLD] = true,
    },

    TYPE = 100,
    KEY="REOTTO",
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_CURSE,
        ItemPoolType.POOL_RED_CHEST,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_CURSE,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Reverse of the Tower", DESC = '{{CURCOL_crea}} Grants Curse of Creation#{{Card72}} Spawn rocks when taking damage' },
        { LANG = "ru",    NAME = "Обратная сторона башни", DESC = '{{CURCOL_crea}} Дарует проклятие созидания#{{Card72}} Создаваёт камни при получении урона' },
        { LANG = "spa",   NAME = "Reversión de la Torre", DESC = "{{CURCOL_crea}} Da la Maldición de la Creación#{{Card72}} Genera rocas al recibir daño" },
        { LANG = "zh_cn", NAME = "逆位塔之诅咒", DESC = "{{CURCOL_crea}} 角色每层都会被赋予“创造诅咒”#{{Card72}} 角色受伤时有15%的概率触发“XVI-塔？”的效果#{{Warning}} 持有该道具会摧毁获得的{{Collectible260}}黑蜡烛" },
        { LANG = "ko_kr", NAME = "역바벨탑의 저주", DESC = '!!! Black Candle 아이템이 제거됩니다.#{{CURCOL_crea}} 항상 창조의 저주에 걸립니다.#{{Card72}} 피격시 15%의 확률로 5~12개의 장애물이 생성됩니다.' },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = 'Has a 15% chance to spawn between 5 and 12 rocks when taking damage.'},
            {str = 'Grants "Curse of Creation" upon pickup and on every new floor.'},
            {str = 'The granted curse may be removed via special means (cursed dice, cursed flame, etc...).'},
            {str = 'Disabling "Curse of Creation" via MCM does not prevent this item from granting the curse.'},
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

function item:OnDamage(entity, _, flags, _, _)
    local player = entity:ToPlayer()

    if TCC_API:Has(item.KEY, player) 
    and #Isaac.FindByType (5, 340, -1, true) == 0
    and #Isaac.FindByType (5, 370, -1, true) == 0 then
        for i=-1, player:GetCollectibleRNG(item.ID):RandomInt(6)+7 do
            Isaac.Spawn(1000, EffectVariant.REVERSE_EXPLOSION, 1, Isaac.GetRandomPosition(), Vector(0,0), nil)
        end

        CURCOL.SFX:Play(SoundEffect.SOUND_REVERSE_EXPLOSION)
    end
end

function item:OnCurse(player)
    if item.CURSE > 0 then
        CURCOL.tryHoldAFuneral()
        CURCOL.GAME:GetLevel():AddCurse(flag(item.CURSE))
        TCC_API.ReloadCurses()
    end
end

function item:OnEff()
    local room = CURCOL.GAME:GetRoom()
    for i = 1, room:GetGridSize() do
        local entity = room:GetGridEntity(i)
        
        if entity and item.GRID_LIST[entity.Desc.Type] then
            entity:Destroy(true)
        end
    end
end

function item:OnFloor()
    if hasLoaded then
        item.OnCurse()
    end
end


--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable()
    CURCOL:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, item.OnDamage, EntityType.ENTITY_PLAYER)
    CURCOL:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL,  item.OnFloor)
    CURCOL:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT,  item.OnEff, 340)
    CURCOL:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT,  item.OnEff, 370)
    CURCOL:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function() hasLoaded = false end)
    
    hasLoaded = true
end

function item:Disable()
    CURCOL:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, item.OnDamage, EntityType.ENTITY_PLAYER)
    CURCOL:RemoveCallback(ModCallbacks.MC_POST_NEW_LEVEL,  item.OnFloor)
    CURCOL:RemoveCallback(ModCallbacks.MC_POST_PICKUP_INIT,  item.OnEff, 340)
    CURCOL:RemoveCallback(ModCallbacks.MC_POST_PICKUP_INIT,  item.OnEff, 370)
    CURCOL:RemoveCallback(ModCallbacks.MC_PRE_GAME_EXIT, function() hasLoaded = false end)
end

TCC_API:AddTCCCallback("TCC_EXIT_QUEUE", item.OnCurse, item.ID)
TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)

return item