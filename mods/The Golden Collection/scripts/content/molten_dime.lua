--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local item = {
    ID = Isaac.GetItemIdByName("Molten dime"),
    WHITELIST = {
        [10] = EffectVariant.BLOOD_PARTICLE, -- Heart
        [20] = EffectVariant.COIN_PARTICLE, -- Coin
        [30] = EffectVariant.SCYTHE_BREAK, -- Key
        [40] = EffectVariant.DUST_CLOUD, -- Bomb
        [42] = EffectVariant.POOP_PARTICLE, -- Poops
        [69] = EffectVariant.DUST_CLOUD, -- Baggy
        [70] = EffectVariant.DUST_CLOUD, -- Pill
        [90] = EffectVariant.DUST_CLOUD, -- Battery
        [100] = EffectVariant.ROCK_PARTICLE, -- Collectible
        [300] = EffectVariant.DUST_CLOUD, -- Card
        [350] = EffectVariant.DUST_CLOUD -- Trinket
    },
    CHESTS =  { 50, 51, 52, 53, 54, 55, 56, 57, 58, 60, 360 },
    CHANCES = { 50, 20, 20, 5,  20, 1,  2,  3,  4,  20, 30  },
    LIMIT = 50, -- Added to prevent the game from crashing when there are too many items.

    TYPE = 100,
    POOLS = {
        ItemPoolType.POOL_TREASURE,
        ItemPoolType.POOL_SHOP,
        ItemPoolType.POOL_BEGGAR,
        ItemPoolType.POOL_GREED_TREASUREL,
        ItemPoolType.POOL_GREED_SHOP,
    },
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Molten Dime", DESC = "50% chance to spawn similar drops for all items, consumables and chests#50% chance to remove all items and pickups and damage the player" },
        { LANG = "ru",    NAME = "Расплавленный Дайм", DESC = "50% шанс удвоить все артефакты, подбираемые предметы и сундуки#50% шанс убрать все артефакты, подбираемые предметы и нанести урон игроку" },
        { LANG = "spa",   NAME = "Moneda de 10 centavos fundida", DESC = "50% de posibilidad de generar recolectables y objetos similares en la sala#{{Warning}} 50% de posibilidades de desaparecer todo y herir al jugador" },
        { LANG = "zh_cn", NAME = "熔化的铸币", DESC = "50%的概率复制房间内的物品，随机生成对应类型的物品#50%的概率清除房间内所有物品并对角色造成伤害" },
        { LANG = "ko_kr", NAME = "녹아내리는 다임", DESC = "50% 의 확률로 방 안의 모든 아이템과 픽업 아이템을 다른 종류로 복사합니다.#복사 실패 시 아이템을 모두 없애고 하트 반칸의 피해를 받습니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Has a 50% chance to duplicate everything in the room just like crooked penny. However unlike crooked penny these new pickups/collectibles wont have the same subtype. Meaning that a pickup would spawn another random pickup and a collectible will spawn another random collectibe."},
            {str = "The other 50% chance destroys all items in the room and makes the player take damage instead of duplicating."}
        }
    }
}

local lastExecution = 0
local cachedRemovedPickups = {}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
local function getRandomChest()
    local totalWeight = 0
    for _, cur in pairs(item.CHANCES) do
        totalWeight = totalWeight + cur
    end
        
    local rand = math.random() * totalWeight
    local choice = nil
        
    for i, cur in pairs(item.CHANCES) do
        if rand < cur then
            choice = item.CHESTS[i]
            break
        else
            rand = rand - cur
        end
    end

    return choice
end

local function hasChest(val)
    for index, value in ipairs(item.CHESTS) do
        if value == val then return true end
    end

    return false
end

function item:OnUse(_, RNG, player, _, _, _)
    local curFrame = GOLCG.GAME:GetFrameCount()
    if curFrame ~= lastExecution then
        lastExecution = curFrame
        cachedRemovedPickups = {}
    end

    local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)

    if RNG:RandomInt(10) > 4 then
        local room = GOLCG.GAME:GetRoom()
        if not pickups then
            -- Get random pickup
            GOLCG.SeedSpawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
        else
            -- Dupe items with random alternate
            for _, pickup in pairs(pickups) do
                if _ > item.LIMIT then break end

                if item.WHITELIST[pickup.Variant] and pickup:Exists() then -- Collectible

                    if pickup.Variant == 100 and pickup.SubType == CollectibleType.COLLECTIBLE_NULL then -- Empty pedestal
                        goto skipspawn
                    end

                    GOLCG.SeedSpawn(pickup.Type, pickup.Variant, 0, room:FindFreePickupSpawnPosition(pickup.Position, 0, true), Vector(0, 0), nil)

                    ::skipspawn::
                elseif hasChest(pickup.Variant) then -- Chests
                    GOLCG.SeedSpawn(pickup.Type, getRandomChest(), 0, room:FindFreePickupSpawnPosition(pickup.Position, 0, true), Vector(0, 0), nil)
                end
            end
        end

        if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then 
            -- player:TriggerBookOfVirtues(CollectibleType.COLLECTIBLE_CROOKED_PENNY)
            player:AddWisp(CollectibleType.COLLECTIBLE_CROOKED_PENNY, player.Position) 
        end

        GOLCG.SFX:Play(SoundEffect.SOUND_BEAST_LAVABALL_RISE, 3, 0, false, 0.75)
    else
        for _, pickup in pairs(pickups) do
            if _ > item.LIMIT then break end
            local delete = false
            if item.WHITELIST[pickup.Variant] then
                local effect = item.WHITELIST[pickup.Variant]
                for i = 1, 4 do
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, effect, 0, pickup.Position, RandomVector() * ((math.random() * 2) + 1), nil)
                end
                delete = true
            elseif hasChest(pickup.Variant) then
                for i = 1, 4 do   
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WOOD_PARTICLE, 0, pickup.Position, RandomVector() * ((math.random() * 2) + 1), nil)
                end
                delete = true
            end

            if delete then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FIRE_JET, 0, pickup.Position, Vector(0,0), nil) -- HOT_BOMB_FIRE

                for i = 1, 4 do   
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.EMBER_PARTICLE, 0, pickup.Position, RandomVector() * ((math.random() * 2) + 1), nil)
                end

                pickup:Remove()
                cachedRemovedPickups[pickup.InitSeed] = true
            end
        end

        if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then 
            -- player:TriggerBookOfVirtues(CollectibleType.COLLECTIBLE_RED_CANDLE) 
            player:AddWisp(CollectibleType.COLLECTIBLE_RED_CANDLE, player.Position)
        end

        GOLCG.SFX:Play(SoundEffect.SOUND_WAR_LAVA_SPLASH, 1.5, 0)
        GOLCG.SFX:Play(SoundEffect.SOUND_BEAST_LAVA_BALL_SPLASH, 1.5, 0)
        
        player:TakeDamage(1, DamageFlag.DAMAGE_FIRE, EntityRef(player), 0)
    end

    return {
        ["Discharge"] = true,
        ["Remove"] = false,
        ["ShowAnim"] = true
    }
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
GOLCG:AddCallback(ModCallbacks.MC_USE_ITEM, item.OnUse, item.ID)

return item