--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Stolen placard"),

    GREED_TIMEOUT = 500,
    GREED_SPAWN_CHANCE = 50,
    SPAWN_CHANCE = 7,

    OPTIONS = {
        [1] = 10, -- Heart
        [2] = 30, -- Key
        [3] = 40, -- Bomb
        [4] = 69, -- Baggy
        [5] = 70, -- Pill
        [6] = 90, -- Battery
        [7] = 300, -- Card
        [8] = 350, -- Trinket
        [9] = 42 -- Poops
    },

    KEY="STPL",
    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_SHOP
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Stolen Placard", DESC = "May spawn shop items/pickups when clearing a room" },
        { LANG = "ru",    NAME = "Украденный плакат", DESC = "Может создавать магазины при зачистке комнаты" },
        { LANG = "spa",   NAME = "Cartel robado", DESC = "Hay una posibilidad de generar objetos y recolectables con precio al limpiar la habitación#Sólo se puede comprar uno" },
        { LANG = "zh_cn", NAME = "失窃的招牌", DESC = "清理完房间时有9%的概率原地生成4个商品#只能买一个" },
        { LANG = "ko_kr", NAME = "훔친 플래카드", DESC = "방 클리어 시 9%의 확률로 판매 아이템을 4개 소환합니다.#판매 아이템은 하나만 구매할 수 있으며 하나 구매 시 나머지는 사라집니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "When clearing a room has a 9% chance to spawn 4 shop items."},
            {str = "When playing as tainted ??? these shops may contain poops"},
            {str = "On greed these shops have a timeout to keep them from getting in the way"},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function GetPos(index, room, avoid)
    local center = room:GetCenterPos()
    local selection = center

    if index == 1 then
        selection = center + Vector(-50, -50)
    elseif index == 2 then
        selection = center + Vector(-50, 50)
    elseif index == 3 then
        selection = center + Vector(50, -50)
    else
        selection = center + Vector(50, 50)
    end

    local entity = room:GetGridEntityFromPos(selection)
        
    if entity and entity.Desc.Type == GridEntityType.GRID_PIT then
        entity:ToPit():MakeBridge(nil)
    end

    local pos = room:FindFreePickupSpawnPosition(selection, 0, true, false)

    for i=1, 10 do
        if pos.X ~= avoid.X and pos.Y ~= avoid.Y then break end
        pos = room:FindFreePickupSpawnPosition(pos, 30, true, false)
    end

    return pos
end

function item:OnRoomClear(RNG, SpawnPosition)
    if RNG:RandomInt(100)+1 <= item[GOLCG.GAME.Difficulty > 1 and "GREED_SPAWN_CHANCE" or "SPAWN_CHANCE"] then
        local hasCollectible = false
        local hasPoundOfFlesh = false
        local steamSaleMultiplier = 0
        local TainedXXX = false

        local numPlayers = GOLCG.GAME:GetNumPlayers()
        for i=1, numPlayers do
            local player = GOLCG.GAME:GetPlayer(tostring((i-1)))
            if player:HasCollectible(item.ID) then
                hasCollectible = true
            end

            if player:HasCollectible(CollectibleType.COLLECTIBLE_POUND_OF_FLESH) then
                hasPoundOfFlesh = true
            end

            if player:HasCollectible(CollectibleType.COLLECTIBLE_STEAM_SALE) then
                steamSaleMultiplier = steamSaleMultiplier + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_STEAM_SALE)
            end

            if player.Variant == PlayerType.PLAYER_XXX_B then
                TainedXXX = true
            end
        end

        if hasCollectible then
            local hasSpawnedCol = false
            local room = GOLCG.GAME:GetRoom()

            for i=1, 4 do
                local curRNG = RNG:RandomInt(10)
                local selection = ((curRNG > 8 or (i==4 and not hasSpawnedCol)) and PickupVariant.PICKUP_COLLECTIBLE or item.OPTIONS[RNG:RandomInt((#item.OPTIONS-(TainedXXX and 0 or 1)))+1])

                if selection == PickupVariant.PICKUP_COLLECTIBLE then hasSpawnedCol = true end

                local sub = 0

                local curitem = GOLCG.SeedSpawn(
                    EntityType.ENTITY_PICKUP,
                    selection,
                    0,
                    GetPos(i, room, SpawnPosition),
                    Vector(0,0),
                    nil
                ):ToPickup()
                
                curitem.Price = GOLCG:getPrice(
                    selection == PickupVariant.PICKUP_COLLECTIBLE and 20 or 8,
                    selection == PickupVariant.PICKUP_COLLECTIBLE and false or true,
                    hasPoundOfFlesh,
                    steamSaleMultiplier
                )

                curitem.ShopItemId = -1
                curitem.OptionsPickupIndex = 3320
                curitem.AutoUpdatePrice = false
                if GOLCG.GAME.Difficulty > 1 then curitem.Timeout = item.GREED_TIMEOUT end

                curitem.Wait = 50

                GOLCG.GAME:SpawnParticles(curitem.Position, EffectVariant.GOLD_PARTICLE, 5, 1)
                GOLCG.GAME:SpawnParticles(curitem.Position, EffectVariant.CRACKED_ORB_POOF, 1, 0)
            end
        end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function item:Enable() GOLCG:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, item.OnRoomClear) end
function item:Disable() GOLCG:RemoveCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, item.OnRoomClear) end

TCC_API:AddTCCInvManager(item.ID, item.TYPE, item.KEY, item.Enable, item.Disable)


return item