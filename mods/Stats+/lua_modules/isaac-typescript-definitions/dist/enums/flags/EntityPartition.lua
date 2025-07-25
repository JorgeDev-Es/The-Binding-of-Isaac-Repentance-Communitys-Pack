local ____exports = {}
--- This is represented as an object instead of an enum due to limitations with TypeScript enums. (We
-- want this type to be a child of the `BitFlag` type.)
-- 
-- @enum
-- @notExported
-- @rename EntityPartition
local EntityPartitionInternal = {
    FAMILIAR = 1 << 0,
    BULLET = 1 << 1,
    TEAR = 1 << 2,
    ENEMY = 1 << 3,
    PICKUP = 1 << 4,
    PLAYER = 1 << 5,
    EFFECT = 1 << 6
}
____exports.EntityPartition = EntityPartitionInternal
____exports.EntityPartitionZero = 0
return ____exports
