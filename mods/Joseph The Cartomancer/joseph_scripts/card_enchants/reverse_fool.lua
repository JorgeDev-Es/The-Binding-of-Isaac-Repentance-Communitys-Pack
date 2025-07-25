local ReverseFool = {}

local utility = JosephMod.utility
local enums = JosephMod.enums
local fool = Card.CARD_REVERSE_FOOL


---@param player EntityPlayer
---@param card Card
function ReverseFool:initReverseFool(player, card)

end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, ReverseFool.initReverseFool, fool)
JosephMod:AddCallback(enums.Callbacks.JOSEPH_GAME_START_ENCHANT_REFRESH, ReverseFool.initReverseFool, fool)

---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseFool:removeReverseFool(player, card, slot)
end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, ReverseFool.removeReverseFool, fool)


function ReverseFool:OnHit(entity, amount, flags, source, countDown)

    local player = entity:ToPlayer()
    --local fakeDamageFlags = DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_FAKE
    --if flags & fakeDamageFlags > 0 then return end

    if not utility:HasEnchantment(player, fool) then return end
    local rng = player:GetCardRNG(fool)

    local maxPickupsToDrop = rng:RandomInt(4) + 2
    --print("To drop: " .. maxPickupsToDrop)

    local coinCount = player:GetNumCoins()
    local bombCount = player:GetNumBombs()
    local keyCount = player:GetNumKeys()

    local soulHearts = player:GetSoulHearts()
    local blackHearts = player:GetBlackHearts()
    local boneHearts = player:GetBoneHearts()
    local redHearts = player:GetHearts()
    local eternalHearts = player:GetEternalHearts()
    local goldenHearts = player:GetGoldenHearts()
    local rottenHearts = player:GetRottenHearts()

    local hasGoldenKey = player:HasGoldenKey()
    local hasGoldenBomb = player:HasGoldenBomb()

    local pickupsDropped = 0

    local function spawnPickup(pickupType, pickupVariant, pickupSubType)
        Isaac.Spawn(pickupType, pickupVariant, pickupSubType, Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, player)
        pickupsDropped = pickupsDropped + 1
    end


    for i=0, rng:RandomInt(1)+1, 1 do
        if coinCount >= 100 then
            player:AddCoins(-100)
            spawnPickup(5, 100, CollectibleType.COLLECTIBLE_DOLLAR)
            coinCount = coinCount - 100

        elseif coinCount >= 25 then
            player:AddCoins(-25)
            spawnPickup(5, 100, CollectibleType.COLLECTIBLE_QUARTER)
            coinCount = coinCount - 25
            
        elseif bombCount >= 99 then
            player:AddBombs(-99)
            spawnPickup(5, 100, CollectibleType.COLLECTIBLE_PYRO)
            bombCount = bombCount - 99

        elseif bombCount >= 10 then
            player:AddBombs(-10)
            spawnPickup(5, 100, CollectibleType.COLLECTIBLE_BOOM)
            bombCount = bombCount - 10

        elseif keyCount >= 99 then
            player:AddKeys(-99)
            spawnPickup(5, 100, CollectibleType.COLLECTIBLE_SKELETON_KEY)
            keyCount = keyCount - 99

        end
    end

    local attempts = 0
    while pickupsDropped < maxPickupsToDrop and attempts < maxPickupsToDrop do

        if  coinCount >= 10 then
            player:AddCoins(-10)
            spawnPickup(5, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DIME)
            coinCount = coinCount - 5

        elseif coinCount >= 5 then
            player:AddCoins(-5)
            spawnPickup(5, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL)
            coinCount = coinCount - 5

        elseif coinCount >= 1 then
            player:AddCoins(-1)
            spawnPickup(5, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY)
            coinCount = coinCount - 1

        end

        if hasGoldenKey then
            player:RemoveGoldenKey()
            hasGoldenKey = false
            spawnPickup(5, PickupVariant.PICKUP_KEY, KeySubType.KEY_GOLDEN)

        elseif keyCount >= 2 then
            player:AddKeys(-2)
            spawnPickup(5, PickupVariant.PICKUP_KEY, KeySubType.KEY_DOUBLEPACK)
            keyCount = keyCount - 2

        elseif keyCount >= 1 then
            player:AddKeys(-1)
            spawnPickup(5, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL)
            keyCount = keyCount - 1
        end

        if hasGoldenBomb then
            player:RemoveGoldenBomb()
            hasGoldenBomb = false
            spawnPickup(5, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GOLDEN)

        elseif bombCount >= 2 then
            player:AddBombs(-2)
            spawnPickup(5, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_DOUBLEPACK)
            bombCount = bombCount - 2

        elseif bombCount >= 1 then
            player:AddBombs(-1)
            spawnPickup(5, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL)
            bombCount = bombCount - 1
        end
        attempts = attempts + 1
    end

    --print("Dropped: " .. pickupsDropped)

end
JosephMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ReverseFool.OnHit, EntityType.ENTITY_PLAYER)