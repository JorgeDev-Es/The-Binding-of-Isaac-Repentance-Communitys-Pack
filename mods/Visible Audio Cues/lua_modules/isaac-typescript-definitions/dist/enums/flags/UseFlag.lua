local ____exports = {}
--- This is represented as an object instead of an enum due to limitations with TypeScript enums. (We
-- want this type to be a child of the `BitFlag` type.)
-- 
-- @enum
-- @notExported
-- @rename UseFlag
local UseFlagInternal = {
    NO_ANIMATION = 1 << 0,
    NO_COSTUME = 1 << 1,
    OWNED = 1 << 2,
    ALLOW_NON_MAIN_PLAYERS = 1 << 3,
    REMOVE_ACTIVE = 1 << 4,
    CAR_BATTERY = 1 << 5,
    VOID = 1 << 6,
    MIMIC = 1 << 7,
    NO_ANNOUNCER_VOICE = 1 << 8,
    ALLOW_WISP_SPAWN = 1 << 9,
    CUSTOM_VARDATA = 1 << 10,
    NO_HUD = 1 << 11
}
____exports.UseFlag = UseFlagInternal
____exports.UseFlagZero = 0
return ____exports
