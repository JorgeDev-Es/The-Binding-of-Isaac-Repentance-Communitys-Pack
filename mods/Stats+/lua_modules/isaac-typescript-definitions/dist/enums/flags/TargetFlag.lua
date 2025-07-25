local ____exports = {}
--- This is represented as an object instead of an enum due to limitations with TypeScript enums. (We
-- want this type to be a child of the `BitFlag` type.)
-- 
-- @enum
-- @notExported
-- @rename TargetFlag
local TargetFlagInternal = {
    ALLOW_SWITCHING = 1 << 0,
    DONT_PRIORITIZE_ENEMIES_CLOSE_TO_PLAYER = 1 << 1,
    PRIORITIZE_ENEMIES_WITH_HIGH_HP = 1 << 2,
    PRIORITIZE_ENEMIES_WITH_LOW_HP = 1 << 3,
    GIVE_LOWER_PRIORITY_TO_CURRENT_TARGET = 1 << 4
}
____exports.TargetFlag = TargetFlagInternal
____exports.TargetFlagZero = 0
return ____exports
