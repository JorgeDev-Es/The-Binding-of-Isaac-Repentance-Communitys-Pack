--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Silver lacquered chisel"),

    -- ### POOL NOTES ### --
    -- Minimum drops seems to be 3, max seems to be 13. But this could be wrong
    -- Cards, Runes, Soul stones, etc.. are never dropped

    -- The following rooms seem to have no guaranteed special drop
    -- Library,   Planetarium,  Arcade, 
    -- Challenge, Error,        Shops, 
    -- Boss,      Sacrifice,    Treasure,
    -- Isaacs,    Barren,       Dungeon,
    -- Miniboss,  Default,      Chest,
    -- Dice,      Black market, 

    MIN_DROPS = 3,
    EXTRA_DROPS = 10, -- Max is 13
    PICKUP_POOLS = {
        [RoomType.ROOM_NULL] = {
            { ["Var"] = PickupVariant.PICKUP_BOMB },
            { ["Var"] = PickupVariant.PICKUP_KEY },
            { ["Var"] = PickupVariant.PICKUP_COIN },
            { ["Var"] = PickupVariant.PICKUP_HEART },
        },
        [RoomType.ROOM_SECRET] = {
            { ["Sub"] = HeartSubType.HEART_BONE, ["Var"] = PickupVariant.PICKUP_HEART },
        },
        [RoomType.ROOM_SUPERSECRET] = {
            { ["Sub"] = HeartSubType.HEART_BONE, ["Var"] = PickupVariant.PICKUP_HEART },
        },
        [RoomType.ROOM_ULTRASECRET] = {
            { ["Sub"] = HeartSubType.HEART_ETERNAL, ["Var"] = PickupVariant.PICKUP_HEART },
        },
        [RoomType.ROOM_CURSE] = {
            { ["Sub"] = HeartSubType.HEART_ROTTEN, ["Var"] = PickupVariant.PICKUP_HEART },
        },
        [RoomType.ROOM_DEVIL] = {
            { ["Sub"] = HeartSubType.HEART_BLACK, ["Var"] = PickupVariant.PICKUP_HEART },
        },
        [RoomType.ROOM_ANGEL] = {
            { ["Sub"] = HeartSubType.HEART_ETERNAL, ["Var"] = PickupVariant.PICKUP_HEART },
        }
    },

    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_SHOP,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Silver Lacquered Chisel", DESC = "Turns collectibles into random pickups" },
        { LANG = "ru",    NAME = "Серебряное лакированное долото", DESC = "Превращает предметы коллекционирования в случайные подбираемые предметы" },
        { LANG = "spa",   NAME = "Cincel barnizado en plata", DESC = "Los objetos de la sala se convierten en recolectables aleatorios" },
        { LANG = "zh_cn", NAME = "银漆凿", DESC = "使用后将基座上的道具变成基础掉落" },
        { LANG = "ko_kr", NAME = "은을 바른 끌", DESC = "사용 시 현재 방의 아이템을 3~13개의 랜덤 픽업 아이템으로 분해합니다.#분해 규칙은 Tainted Cain의 규칙을 따릅니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Turn collectibles into random pickups (like tainted Cain)."},
            {str = "The minimum amount of drops is 3 and the maximum is 13."},
            {str = "Some types of rooms may guarantee a special drop just like with tainted Cain."}
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function SpawnLoot(pos, RNG, roomPool, defaultPool)
    for i = 1, (item.MIN_DROPS + (RNG:RandomInt(item.EXTRA_DROPS)+1)) do
        local curitem = i == 1 and roomPool[RNG:RandomInt(#roomPool)+1] or defaultPool[RNG:RandomInt(#defaultPool)+1]

        GOLCG.SeedSpawn(
            EntityType.ENTITY_PICKUP,
            curitem.Var or 0,
            curitem.Sub or 0,
            pos,
            RandomVector() * ((math.random() * 4) + 3.5),
            nil
        )
    end
end

function item:OnUse(_, RNG, player, _, _, _)
    local defaultPool = item.PICKUP_POOLS[0]
    local roomPool = item.PICKUP_POOLS[GOLCG.GAME:GetRoom():GetType()] or defaultPool
    local hasRemoved = false

    for _, entity in pairs(Isaac.FindByType(5, 100)) do
        entity = entity:ToPickup()

        if not entity:IsShopItem() and entity.SubType ~= CollectibleType.COLLECTIBLE_NULL then
            SpawnLoot(entity.Position, RNG, roomPool, defaultPool)

            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector(0,0), nil)
            entity:Remove()
            hasRemoved = true
        end
    end

    if not player:IsItemQueueEmpty() then
        local item = player.QueuedItem.Item

        if item:IsCollectible() then
            -- I can't seem to cancel the queued item in any way so this is the workaround
            player:FlushQueueItem()
            player:RemoveCollectible(item.ID)
            SpawnLoot(player.Position, RNG, roomPool, defaultPool)
            
            hasRemoved = true
        end
    end
    
    if hasRemoved then
        GOLCG.SFX:Play(SoundEffect.SOUND_WOOD_PLANK_BREAK, 3, 0)
        GOLCG.SFX:Play(SoundEffect.SOUND_ULTRA_GREED_PULL_SLOT, 2, 0)
        player:AnimateHappy()
    else
        player:AnimateSad()
    end

    -- if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
    --     player:AddWisp(CollectibleType.COLLECTIBLE_GOLDEN_RAZOR, Player.Position)
    -- end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
GOLCG:AddCallback(ModCallbacks.MC_USE_ITEM, item.OnUse, item.ID)

return item