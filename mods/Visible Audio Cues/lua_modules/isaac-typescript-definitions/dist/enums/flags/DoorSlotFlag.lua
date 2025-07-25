local ____exports = {}
local ____DoorSlot = require("lua_modules.isaac-typescript-definitions.dist.enums.DoorSlot")
local DoorSlot = ____DoorSlot.DoorSlot
--- For `GridEntityType.DOOR` (16).
-- 
-- This is represented as an object instead of an enum due to limitations with TypeScript enums. (We
-- want this type to be a child of the `BitFlag` type.)
-- 
-- @enum
-- @notExported
-- @rename DoorSlotFlag
local DoorSlotFlagInternal = {
    LEFT_0 = 1 << DoorSlot.LEFT_0,
    UP_0 = 1 << DoorSlot.UP_0,
    RIGHT_0 = 1 << DoorSlot.RIGHT_0,
    DOWN_0 = 1 << DoorSlot.DOWN_0,
    LEFT_1 = 1 << DoorSlot.LEFT_1,
    UP_1 = 1 << DoorSlot.UP_1,
    RIGHT_1 = 1 << DoorSlot.RIGHT_1,
    DOWN_1 = 1 << DoorSlot.DOWN_1
}
____exports.DoorSlotFlag = DoorSlotFlagInternal
____exports.DoorSlotFlagZero = 0
return ____exports
