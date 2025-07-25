local ReverseHermit = {}

local utility = JosephMod.utility
local enums = JosephMod.enums


local PICKUP_PRICES = {
    [PickupVariant.PICKUP_HEART] = {
        [0] = 1, -- Default value if the subtype does not have an entry
        [HeartSubType.HEART_FULL] = 3,
        [HeartSubType.HEART_HALF] = 1,
        [HeartSubType.HEART_SOUL] = 5,
        [HeartSubType.HEART_ETERNAL] = 10,
        [HeartSubType.HEART_DOUBLEPACK] = 6,
        [HeartSubType.HEART_BLACK] = 6,
        [HeartSubType.HEART_GOLDEN] = 10,
        [HeartSubType.HEART_HALF_SOUL] = 2,
        [HeartSubType.HEART_SCARED] = 3,
        [HeartSubType.HEART_BLENDED] = 3,
        [HeartSubType.HEART_BONE] = 6,
        [HeartSubType.HEART_ROTTEN] = 2,
    },

    [PickupVariant.PICKUP_COIN] = {
        [0] = 0
    },

    [PickupVariant.PICKUP_KEY] = {
        [0] = 5,
        [KeySubType.KEY_NORMAL] = 5,
        [KeySubType.KEY_GOLDEN] = 10,
        [KeySubType.KEY_DOUBLEPACK] = 10,
        [KeySubType.KEY_CHARGED] = 10,
        
    },

    [PickupVariant.PICKUP_BOMB] = {
        [0] = 5,
        [BombSubType.BOMB_NORMAL] = 5,
        [BombSubType.BOMB_DOUBLEPACK] = 10,
        [BombSubType.BOMB_TROLL] = 0,
        [BombSubType.BOMB_GOLDEN] = 10,
        [BombSubType.BOMB_SUPERTROLL] = 0,
        [BombSubType.BOMB_GOLDENTROLL] = 0,
        [BombSubType.BOMB_GIGA] = 10,

    },

    [PickupVariant.PICKUP_THROWABLEBOMB] = {
        [0] = 0,
    },

    [PickupVariant.PICKUP_POOP] = {
        [0] = 0,
        [PoopPickupSubType.POOP_SMALL] = 0,
        [PoopPickupSubType.POOP_BIG] = 0,
    },


    [PickupVariant.PICKUP_GRAB_BAG] = {
        [0] = 7,
        [SackSubType.SACK_NORMAL] = 7,
        [SackSubType.SACK_BLACK] = 7
    },


    [PickupVariant.PICKUP_LIL_BATTERY] = {
        [0] = 5,
        [BatterySubType.BATTERY_NORMAL] = 5,
        [BatterySubType.BATTERY_MICRO] = 5,
        [BatterySubType.BATTERY_MEGA] = 5,
        [BatterySubType.BATTERY_GOLDEN] = 5,
    },


    [PickupVariant.PICKUP_PILL] = {
        [0] = 5
    },

    [PickupVariant.PICKUP_TAROTCARD] = {
        [0] = 5
    },

    [PickupVariant.PICKUP_TRINKET] = {
        [0] = 5
    },

    [PickupVariant.PICKUP_COLLECTIBLE] = {
        [0] = 15
    },


    [PickupVariant.PICKUP_CHEST] = {
        [0] = 0
    },
    [PickupVariant.PICKUP_BOMBCHEST] = {
        [0] = 0
    },
    [PickupVariant.PICKUP_SPIKEDCHEST] = {
        [0] = 0
    },
    [PickupVariant.PICKUP_ETERNALCHEST] = {
        [0] = 0
    },
    [PickupVariant.PICKUP_MIMICCHEST] = {
        [0] = 0
    },
    [PickupVariant.PICKUP_OLDCHEST] = {
        [0] = 0
    },
    [PickupVariant.PICKUP_WOODENCHEST] = {
        [0] = 0
    },
    [PickupVariant.PICKUP_MEGACHEST] = {
        [0] = 0
    },
    [PickupVariant.PICKUP_HAUNTEDCHEST] = {
        [0] = 0
    },
    [PickupVariant.PICKUP_LOCKEDCHEST] = {
        [0] = 0
    },
    [PickupVariant.PICKUP_BROKEN_SHOVEL] = {
        [0] = 0
    },    
    [PickupVariant.PICKUP_SHOPITEM] = {
        [0] = 0
    },    
    [PickupVariant.PICKUP_BIGCHEST] = {
        [0] = 0
    },    
    [PickupVariant.PICKUP_REDCHEST] = {
        [0] = 0
    },    
    [PickupVariant.PICKUP_TROPHY] = {
        [0] = 0
    },    
    [PickupVariant.PICKUP_BED] = {
        [0] = 0
    },
    [PickupVariant.PICKUP_MOMSCHEST] = {
        [0] = 0
    },

}


function ReverseHermit:GetPickupValue(variant, subtype)
    return (PICKUP_PRICES[variant] and PICKUP_PRICES[variant][subtype]) or (PICKUP_PRICES[variant] and PICKUP_PRICES[variant][0]) or 0
end


function ReverseHermit:touchPickup(pickup, collider)
    if pickup:IsShopItem() then return end
    local player = collider:ToPlayer()
    if not (player and utility:HasEnchantment(player, Card.CARD_REVERSE_HERMIT)) then return end

    local pickupValue = ReverseHermit:GetPickupValue(pickup.Variant, pickup.SubType)
    if pickupValue == 0 then return end

    while pickupValue > 0 do
        if pickupValue >= 10 then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL, pickup.Position, 3*RandomVector(), player)
            pickupValue = pickupValue - 5
        else
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, pickup.Position, 3*RandomVector(), player)
            pickupValue = pickupValue - 1
        end
    end

    local poof = Isaac.Spawn(1000, 15, 0, pickup.Position, Vector.Zero, nil)
    poof.Color = Color(1, 1, 1, 1, 0, 0, 0, 3, 2.4, 1, 1)
    SFXManager():Play(SoundEffect.SOUND_CASH_REGISTER)
    --SFXManager():Play(SoundEffect.SOUND_FETUS_JUMP)
    SFXManager():Play(SoundEffect.SOUND_BLACK_POOF)
    pickup:Remove()
    return true

end
JosephMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, ReverseHermit.touchPickup)

---@param player EntityPlayer
---@param card Card
function ReverseHermit:initReverseHermit(player, card)

end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_ADD, ReverseHermit.initReverseHermit, Card.CARD_REVERSE_HERMIT)


---@param player EntityPlayer
---@param card Card
---@param slot CardSlot
function ReverseHermit:removeReverseHermit(player, card, slot)

end
JosephMod:AddCallback(enums.Callbacks.JOSEPH_POST_ENCHANT_REMOVE, ReverseHermit.removeReverseHermit, Card.CARD_REVERSE_HERMIT)