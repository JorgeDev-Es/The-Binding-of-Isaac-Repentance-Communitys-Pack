local ____exports = {}
--- Matches the `RoomDescriptor.FLAG_*` members of the `RoomDescriptor` class. In IsaacScript, we
-- reimplement this as an object instead, since it is cleaner.
-- 
-- This is represented as an object instead of an enum due to limitations with TypeScript enums. (We
-- want this type to be a child of the `BitFlag` type.)
-- 
-- @enum
-- @notExported
-- @rename RoomDescriptorFlag
local RoomDescriptorFlagInternal = {
    CLEAR = 1 << 0,
    PRESSURE_PLATES_TRIGGERED = 1 << 1,
    SACRIFICE_DONE = 1 << 2,
    CHALLENGE_DONE = 1 << 3,
    SURPRISE_MINIBOSS = 1 << 4,
    HAS_WATER = 1 << 5,
    ALT_BOSS_MUSIC = 1 << 6,
    NO_REWARD = 1 << 7,
    FLOODED = 1 << 8,
    PITCH_BLACK = 1 << 9,
    RED_ROOM = 1 << 10,
    DEVIL_TREASURE = 1 << 11,
    USE_ALTERNATE_BACKDROP = 1 << 12,
    CURSED_MIST = 1 << 13,
    MAMA_MEGA = 1 << 14,
    NO_WALLS = 1 << 15,
    ROTGUT_CLEARED = 1 << 16,
    PORTAL_LINKED = 1 << 17,
    BLUE_REDIRECT = 1 << 18
}
____exports.RoomDescriptorFlag = RoomDescriptorFlagInternal
____exports.RoomDescriptorFlagZero = 0
return ____exports
