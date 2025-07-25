--##############################################################################--
--#################################### DATA ####################################--
--##############################################################################--
local trinket = { 
    ID = Isaac.GetTrinketIdByName("Cracked penny"),

    VALUES = {
        [CoinSubType.COIN_NICKEL] = 5,
        [CoinSubType.COIN_DIME] = 15,
        [CoinSubType.COIN_DOUBLEPACK] = 2,
    },
    REWARDS = {
        [1] =  nil,                                                                                                           -- Swallowed Penny
        [2] =  nil,                                                                                                           -- Butt Penny
        [3] =  nil,                                                                                                           -- Rotten Penny
        [4] =  {                                                                                           ["Chance"] = 6 },    -- Charged penny     (value/6)
        [5] =  { ["Variant"] = PickupVariant.PICKUP_HEART,     ["SubType"] = HeartSubType.HEART_HALF,      ["Chance"] = 0.75 }, -- Bloody Penny
        [6] =  { ["Variant"] = PickupVariant.PICKUP_BOMB,                                                  ["Chance"] = 0.75 }, -- Burnt Penny
        [7] =  { ["Variant"] = PickupVariant.PICKUP_COIN,      ["SubType"] = CoinSubType.COIN_PENNY,       ["Chance"] = 0.50 }, -- Counterfeit Penny
        [8] =  { ["Variant"] = PickupVariant.PICKUP_KEY,       ["SubType"] = KeySubType.KEY_NORMAL,        ["Chance"] = 0.75 }, -- Flat Penny
        [9] =  nil, --{ ["Variant"] = PickupVariant.PICKUP_TAROTCARD, ["SubType"] = Card.CARD_CRACKED_KEY,        ["Chance"] = 12  }, -- Red Penny
        [10] = { ["Variant"] = PickupVariant.PICKUP_HEART,     ["SubType"] = HeartSubType.HEART_HALF_SOUL, ["Chance"] = 0.8334 }, -- Blessed penny
        [11] = nil,                                                                                                           -- Cursed Penny
    },

    KEY="CRPE",
    TYPE = 350,
    EID_DESCRIPTIONS = {
        { LANG = "en_us", NAME = "Cracked Penny", DESC = "Has all penny trinket effects" },
        { LANG = "ru",    NAME = "Треснувшая монета", DESC = "Имеет все эффекты пенни-брелков" },
        { LANG = "spa",   NAME = "Centavo roto", DESC = "Posee todos los efectos de los trinkets de monedas" },
        { LANG = "zh_cn", NAME = "硬币碎片", DESC = "随机触发各种硬币饰品的效果" },
        { LANG = "ko_kr", NAME = "금이 간 페니", DESC = "동전 획득 시 랜덤 Penny류 장신구의 효과를 발동합니다.#{{Trinket1}} 피격 시 40%의 확률로 {{Coin}}동전을 1개({{Player14}}/{{Player33}}: 0~1개) 드랍합니다." },
    },
    ENC_DESCRIPTION = {
        { -- Effect
            {str = "Effect", fsize = 2, clr = 3, halign = 0},
            {str = "Triggers a random penny trinket effect when picking up a penny. and has a 2/5 chance of triggering the swallowed penny effect when taking damage."},
            {str = "The following multiplier effects exist: "},
            {str = "Butt penny farts are larger based on the multiplier"},
            {str = "Cursed penny may teleport you to the I AM ERROR room when it is multiplied"},
            {str = "The amount of items dropped, charges gained or flies spawned may increase based on the multiplier"},
            {str = "The chance of red penny's effects triggering increases based on the multiplier"},
        },
        { -- Synergies
            {str = "Synergies", fsize = 2, clr = 3, halign = 0},
            {str = 'While holding "Black candle" the cursed penny effect will not occur'},
        }
    }
}

--##############################################################################--
--################################# ITEM LOGIC #################################--
--##############################################################################--

-- CURRENTLY MISSING EFFECTS --
-- Counterfeit Penny should have the chance for Keeper to gain the full value of a coin while healing.
-- Charged Penny should not charge beyond max charges
-- Butt Penny should grant a higher chance for poops to drop coins. There's no callback for poops dying so ¯\_(ツ)_/¯

