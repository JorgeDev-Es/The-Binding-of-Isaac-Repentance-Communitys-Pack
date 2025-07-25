local ____exports = {}
--- Most rooms have a grid index corresponding to their position on the level layout grid. Valid grid
-- indexes range from 0 through 168 (because the grid is 13x13). However, some rooms are not part of
-- the level layout grid. For off-grid rooms, they are assigned special negative integers that
-- correspond to what kind of room they are. This enum contains all of the special negative values
-- that exist.
____exports.GridRoom = {}
____exports.GridRoom.DEVIL = -1
____exports.GridRoom[____exports.GridRoom.DEVIL] = "DEVIL"
____exports.GridRoom.ERROR = -2
____exports.GridRoom[____exports.GridRoom.ERROR] = "ERROR"
____exports.GridRoom.DEBUG = -3
____exports.GridRoom[____exports.GridRoom.DEBUG] = "DEBUG"
____exports.GridRoom.DUNGEON = -4
____exports.GridRoom[____exports.GridRoom.DUNGEON] = "DUNGEON"
____exports.GridRoom.BOSS_RUSH = -5
____exports.GridRoom[____exports.GridRoom.BOSS_RUSH] = "BOSS_RUSH"
____exports.GridRoom.BLACK_MARKET = -6
____exports.GridRoom[____exports.GridRoom.BLACK_MARKET] = "BLACK_MARKET"
____exports.GridRoom.MEGA_SATAN = -7
____exports.GridRoom[____exports.GridRoom.MEGA_SATAN] = "MEGA_SATAN"
____exports.GridRoom.BLUE_WOMB = -8
____exports.GridRoom[____exports.GridRoom.BLUE_WOMB] = "BLUE_WOMB"
____exports.GridRoom.VOID = -9
____exports.GridRoom[____exports.GridRoom.VOID] = "VOID"
____exports.GridRoom.SECRET_EXIT = -10
____exports.GridRoom[____exports.GridRoom.SECRET_EXIT] = "SECRET_EXIT"
____exports.GridRoom.GIDEON_DUNGEON = -11
____exports.GridRoom[____exports.GridRoom.GIDEON_DUNGEON] = "GIDEON_DUNGEON"
____exports.GridRoom.GENESIS = -12
____exports.GridRoom[____exports.GridRoom.GENESIS] = "GENESIS"
____exports.GridRoom.SECRET_SHOP = -13
____exports.GridRoom[____exports.GridRoom.SECRET_SHOP] = "SECRET_SHOP"
____exports.GridRoom.ROTGUT_DUNGEON_1 = -14
____exports.GridRoom[____exports.GridRoom.ROTGUT_DUNGEON_1] = "ROTGUT_DUNGEON_1"
____exports.GridRoom.ROTGUT_DUNGEON_2 = -15
____exports.GridRoom[____exports.GridRoom.ROTGUT_DUNGEON_2] = "ROTGUT_DUNGEON_2"
____exports.GridRoom.BLUE_ROOM = -16
____exports.GridRoom[____exports.GridRoom.BLUE_ROOM] = "BLUE_ROOM"
____exports.GridRoom.EXTRA_BOSS = -17
____exports.GridRoom[____exports.GridRoom.EXTRA_BOSS] = "EXTRA_BOSS"
____exports.GridRoom.ANGEL_SHOP = -18
____exports.GridRoom[____exports.GridRoom.ANGEL_SHOP] = "ANGEL_SHOP"
return ____exports
