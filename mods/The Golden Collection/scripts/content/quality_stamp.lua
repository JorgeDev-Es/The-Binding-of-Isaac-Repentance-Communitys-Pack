--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Quality stamp"),

    OPTIONS = {
        [1] = 10, -- Heart
        [2] = 20, -- Coin
        [3] = 30, -- Key
        [4] = 40, -- Bomb
        [5] = 69, -- Baggy
        [6] = 70, -- Pill
        [7] = 90, -- Battery
        [8] = 300, -- Card
        [10] = GOLCG.FICHES.VARIANT, -- Cursed coins (is ignored for rerolls)
        [11] = 42, -- Poops
    },

    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_SHOP,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Quality Stamp", DESC = "!!! HAS MAX RANGE !!!#Rerolls items / pickups for a price#May instead destroy them" },
        { LANG = "ru",    NAME = "Знак качества", DESC = "!!! Имеет максимальную дальность !!!#Меняет артефакты / пикапы по цене#Вместо этого может уничтожить их" },
        { LANG = "spa",   NAME = "Sello de calidad", DESC = "Rerollea objetos/recolectables a otros marcados con un precio#{{Warning}} Es posible que los destruya" },
        { LANG = "zh_cn", NAME = "质检印章", DESC = "重随角色附近的道具、饰品或基础掉落并将其变成商品#若已经是商品重随将再次涨价#价格涨到99分钱时将无法再重随#饰品有50%的概率重随成其金饰品的版本#{{Warning}} 物品有20%的概率消失" },
        { LANG = "ko_kr", NAME = "품질 도장", DESC = "#!!! 가격이 98코인 이하의 아이템에만 적용#현재 방의 모든 아이템과 픽업 아이템을 판매 아이템으로 바꿉니다.#이미 판매 중인 아이템의 경우 아이템의 가격을 1.5배로 증가시킵니다.#!!! 20% 확률로 아이템이 사라집니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Rerolls collectibles, pickups and trinkets into other items with a price."},
            {str = "If the item already had a price then the price is increased *1.5 on reroll."},
            {str = "Items can't be rerolled if the price is 99."},
            {str = "Trinkets have a 50% chance to be turned gold instead of rerolled."},
            {str = "Any item has a 20% chance to be destroyed instead of rerolled."},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function IsWhitelisted(dungle)
    for index, items in ipairs(item.OPTIONS) do
        if items == dungle then return true end
    end
    return false
end

function item:OnUse(_, RNG, player, _, _, _)
    local hasChangedItems = false
    local hasDestroyed = false
    local shouldDestroy = false

    local room = GOLCG.GAME:GetRoom()
    if RNG:RandomInt(100)+1 <= 20 then shouldDestroy = true end

    for _, entity in pairs(Isaac.FindInRadius(player.Position, 80, EntityPartition.PICKUP)) do
        entity = entity:ToPickup()
        if entity and (not entity.Price or entity.Price < 99) then
            local price = nil
            local shopId = -1
            local newItem = nil
            local pos = entity.Position --room:GetGridPosition(room:GetGridIndex(entity.Position)) -- Center pos in tile
            
            if entity.Variant == PickupVariant.PICKUP_TRINKET then -- Trinket 50/50 upgrade
                if shouldDestroy then goto failure end

                local addGold = ((RNG:RandomInt(10)+1 > 5 and entity.SubType < 32768) and true or false)
                newItem = GOLCG.SeedSpawn(entity.Type, entity.Variant or 0, (addGold and entity.SubType + 32768 or 0), pos, Vector(0,0), nil):ToPickup()
                price = 5
            elseif entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and entity.SubType ~= 0 then -- handle collectible
                if shouldDestroy then goto failure end

                newItem = GOLCG.SeedSpawn(entity.Type, entity.Variant or 0, 0, pos, Vector(0,0), nil):ToPickup()
                price = 8
            elseif IsWhitelisted(entity.Variant) then -- Else if allowed type (pickups)
                if shouldDestroy then goto failure end
                newItem = GOLCG.SeedSpawn(
                    entity.Type, 
                    item.OPTIONS[RNG:RandomInt((#item.OPTIONS-((player.Variant == PlayerType.PLAYER_XXX_B) and 1 or 2)))+1], -- Don't select poops if player isn't T.Blue baby
                    0, pos, Vector(0,0), nil
                ):ToPickup()
                price = 3
            else -- Skip if not allowed type
                goto endoffunc
            end

            if entity:IsShopItem() then -- Overwrite new price if was already a shop item
                price = entity.Price*1.5
                shopId = entity.ShopItemId
            end

            if not shopId then shopId = newItem.InitSeed end

            entity:Remove()
            newItem:PlayDropSound()

            newItem.Price = GOLCG:getPrice(
                price,
                newItem.Variant~=100, 
                player:HasCollectible(CollectibleType.COLLECTIBLE_POUND_OF_FLESH),
                player:GetCollectibleNum(CollectibleType.COLLECTIBLE_STEAM_SALE)
            )
            newItem.ShopItemId = shopId
            newItem.AutoUpdatePrice = false
            hasChangedItems = true

            GOLCG.GAME:SpawnParticles(entity.Position, EffectVariant.GOLD_PARTICLE, 5, 1)

            newItem:Update()

            goto endoffunc -- Skip failure logic

            ::failure:: -- Only run on failure

            hasDestroyed = true
            GOLCG.GAME:SpawnParticles(entity.Position, EffectVariant.WOOD_PARTICLE, 2, 1)
            GOLCG.GAME:SpawnParticles(entity.Position, EffectVariant.ROCK_PARTICLE, 3, 1)
            GOLCG.GAME:SpawnParticles(entity.Position, EffectVariant.CRACKED_ORB_POOF, 1, 0)
            entity:Remove()

            ::endoffunc::
        end
    end

    if hasDestroyed then
        GOLCG.GAME:SpawnParticles(player.Position, EffectVariant.HALLOWED_GROUND, 1, 0)
        player:AnimateSad()
        return false
    elseif hasChangedItems then -- BISHOP_SHIELD
        GOLCG.GAME:SpawnParticles(player.Position, EffectVariant.HALLOWED_GROUND, 1, 0)
        player:AnimateHappy()
        return true
    end

    return {
        ["Discharge"] = false,
        ["Remove"] = false,
        ["ShowAnim"] = false
    }
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
GOLCG:AddCallback(ModCallbacks.MC_USE_ITEM, item.OnUse, item.ID)

return item