function trinket:OnPickup(pickup, collider, _)
    if collider.Type == EntityType.ENTITY_PLAYER
    and pickup.SubType ~= CoinSubType.COIN_STICKYNICKEL
    and not pickup:IsShopItem() then
        local player = collider:ToPlayer()
        local RNG = player:GetTrinketRNG(trinket.ID)
        local mul = TCC_API:Has(trinket.KEY, player)
        
        for i=1, mul do
            RNG:Next()
            local activeEffect = (RNG:RandomInt((player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) and 10 or 11))+1)
            local currentEffect = trinket.REWARDS[activeEffect]

            if activeEffect == 2 then -- If true then spawn fart (Butt penny only)
                local modifier = 0.50 + (mul/2)
                GOLCG.GAME:Fart(player.Position, 85*modifier, player, 1*modifier)
                goto endpoint
            end

            if activeEffect == 10 then -- If true then use red penny logic (Red penny only)
                if RNG:RandomInt(100)+1 <= (1-(0.94^(trinket.VALUES[pickup.SubType] or 1)))*100 then
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

                goto endpoint
            end

            if activeEffect == 11 then -- If true teleport (Cursed penny only)
                if not player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then -- Edgecase of having the curse in the same room you picked up black candle
                    GOLCG.GAME:MoveToRandomRoom((mul > 1 and true or false), player:GetTrinketRNG(trinket.ID):GetSeed(), player)
                    RNG:Next()
                end
                goto endpoint
            end

            if activeEffect == 3 then -- If true spawn blue fly (Rotten penny only)
                player:AddBlueFlies(mul, player.Position, player)
                goto endpoint
            end

            if activeEffect == 4 then -- If true then add charge (Charged penny only)
                if RNG:RandomInt(100)+1 <= ((trinket.VALUES[pickup.SubType] or 1)/currentEffect.Chance)*100 then 
                    player:SetActiveCharge(player:GetActiveCharge()+1) -- Should add max charges logic
                end
                goto endpoint
            end

            if currentEffect and currentEffect.Variant then -- If true spawn pickup logic
                -- 1-chance^value
                if RNG:RandomInt(100)+1 <= (1-(currentEffect.Chance^(trinket.VALUES[pickup.SubType] or 1)))*100 then
                    GOLCG.SeedSpawn(
                        EntityType.ENTITY_PICKUP,
                        currentEffect.Variant,
                        (currentEffect.SubType or 0),
                        GOLCG.GAME:GetRoom():FindFreePickupSpawnPosition(pickup.Position, 0, true),
                        Vector(0, 0),
                        nil
                    )
                end
            end

            ::endpoint::
        end
    end
end

function trinket:OnDamage(entity, _, _, _, _) -- Swallowed Penny logic
    local player = entity:ToPlayer()
    local RNG = player:GetTrinketRNG(trinket.ID)
    
    for i=1, TCC_API:Has(trinket.KEY, player) do
        local isKeeper = (player.SubType == PlayerType.PLAYER_KEEPER or player.SubType == PlayerType.PLAYER_KEEPER_B)
        if not isKeeper or RNG:RandomInt(2)+1 > 1 then
            GOLCG.SeedSpawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, GOLCG.GAME:GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
        end
    end
end

--##############################################################################--
--############################ CALLBACKS AND EXPORT ############################--
--##############################################################################--
function trinket:Enable()
    GOLCG:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, trinket.OnPickup, PickupVariant.PICKUP_COIN)
    GOLCG:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,      trinket.OnDamage, EntityType.ENTITY_PLAYER )
end

function trinket:Disable()
    GOLCG:RemoveCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, trinket.OnPickup, PickupVariant.PICKUP_COIN)
    GOLCG:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,      trinket.OnDamage, EntityType.ENTITY_PLAYER )
end

TCC_API:AddTCCInvManager(trinket.ID, trinket.TYPE, trinket.KEY, trinket.Enable, trinket.Disable)

return trinket

--###########################################################################--
--### Old code that changed the effect every room instead of every pickup ###--
--###########################################################################--

-- function trinket:OnEnterNewRoom()
--     local range = 11
--     local numPlayers = Game():GetNumPlayers()

--     for i=1,numPlayers do
--         local player = Game():GetPlayer(tostring((i-1)))
--         if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then range = 10 end -- Range gets set to a max of 10 so that cursed penny is not included
--     end

--     activeEffect = (rng:RandomInt(range)+1) 
-- end

-- trinket:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,        trinket.OnEnterNewRoom)

--########################################################################--
--### AddTrinketEffect is sadly bugged i think. Insta crashes the game ###--
--########################################################################--

--[[
local pennyEffects = {
    [1] = TrinketType.TRINKET_SWALLOWED_PENNY,
    [2] = TrinketType.TRINKET_BUTT_PENNY,
    [3] = TrinketType.TRINKET_BLOODY_PENNY,
    [4] = TrinketType.TRINKET_BURNT_PENNY,
    [5] = TrinketType.TRINKET_FLAT_PENNY,
    [6] = TrinketType.TRINKET_COUNTERFEIT_PENNY,
    [7] = TrinketType.TRINKET_ROTTEN_PENNY,
    [8] = TrinketType.TRINKET_BLESSED_PENNY,
    [9] = TrinketType.TRINKET_CHARGED_PENNY, 
    [10] = TrinketType.TRINKET_CURSED_PENNY
}

local numPlayers = Game():GetNumPlayers()
for i=1,numPlayers do
    local player = Game():GetPlayer(tostring((i-1)))
    if player:HasTrinket(trinket.CRACKED_PENNY) then
        for i=1,player:GetTrinketMultiplier(trinket.CRACKED_PENNY) do
            player:GetEffects():AddTrinketEffect(pennyEffects[player:GetTrinketRNG(trinket.CRACKED_PENNY):RandomInt(#pennyEffects)+1])
        end
    end
end
--]]