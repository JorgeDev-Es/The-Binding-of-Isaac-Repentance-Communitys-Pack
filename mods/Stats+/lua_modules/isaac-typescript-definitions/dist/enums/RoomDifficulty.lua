local ____exports = {}
--- Each room has an arbitrarily set difficulty of 0, 1, 2, 5, or 10. The floor generation algorithm
-- attempts to generates floors with a combined difficulty of a certain value.
____exports.RoomDifficulty = {}
____exports.RoomDifficulty.ALWAYS_EXCLUDED = 0
____exports.RoomDifficulty[____exports.RoomDifficulty.ALWAYS_EXCLUDED] = "ALWAYS_EXCLUDED"
____exports.RoomDifficulty.VERY_EASY = 1
____exports.RoomDifficulty[____exports.RoomDifficulty.VERY_EASY] = "VERY_EASY"
____exports.RoomDifficulty.EASY = 2
____exports.RoomDifficulty[____exports.RoomDifficulty.EASY] = "EASY"
____exports.RoomDifficulty.MEDIUM = 5
____exports.RoomDifficulty[____exports.RoomDifficulty.MEDIUM] = "MEDIUM"
____exports.RoomDifficulty.HARD = 10
____exports.RoomDifficulty[____exports.RoomDifficulty.HARD] = "HARD"
return ____exports
