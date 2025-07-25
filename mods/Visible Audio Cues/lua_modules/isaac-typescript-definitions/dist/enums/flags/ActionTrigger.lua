local ____exports = {}
--- This is represented as an object instead of an enum due to limitations with TypeScript enums. (We
-- want this type to be a child of the `BitFlag` type.)
-- 
-- @enum
-- @notExported
-- @rename ActionTrigger
local ActionTriggerInternal = {
    NONE = 1 << -1,
    BOMB_PLACED = 1 << 0,
    MOVED = 1 << 1,
    SHOOTING = 1 << 2,
    CARD_PILL_USED = 1 << 3,
    ITEM_ACTIVATED = 1 << 4,
    ITEMS_DROPPED = 1 << 5
}
____exports.ActionTrigger = ActionTriggerInternal
____exports.ActionTriggerZero = 0
return ____exports
