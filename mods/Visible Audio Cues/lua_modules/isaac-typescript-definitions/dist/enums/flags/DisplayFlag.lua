local ____exports = {}
--- This is represented as an object instead of an enum due to limitations with TypeScript enums. (We
-- want this type to be a child of the `BitFlag` type.)
-- 
-- @enum
-- @notExported
-- @rename DisplayFlag
local DisplayFlagInternal = {INVISIBLE = 1 << -1, VISIBLE = 1 << 0, SHADOW = 1 << 1, SHOW_ICON = 1 << 2}
____exports.DisplayFlag = DisplayFlagInternal
____exports.DisplayFlagZero = 0
return ____exports
