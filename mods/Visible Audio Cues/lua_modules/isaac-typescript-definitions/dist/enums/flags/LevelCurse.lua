local ____exports = {}
local getLevelCurse
local ____CurseID = require("lua_modules.isaac-typescript-definitions.dist.enums.CurseID")
local CurseID = ____CurseID.CurseID
function getLevelCurse(self, curseID)
    return 1 << curseID - 1
end
--- This is represented as an object instead of an enum due to limitations with TypeScript enums. (We
-- want this type to be a child of the `BitFlag` type.)
-- 
-- @enum
-- @notExported
-- @rename LevelCurse
local LevelCurseInternal = {
    NONE = 0,
    DARKNESS = getLevelCurse(nil, CurseID.DARKNESS),
    LABYRINTH = getLevelCurse(nil, CurseID.LABYRINTH),
    LOST = getLevelCurse(nil, CurseID.LOST),
    UNKNOWN = getLevelCurse(nil, CurseID.UNKNOWN),
    CURSED = getLevelCurse(nil, CurseID.CURSED),
    MAZE = getLevelCurse(nil, CurseID.MAZE),
    BLIND = getLevelCurse(nil, CurseID.BLIND),
    GIANT = getLevelCurse(nil, CurseID.GIANT)
}
____exports.LevelCurse = LevelCurseInternal
____exports.LevelCurseZero = 0
return ____exports
