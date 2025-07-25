local ____exports = {}
--- Matches the "id" field in the "resources/curses.xml" file. This is used to compute the
-- `LevelCurse` enum.
-- 
-- The values of this enum are integers. Do not use this enum to check for the presence of curses;
-- use the `LevelCurse` enum instead, which has bit flag values.
____exports.CurseID = {}
____exports.CurseID.DARKNESS = 1
____exports.CurseID[____exports.CurseID.DARKNESS] = "DARKNESS"
____exports.CurseID.LABYRINTH = 2
____exports.CurseID[____exports.CurseID.LABYRINTH] = "LABYRINTH"
____exports.CurseID.LOST = 3
____exports.CurseID[____exports.CurseID.LOST] = "LOST"
____exports.CurseID.UNKNOWN = 4
____exports.CurseID[____exports.CurseID.UNKNOWN] = "UNKNOWN"
____exports.CurseID.CURSED = 5
____exports.CurseID[____exports.CurseID.CURSED] = "CURSED"
____exports.CurseID.MAZE = 6
____exports.CurseID[____exports.CurseID.MAZE] = "MAZE"
____exports.CurseID.BLIND = 7
____exports.CurseID[____exports.CurseID.BLIND] = "BLIND"
____exports.CurseID.GIANT = 8
____exports.CurseID[____exports.CurseID.GIANT] = "GIANT"
return ____exports
