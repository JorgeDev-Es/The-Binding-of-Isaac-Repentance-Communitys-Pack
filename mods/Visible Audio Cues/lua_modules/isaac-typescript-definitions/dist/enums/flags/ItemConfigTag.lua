local ____exports = {}
--- Matches the ItemConfig.TAG_ members of the ItemConfig class. In IsaacScript, we re-implement this
-- as an object instead, since it is cleaner.
-- 
-- This is represented as an object instead of an enum due to limitations with TypeScript enums. (We
-- want this type to be a child of the `BitFlag` type.)
-- 
-- @enum
-- @notExported
-- @rename ItemConfigTag
local ItemConfigTagInternal = {
    DEAD = 1 << 0,
    SYRINGE = 1 << 1,
    MOM = 1 << 2,
    TECH = 1 << 3,
    BATTERY = 1 << 4,
    GUPPY = 1 << 5,
    FLY = 1 << 6,
    BOB = 1 << 7,
    MUSHROOM = 1 << 8,
    BABY = 1 << 9,
    ANGEL = 1 << 10,
    DEVIL = 1 << 11,
    POOP = 1 << 12,
    BOOK = 1 << 13,
    SPIDER = 1 << 14,
    QUEST = 1 << 15,
    MONSTER_MANUAL = 1 << 16,
    NO_GREED = 1 << 17,
    FOOD = 1 << 18,
    TEARS_UP = 1 << 19,
    OFFENSIVE = 1 << 20,
    NO_KEEPER = 1 << 21,
    NO_LOST_BR = 1 << 22,
    STARS = 1 << 23,
    SUMMONABLE = 1 << 24,
    NO_CANTRIP = 1 << 25,
    WISP = 1 << 26,
    UNIQUE_FAMILIAR = 1 << 27,
    NO_CHALLENGE = 1 << 28,
    NO_DAILY = 1 << 29,
    LAZ_SHARED = 1 << 30,
    LAZ_SHARED_GLOBAL = 1 << 31,
    NO_EDEN = 1 << 32
}
____exports.ItemConfigTag = ItemConfigTagInternal
____exports.ItemConfigTagZero = 0
return ____exports
