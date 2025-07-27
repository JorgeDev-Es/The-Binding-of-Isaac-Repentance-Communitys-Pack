
local mod = FiendFolio
local game = Game()

--Functions stolen from retribution and slightly modified (thank you xal :)
function mod.GetSafeCoinValueFromSubType(subtype)
	if subtype == CoinSubType.COIN_DIME then
		return 10
	elseif subtype == CoinSubType.COIN_NICKEL or subtype == CoinSubType.COIN_STICKYNICKEL then
		return 5
	elseif subtype == CoinSubType.COIN_DOUBLEPACK then
		return 2
	else
		return 1
	end
end
function mod.GetSafeCoinValueFromSubTypeSpoils(subtype)
    local assumedSub = subtype % 64
	if assumedSub == 2 then
		return 1
    else
        return assumedSub
    end
end

local isCursedPenny = {
    [FiendFolio.PICKUP.COIN.CURSED] = true,
    [FiendFolio.PICKUP.COIN.GOLDENCURSED] = true,
}

local function pennyPickupBloody(pickup, player, value)
    if player:HasTrinket(TrinketType.TRINKET_BLOODY_PENNY) then
        local rng = player:GetTrinketRNG(TrinketType.TRINKET_BLOODY_PENNY)
        if rng:RandomFloat() < 1 - 0.75 ^ value then
            if isCursedPenny[pickup.SubType] then
                Isaac.Spawn(5, FiendFolio.PICKUP.VARIANT.THIRD_MORBID_HEART, 0, game:GetRoom():FindFreePickupSpawnPosition(pickup.Position, 40, false), Vector.Zero, nil)
            else
                Isaac.Spawn(5, 10, 2, game:GetRoom():FindFreePickupSpawnPosition(pickup.Position, 40, false), Vector.Zero, nil)
            end
        end
    end
end

local function pennyPickupBurnt(pickup, player, value)
    if player:HasTrinket(TrinketType.TRINKET_BURNT_PENNY) then
        local rng = player:GetTrinketRNG(TrinketType.TRINKET_BURNT_PENNY)
        if rng:RandomFloat() < 1 - 0.75 ^ value then
            if isCursedPenny[pickup.SubType] then
                Isaac.Spawn(5, 40, FiendFolio.PICKUP.BOMB.COPPER, game:GetRoom():FindFreePickupSpawnPosition(pickup.Position, 40, false), Vector.Zero, nil)
            else
                Isaac.Spawn(5, 40, 1, game:GetRoom():FindFreePickupSpawnPosition(pickup.Position, 40, false), Vector.Zero, nil)
            end
        end
    end
end

local function pennyPickupButt(pickup, player, value)
    if player:HasTrinket(TrinketType.TRINKET_BUTT_PENNY) then
        game:Fart(player.Position)
    end
end

local function pennyPickupCounterfeit(pickup, player, value)
    if player:HasTrinket(TrinketType.TRINKET_COUNTERFEIT_PENNY) then
        local rng = player:GetTrinketRNG(TrinketType.TRINKET_COUNTERFEIT_PENNY)
        if rng:RandomFloat() < 1 - 0.5 ^ value then
            player:AddCoins(1)
        end
    end
end

local function pennyPickupFlat(pickup, player, value)
    if player:HasTrinket(TrinketType.TRINKET_FLAT_PENNY) then
        local rng = player:GetTrinketRNG(TrinketType.TRINKET_FLAT_PENNY)
        if rng:RandomFloat() < 1 - 0.75 ^ value then
            if isCursedPenny[pickup.SubType] then
                Isaac.Spawn(5, 30, FiendFolio.PICKUP.KEY.SPICY_PERM, game:GetRoom():FindFreePickupSpawnPosition(pickup.Position, 40, false), Vector.Zero, nil)
            else
                Isaac.Spawn(5, 30, 1, game:GetRoom():FindFreePickupSpawnPosition(pickup.Position, 40, false), Vector.Zero, nil)
            end
        end
    end
end

local function pennyPickupRotten(pickup, player, value)
    if player:HasTrinket(TrinketType.TRINKET_ROTTEN_PENNY) then
        player:AddBlueFlies(1, player.Position, player)
    end
end

-- Repentance Coins
local function pennyPickupBlessed(pickup, player, value)
    if player:HasTrinket(TrinketType.TRINKET_BLESSED_PENNY) then
        local rng = player:GetTrinketRNG(TrinketType.TRINKET_BLESSED_PENNY)
        if rng:RandomFloat() < 1 - (5/6) ^ value then
            if isCursedPenny[pickup.SubType] then
                Isaac.Spawn(5, FiendFolio.PICKUP.VARIANT.HALF_IMMORAL_HEART, 0, game:GetRoom():FindFreePickupSpawnPosition(pickup.Position, 40, false), Vector.Zero, nil)
            else
                Isaac.Spawn(5, 10, 8, game:GetRoom():FindFreePickupSpawnPosition(pickup.Position, 40, false), Vector.Zero, nil)
            end
        end
    end
end

