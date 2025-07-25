--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local trinket = { 
    ID = Isaac.GetTrinketIdByName("Red penny"),

    VALUES = {
        [CoinSubType.COIN_NICKEL] = 5,
        [CoinSubType.COIN_DIME] = 15,
        [CoinSubType.COIN_DOUBLEPACK] = 2,
    },

    KEY="REPE",
    TYPE = 350,
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Red Penny", DESC = 'Chance to drop cracked keys when collecting coins#Chance to trigger "Soul of cain" when collecting coins' },
        { LANG = "ru",    NAME = "Красный Пенни", DESC = 'Шанс выпадения треснувшего ключа при сборе монет#Шанс активировать «Душу Каина» при сборе монет.' },
        { LANG = "spa",   NAME = "Centavo rojo", DESC = "Posibilidad de generar {{Collectible580}} LLaves rotas al tomar monedas# Posibilidad de activar el efecto de {{Rune}} El alma de Caín al tomar monedas" },
        { LANG = "zh_cn", NAME = "红硬币", DESC = "捡起硬币时有7%的概率触发“该隐的魂石”效果#捡起硬币时有3%的概率掉落一个红钥匙碎片" },
        { LANG = "ko_kr", NAME = "붉은 페니", DESC = '동전 획득 시 3% 확률로 {{Card78}}깨진 열쇠를 하나 드랍합니다.#동전 획득 시 7% 확률로 {{Card83}}Soul of Cain 효과를 발동합니다.' },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = 'Has a 7% chance to trigger the "Soul of cain" effect when picking up a coin.'},
            {str = 'Has a 3% chance to drop a cracked key when picking up a coin.'},
            {str = 'These chances are increased by the trinket multiplier and coin values.'},
        }
    },

    TRIGGER_CHANCE = 7,
    SPAWN_CHANCE = 3,
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--
function trinket:OnPickup(pickup, collider, _)
    if collider.Type == EntityType.ENTITY_PLAYER
    and pickup.SubType ~= CoinSubType.COIN_STICKYNICKEL
    and TCC_API:Has(trinket.KEY, collider:ToPlayer()) > 0
    and not pickup:IsShopItem() then
        local player = collider:ToPlayer()
        local RNG = player:GetTrinketRNG(trinket.ID)
        local multiplier = TCC_API:Has(trinket.KEY, collider:ToPlayer())

        -- player:UseActiveItem(CollectibleType.COLLECTIBLE_RED_KEY, false, false, true, false)
        for i=1, multiplier do
            if RNG:RandomInt(100)+1 <= (1-(0.94^(trinket.VALUES[pickup.SubType] or 1)))*100 then
                -- local level = GOLCG.GAME:GetLevel()
                -- local room = GOLCG.GAME:GetRoom()
                -- local roomIndex = level:GetCurrentRoomIndex()
                
                -- for key, value in pairs(trinket.DOORS[room:GetRoomShape()]) do
                --     Isaac.DebugString("key: " .. key .. ', VALUE: ' .. value)
                --     local success = level:MakeRedRoomDoor(roomIndex, value)
                --     if success then break end
                -- end
                
                player:UseCard(Card.CARD_SOUL_CAIN, 259)
                GOLCG.SFX:Stop(SoundEffect.SOUND_GOLDENKEY)
            end

            RNG:Next()

            if RNG:RandomInt(100)+1 <= (1-(0.96^(trinket.VALUES[pickup.SubType] or 1)))*100 then
                GOLCG.SeedSpawn(
                    EntityType.ENTITY_PICKUP, 
                    PickupVariant.PICKUP_TAROTCARD, 
                    Card.CARD_CRACKED_KEY, 
                    GOLCG.GAME:GetRoom():FindFreePickupSpawnPosition(pickup.Position, 0, true), 
                    Vector(0,0), 
                    player
                )
            end

            RNG:Next()
        end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function trinket:Enable()
    GOLCG:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, trinket.OnPickup, PickupVariant.PICKUP_COIN)
end

function trinket:Disable() 
    GOLCG:RemoveCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, trinket.OnPickup, PickupVariant.PICKUP_COIN)
end

TCC_API:AddTCCInvManager(trinket.ID, trinket.TYPE, trinket.KEY, trinket.Enable, trinket.Disable)

return trinket