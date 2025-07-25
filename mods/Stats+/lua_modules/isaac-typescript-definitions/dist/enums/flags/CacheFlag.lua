local ____exports = {}
--- This is represented as an object instead of an enum due to limitations with TypeScript enums. (We
-- want this type to be a child of the `BitFlag` type.)
-- 
-- @enum
-- @notExported
-- @rename CacheFlag
local CacheFlagInternal = {
    DAMAGE = 1 << 0,
    FIRE_DELAY = 1 << 1,
    SHOT_SPEED = 1 << 2,
    RANGE = 1 << 3,
    SPEED = 1 << 4,
    TEAR_FLAG = 1 << 5,
    TEAR_COLOR = 1 << 6,
    FLYING = 1 << 7,
    WEAPON = 1 << 8,
    FAMILIARS = 1 << 9,
    LUCK = 1 << 10,
    SIZE = 1 << 11,
    COLOR = 1 << 12,
    PICKUP_VISION = 1 << 13,
    ALL = (1 << 16) - 1,
    TWIN_SYNC = 1 << 31
}
____exports.CacheFlag = CacheFlagInternal
____exports.CacheFlagZero = 0
return ____exports