local function pennyPickupCharged(pickup, player, value)
    if player:HasTrinket(TrinketType.TRINKET_CHARGED_PENNY) then
        local rng = player:GetTrinketRNG(TrinketType.TRINKET_CHARGED_PENNY)
        if player:NeedsCharge() and rng:RandomFloat() < value / 6 then
            local charge = player:GetActiveCharge()
            player:SetActiveCharge(charge + 1)
        end
    end
end

local function pennyPickupCursed(pickup, player, value)
    if player:HasTrinket(TrinketType.TRINKET_CURSED_PENNY) then
        if not player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
            player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPORT, UseFlag.USE_NOANIM)
        end
    end
end

-- Retribution Coins
local function pennyPickupGrubby(pickup, player, value)
    if player:HasTrinket(Retribution.TRINKETS.GRUBBY_PENNY) then
        player:AddBlueSpider(player.Position)
    end
end
local function pennyPickupYen(pickup, player, value)
    if player:HasTrinket(Retribution.TRINKETS.YEN_PENNY) then
        local chance = 1 - (5/6) ^ value
        local rng = player:GetTrinketRNG(Retribution.TRINKETS.YEN_PENNY)
        if rng:RandomFloat() < chance then
            local minicapsule = Isaac.Spawn(5, Retribution.PICKUPS.MINICAPSULE, 0, game:GetRoom():FindFreePickupSpawnPosition(pickup.Position, 40, false), Vector.Zero, pickup)
            minicapsule:GetSprite():Play("Appear" .. minicapsule.SubType)
        end
    end
end
local function pennyPickupRainbow(pickup, player, value)
    local rng = player:GetTrinketRNG(Retribution.TRINKETS.RAINBOW_PENNY)
    for i = 1, player:GetTrinketMultiplier(Retribution.TRINKETS.RAINBOW_PENNY) do
        Retribution.RainbowPenny[rng:RandomInt(#Retribution.RainbowPenny) + 1](pickup, player, rng)
    end
end
-------------------------------
--Implementation code
local blacklistedSubtypes = {
    [CoinSubType.COIN_STICKYNICKEL] = true
}

function mod:triggerPennyPickup(player, pickup, value)
    if pickup.Variant == 20 and blacklistedSubtypes[pickup.SubType] then return end
    if not value then
        if pickup.Variant == 20 then --Default penny
            value = mod.GetSafeCoinValueFromSubType(pickup.SubType)
        elseif pickup.Variant == 1875 then --Spoils penny
            value = mod.GetSafeCoinValueFromSubTypeSpoils(pickup.SubType)
        --[[elseif pickup.Variant == 1876 then
            value = math.max(1, pickup.SubType)]]
        else
            value = 1
        end
    end
    --Fiend Folio penny trinkets
    mod:pennyPickupGMO(player, pickup, value)
    mod:pennyPickupMolten(player, pickup, value)
    mod:pennyPickupFuzzy(player, pickup, value)
    mod:pennyPickupSharp(player, pickup, value)
    mod:pennyPickupEgg(player, pickup, value)
    --Golem penny rocks
    mod:pennyPickupOre(player, pickup, value)
    --Others
    mod:pennyPickupNitroCrystal(player, pickup, value)
    mod:pennyPickupCoolSunglasses(player, pickup, value)

    --Compatibility
    if pickup.SubType > CoinSubType.COIN_GOLDEN then
        --Base penny trinkets
        pennyPickupBloody(pickup, player, value)
        pennyPickupBurnt(pickup, player, value)
        pennyPickupButt(pickup, player, value)
        pennyPickupCounterfeit(pickup, player, value)
        pennyPickupFlat(pickup, player, value)
        pennyPickupRotten(pickup, player, value)
        pennyPickupBlessed(pickup, player, value)
        pennyPickupCharged(pickup, player, value)
        pennyPickupCursed(pickup, player, value)
        --Retribution penny trinkets
        if Retribution then
            pennyPickupGrubby(pickup, player, value)
            pennyPickupYen(pickup, player, value)
            pennyPickupRainbow(pickup, player, value)
        end
    end
end

mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, function(_, pickup, opp)
	--print(pickup.SubType, pickup.Touched)
    if not pickup.Touched then --Maybe causes issues?
        if pickup.SubType <= CoinSubType.COIN_GOLDEN then
            if opp:ToPlayer() then
                local player = opp:ToPlayer()
                mod:triggerPennyPickup(player, pickup)
            end
        end
    end
end, 20)

--Uncommented, not intended to trigger
--[[mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.EARLY, function(_, pickup, opp)
    --print(pickup.SubType, pickup.Touched)
    if opp:ToPlayer() then
        local player = opp:ToPlayer()
        mod:triggerPennyPickup(player, pickup)
    end
end, 1875)]]

--Other funcs
function mod:pennyPickupCoolSunglasses(player, pickup, value)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.COOL_SUNGLASSES) then
        for _, npc in pairs(Isaac.GetRoomEntities()) do
            if npc:IsActiveEnemy() and npc:IsVulnerableEnemy() and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                npc:TakeDamage(player.Damage*(value/2), 0, EntityRef(player), 0)
            end
        end
        game:ShakeScreen(7)
        SFXManager():Play(SoundEffect.SOUND_SUMMONSOUND, 0.6, 0, false, 1)
        player:GetData().closeenough = 0
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
        player:EvaluateItems()
    end
end
