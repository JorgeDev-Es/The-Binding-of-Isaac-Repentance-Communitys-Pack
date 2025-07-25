local ____exports = {}
--- This is represented as an object instead of an enum due to limitations with TypeScript enums. (We
-- want this type to be a child of the `BitFlag` type.)
-- 
-- @enum
-- @notExported
-- @rename DamageFlag
local DamageFlagInternal = {
    NO_KILL = 1 << 0,
    FIRE = 1 << 1,
    EXPLOSION = 1 << 2,
    LASER = 1 << 3,
    ACID = 1 << 4,
    RED_HEARTS = 1 << 5,
    COUNTDOWN = 1 << 6,
    SPIKES = 1 << 7,
    CLONES = 1 << 8,
    POOP = 1 << 9,
    DEVIL = 1 << 10,
    ISSAC_HEART = 1 << 11,
    TNT = 1 << 12,
    INVINCIBLE = 1 << 13,
    SPAWN_FLY = 1 << 14,
    POISON_BURN = 1 << 15,
    CURSED_DOOR = 1 << 16,
    TIMER = 1 << 17,
    IV_BAG = 1 << 18,
    PITFALL = 1 << 19,
    CHEST = 1 << 20,
    FAKE = 1 << 21,
    BOOGER = 1 << 22,
    SPAWN_BLACK_HEART = 1 << 23,
    CRUSH = 1 << 24,
    NO_MODIFIERS = 1 << 25,
    SPAWN_RED_HEART = 1 << 26,
    SPAWN_COIN = 1 << 27,
    NO_PENALTIES = 1 << 28,
    SPAWN_TEMP_HEART = 1 << 29,
    IGNORE_ARMOR = 1 << 30,
    SPAWN_CARD = 1 << 31,
    SPAWN_RUNE = 1 << 32
}
____exports.DamageFlag = DamageFlagInternal
____exports.DamageFlagZero = 0
return ____exports
