GOLCG.FICHES = {
    VARIANT = Isaac.GetEntityVariantByName("Poker penny +"),
    SUB = {
        PENNY = 3320,
        PENNY_NEG = 3321,
        NICKEL = 3322,
        NICKEL_NEG = 3323,
        DIME = 3324,
        DIME_NEG = 3325
    },

    SPAWN_CHANCE = 1,   -- Chance to replace a penny with a cursed coin: 1/100
    NICKEL_CHANCE = 40, -- Chance for the cursed coin to be a nickel:    2/5
    DIME_CHANCE = 20,   -- Chance for the cursed coin to be a dime:      1/5

    VALUES = {
        [3320] = 1,
        [3321] = -1,
        [3322] = 5,
        [3323] = -5,
        [3324] = 15,
        [3325] = -15
    }
}

local pickupSpawnData = {}

function GOLCG.CursedCoinPicker(rng)
    local random = rng:RandomInt(100)+1
    local selection = GOLCG.FICHES.SUB.PENNY  -- Default

    if random <= GOLCG.FICHES.DIME_CHANCE then selection = GOLCG.FICHES.SUB.DIME
    elseif random <= GOLCG.FICHES.NICKEL_CHANCE then selection = GOLCG.FICHES.SUB.NICKEL end

    rng:Next()

    if math.random(2) > 1 then -- Not seeded to keep people from abusing it's spawning logic
        selection = selection+1 -- Make subtype negative 
    end

    return selection
end

local function isFiche(pickup)
    return (pickup.SubType > 3319 and pickup.SubType < 3326)
end

local function HandleCoinSpawns(_, pickup)
	if pickup.SubType == CoinSubType.COIN_PENNY and GOLCG.SAVEDATA.CAN_SPAWN_FICHES and not pickup:IsShopItem() then
        local rng = pickup:GetDropRNG()

        if rng:RandomInt(100)+1 <= GOLCG.FICHES.SPAWN_CHANCE then
            rng:Next()
            pickup:Morph(EntityType.ENTITY_PICKUP, GOLCG.FICHES.VARIANT, GOLCG.CursedCoinPicker(rng), true, true)
        end
	end
end

TCC_API:AddTCCCallback("TCC_ON_SPAWN", HandleCoinSpawns, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY)

local function collectCoin(pickup, value)
    pickup = pickup:ToPickup()
    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    pickup.Touched = true

    local sprite = pickup:GetSprite()
    sprite:RemoveOverlay()
    sprite:Play("Collect", true)
    pickup:Die()

    GOLCG.SFX:Play(value > 0 and SoundEffect.SOUND_ULTRA_GREED_SLOT_WIN_LOOP_END or SoundEffect.SOUND_ULTRA_GREED_SLOT_STOP, 1, 0, false, 1.0)
end

local function HandleCoinCollection(_, pickup, collider, low)
    if isFiche(pickup) then
        local sprite = pickup:GetSprite()
        if not sprite:IsPlaying("Idle") and not sprite:WasEventTriggered("DropSound") then return true end

        if collider.Type == EntityType.ENTITY_PLAYER then
            pickup.Velocity = Vector(0,0)
            
            if not pickup:GetData().SEWCOL_MIRRORED then -- :)
                if pickup:IsShopItem() then
                    pickup.Friction = 100

                    if collider:ToPlayer():GetNumCoins() >= pickup.Price then
                        collider:ToPlayer():AddCoins(-pickup.Price)
                        pickup.Price = 0
                        
                        local value = GOLCG.FICHES.VALUES[pickup.SubType] or -1
                        
                        collectCoin(pickup, value)
                        pickup:Update() -- Update so that the price tag instantly dissapears

                        collider:ToPlayer():AddCoins(value)
                    end

                    pickup:Update()
                else
                    local value = GOLCG.FICHES.VALUES[pickup.SubType] or -1

                    collectCoin(pickup, value)
                    collider:ToPlayer():AddCoins(value)
                end
                
                return true
            end
        elseif collider.Type == EntityType.ENTITY_FAMILIAR and (collider.Variant == FamiliarVariant.BUMBO or collider.Variant == FamiliarVariant.BUM_FRIEND) then
            local value = GOLCG.FICHES.VALUES[pickup.SubType] or -1
            collectCoin(pickup, value)
            collider:ToFamiliar().Coins = collider:ToFamiliar().Coins + value
            return true
        elseif collider.Type == EntityType.ENTITY_ULTRA_GREED or collider.Type == EntityType.ENTITY_BUMBINO then
            local value = GOLCG.FICHES.VALUES[pickup.SubType] or -1
            collectCoin(pickup, value)
            return true
        end
    end
end

GOLCG:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, HandleCoinCollection, GOLCG.FICHES.VARIANT)

local function HandleCoinUpdate(_, pickup)
    if isFiche(pickup) then
        local sprite = pickup:GetSprite()

        if sprite:IsEventTriggered("DropSound") then
            GOLCG.SFX:Play(SoundEffect.SOUND_BONE_BOUNCE, 1, 0)
        end
        
        if sprite:IsPlaying("Collect") then
            pickup.Velocity = Vector(0,0)
        end

        if pickup:GetData() and not pickup:GetData().TGCISynChecked and sprite:IsPlaying("Idle") then
            -- Guppys Eye synergy
            local numPlayers = GOLCG.GAME:GetNumPlayers()
            for i=1,numPlayers do
                local player = GOLCG.GAME:GetPlayer(tostring((i-1)))
                if player:HasCollectible(CollectibleType.COLLECTIBLE_GUPPYS_EYE) then
                    pickup:GetSprite():PlayOverlay(((type(pickup.SubType) == 'number' and (GOLCG.FICHES.VALUES[pickup.SubType] or -1) > 0) and "Up" or "Down"), false)
                end

                pickup:GetData().TGCISynChecked = true
            end
        end
    end
end

GOLCG:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, HandleCoinUpdate, GOLCG.FICHES.VARIANT)

if MinimapAPI then
    MinimapAPI:AddPickup("GOLCOL Poker penny",   "GOLCOL Poker penny",  5, 3320, 0,  nil, "fiches", 2500)
    MinimapAPI:AddPickup("GOLCOL Poker penny+",  "GOLCOL Poker penny",  5, 3320, 10, nil, "fiches", 2500)
    MinimapAPI:AddPickup("GOLCOL Poker penny-",  "GOLCOL Poker penny",  5, 3320, 11, nil, "fiches", 2500)
    MinimapAPI:AddPickup("GOLCOL Poker nickel+", "GOLCOL Poker nickel", 5, 3320, 20, nil, "fiches", 2501)
    MinimapAPI:AddPickup("GOLCOL Poker nickel-", "GOLCOL Poker nickel", 5, 3320, 21, nil, "fiches", 2501)
    MinimapAPI:AddPickup("GOLCOL Poker dime+",   "GOLCOL Poker dime",   5, 3320, 30, nil, "fiches", 2502)
    MinimapAPI:AddPickup("GOLCOL Poker dime-",   "GOLCOL Poker dime",   5, 3320, 31, nil, "fiches", 2502)
end
