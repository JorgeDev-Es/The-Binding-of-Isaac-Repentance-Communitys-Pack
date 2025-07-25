local ____exports = {}
--- GridPath is not an enum, but rather a variable integer that represents the cost it would take for
-- an entity to pass through a grid entity. This enum lists some standard cost values that the
-- vanilla game uses.
____exports.GridPath = {}
____exports.GridPath.NONE = 0
____exports.GridPath[____exports.GridPath.NONE] = "NONE"
____exports.GridPath.WALKED_TILE = 900
____exports.GridPath[____exports.GridPath.WALKED_TILE] = "WALKED_TILE"
____exports.GridPath.FIREPLACE = 950
____exports.GridPath[____exports.GridPath.FIREPLACE] = "FIREPLACE"
____exports.GridPath.ROCK = 1000
____exports.GridPath[____exports.GridPath.ROCK] = "ROCK"
____exports.GridPath.PIT = 3000
____exports.GridPath[____exports.GridPath.PIT] = "PIT"
____exports.GridPath.GRIMACE = 3999
____exports.GridPath[____exports.GridPath.GRIMACE] = "GRIMACE"
return ____exports
