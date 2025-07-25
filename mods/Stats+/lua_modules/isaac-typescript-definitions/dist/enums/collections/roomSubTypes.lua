local ____exports = {}
--- For `StageID.SPECIAL_ROOMS` (0), `RoomType.SHOP` (2).
-- 
-- This matches the sub-type in the "00.special rooms.stb" file.
____exports.ShopSubType = {}
____exports.ShopSubType.LEVEL_1 = 0
____exports.ShopSubType[____exports.ShopSubType.LEVEL_1] = "LEVEL_1"
____exports.ShopSubType.LEVEL_2 = 1
____exports.ShopSubType[____exports.ShopSubType.LEVEL_2] = "LEVEL_2"
____exports.ShopSubType.LEVEL_3 = 2
____exports.ShopSubType[____exports.ShopSubType.LEVEL_3] = "LEVEL_3"
____exports.ShopSubType.LEVEL_4 = 3
____exports.ShopSubType[____exports.ShopSubType.LEVEL_4] = "LEVEL_4"
____exports.ShopSubType.LEVEL_5 = 4
____exports.ShopSubType[____exports.ShopSubType.LEVEL_5] = "LEVEL_5"
____exports.ShopSubType.RARE_GOOD = 10
____exports.ShopSubType[____exports.ShopSubType.RARE_GOOD] = "RARE_GOOD"
____exports.ShopSubType.RARE_BAD = 11
____exports.ShopSubType[____exports.ShopSubType.RARE_BAD] = "RARE_BAD"
____exports.ShopSubType.TAINTED_KEEPER_LEVEL_1 = 100
____exports.ShopSubType[____exports.ShopSubType.TAINTED_KEEPER_LEVEL_1] = "TAINTED_KEEPER_LEVEL_1"
____exports.ShopSubType.TAINTED_KEEPER_LEVEL_2 = 101
____exports.ShopSubType[____exports.ShopSubType.TAINTED_KEEPER_LEVEL_2] = "TAINTED_KEEPER_LEVEL_2"
____exports.ShopSubType.TAINTED_KEEPER_LEVEL_3 = 102
____exports.ShopSubType[____exports.ShopSubType.TAINTED_KEEPER_LEVEL_3] = "TAINTED_KEEPER_LEVEL_3"
____exports.ShopSubType.TAINTED_KEEPER_LEVEL_4 = 103
____exports.ShopSubType[____exports.ShopSubType.TAINTED_KEEPER_LEVEL_4] = "TAINTED_KEEPER_LEVEL_4"
____exports.ShopSubType.TAINTED_KEEPER_LEVEL_5 = 104
____exports.ShopSubType[____exports.ShopSubType.TAINTED_KEEPER_LEVEL_5] = "TAINTED_KEEPER_LEVEL_5"
____exports.ShopSubType.TAINTED_KEEPER_RARE_GOOD = 110
____exports.ShopSubType[____exports.ShopSubType.TAINTED_KEEPER_RARE_GOOD] = "TAINTED_KEEPER_RARE_GOOD"
____exports.ShopSubType.TAINTED_KEEPER_RARE_BAD = 111
____exports.ShopSubType[____exports.ShopSubType.TAINTED_KEEPER_RARE_BAD] = "TAINTED_KEEPER_RARE_BAD"
--- For `StageID.SPECIAL_ROOMS` (0), `RoomType.TREASURE` (4).
-- 
-- This matches the sub-type in the "00.special rooms.stb" file and elsewhere.
____exports.TreasureRoomSubType = {}
____exports.TreasureRoomSubType.NORMAL = 0
____exports.TreasureRoomSubType[____exports.TreasureRoomSubType.NORMAL] = "NORMAL"
____exports.TreasureRoomSubType.MORE_OPTIONS = 1
____exports.TreasureRoomSubType[____exports.TreasureRoomSubType.MORE_OPTIONS] = "MORE_OPTIONS"
____exports.TreasureRoomSubType.PAY_TO_WIN = 2
____exports.TreasureRoomSubType[____exports.TreasureRoomSubType.PAY_TO_WIN] = "PAY_TO_WIN"
____exports.TreasureRoomSubType.MORE_OPTIONS_AND_PAY_TO_WIN = 3
____exports.TreasureRoomSubType[____exports.TreasureRoomSubType.MORE_OPTIONS_AND_PAY_TO_WIN] = "MORE_OPTIONS_AND_PAY_TO_WIN"
____exports.TreasureRoomSubType.KNIFE_PIECE = 34
____exports.TreasureRoomSubType[____exports.TreasureRoomSubType.KNIFE_PIECE] = "KNIFE_PIECE"
--- For `StageID.SPECIAL_ROOMS` (0), `RoomType.BOSS` (5).
-- 
-- This matches the "bossID" attribute in the "entities2.xml" file. It also matches the sub-type in
-- the "00.special rooms.stb" file.
-- 
-- The enum is named `BossID` instead of `BossRoomSubType` in order to match the `Entity.GetBossID`,
-- `Room.GetBossID` and `Room.GetSecondBossID` methods.
-- 
-- This enum is contiguous. (Every value is satisfied between 1 and 102, inclusive.)
-- 
-- Also see the `MinibossID` enum.
____exports.BossID = {}
____exports.BossID.MONSTRO = 1
____exports.BossID[____exports.BossID.MONSTRO] = "MONSTRO"
____exports.BossID.LARRY_JR = 2
____exports.BossID[____exports.BossID.LARRY_JR] = "LARRY_JR"
____exports.BossID.CHUB = 3
____exports.BossID[____exports.BossID.CHUB] = "CHUB"
____exports.BossID.GURDY = 4
____exports.BossID[____exports.BossID.GURDY] = "GURDY"
____exports.BossID.MONSTRO_2 = 5
____exports.BossID[____exports.BossID.MONSTRO_2] = "MONSTRO_2"
____exports.BossID.MOM = 6
____exports.BossID[____exports.BossID.MOM] = "MOM"
____exports.BossID.SCOLEX = 7
____exports.BossID[____exports.BossID.SCOLEX] = "SCOLEX"
____exports.BossID.MOMS_HEART = 8
____exports.BossID[____exports.BossID.MOMS_HEART] = "MOMS_HEART"
____exports.BossID.FAMINE = 9
____exports.BossID[____exports.BossID.FAMINE] = "FAMINE"
____exports.BossID.PESTILENCE = 10
____exports.BossID[____exports.BossID.PESTILENCE] = "PESTILENCE"
____exports.BossID.WAR = 11
____exports.BossID[____exports.BossID.WAR] = "WAR"
____exports.BossID.DEATH = 12
____exports.BossID[____exports.BossID.DEATH] = "DEATH"
____exports.BossID.DUKE_OF_FLIES = 13
____exports.BossID[____exports.BossID.DUKE_OF_FLIES] = "DUKE_OF_FLIES"
____exports.BossID.PEEP = 14
____exports.BossID[____exports.BossID.PEEP] = "PEEP"
____exports.BossID.LOKI = 15
____exports.BossID[____exports.BossID.LOKI] = "LOKI"
____exports.BossID.BLASTOCYST = 16
____exports.BossID[____exports.BossID.BLASTOCYST] = "BLASTOCYST"
____exports.BossID.GEMINI = 17
____exports.BossID[____exports.BossID.GEMINI] = "GEMINI"
____exports.BossID.FISTULA = 18
____exports.BossID[____exports.BossID.FISTULA] = "FISTULA"
____exports.BossID.GISH = 19
____exports.BossID[____exports.BossID.GISH] = "GISH"
____exports.BossID.STEVEN = 20
____exports.BossID[____exports.BossID.STEVEN] = "STEVEN"
____exports.BossID.CHAD = 21
____exports.BossID[____exports.BossID.CHAD] = "CHAD"
____exports.BossID.HEADLESS_HORSEMAN = 22
____exports.BossID[____exports.BossID.HEADLESS_HORSEMAN] = "HEADLESS_HORSEMAN"
____exports.BossID.FALLEN = 23
____exports.BossID[____exports.BossID.FALLEN] = "FALLEN"
____exports.BossID.SATAN = 24
____exports.BossID[____exports.BossID.SATAN] = "SATAN"
____exports.BossID.IT_LIVES = 25
____exports.BossID[____exports.BossID.IT_LIVES] = "IT_LIVES"
____exports.BossID.HOLLOW = 26
____exports.BossID[____exports.BossID.HOLLOW] = "HOLLOW"
____exports.BossID.CARRION_QUEEN = 27
____exports.BossID[____exports.BossID.CARRION_QUEEN] = "CARRION_QUEEN"
____exports.BossID.GURDY_JR = 28
____exports.BossID[____exports.BossID.GURDY_JR] = "GURDY_JR"
____exports.BossID.HUSK = 29
____exports.BossID[____exports.BossID.HUSK] = "HUSK"
____exports.BossID.BLOAT = 30
____exports.BossID[____exports.BossID.BLOAT] = "BLOAT"
____exports.BossID.LOKII = 31
____exports.BossID[____exports.BossID.LOKII] = "LOKII"
____exports.BossID.BLIGHTED_OVUM = 32
____exports.BossID[____exports.BossID.BLIGHTED_OVUM] = "BLIGHTED_OVUM"
____exports.BossID.TERATOMA = 33
____exports.BossID[____exports.BossID.TERATOMA] = "TERATOMA"
____exports.BossID.WIDOW = 34
____exports.BossID[____exports.BossID.WIDOW] = "WIDOW"
____exports.BossID.MASK_OF_INFAMY = 35
____exports.BossID[____exports.BossID.MASK_OF_INFAMY] = "MASK_OF_INFAMY"
____exports.BossID.WRETCHED = 36
____exports.BossID[____exports.BossID.WRETCHED] = "WRETCHED"
____exports.BossID.PIN = 37
____exports.BossID[____exports.BossID.PIN] = "PIN"
____exports.BossID.CONQUEST = 38
____exports.BossID[____exports.BossID.CONQUEST] = "CONQUEST"
____exports.BossID.ISAAC = 39
____exports.BossID[____exports.BossID.ISAAC] = "ISAAC"
____exports.BossID.BLUE_BABY = 40
____exports.BossID[____exports.BossID.BLUE_BABY] = "BLUE_BABY"
____exports.BossID.DADDY_LONG_LEGS = 41
____exports.BossID[____exports.BossID.DADDY_LONG_LEGS] = "DADDY_LONG_LEGS"
____exports.BossID.TRIACHNID = 42
____exports.BossID[____exports.BossID.TRIACHNID] = "TRIACHNID"
____exports.BossID.HAUNT = 43
____exports.BossID[____exports.BossID.HAUNT] = "HAUNT"
____exports.BossID.DINGLE = 44
____exports.BossID[____exports.BossID.DINGLE] = "DINGLE"
____exports.BossID.MEGA_MAW = 45
____exports.BossID[____exports.BossID.MEGA_MAW] = "MEGA_MAW"
____exports.BossID.GATE = 46
____exports.BossID[____exports.BossID.GATE] = "GATE"
____exports.BossID.MEGA_FATTY = 47
____exports.BossID[____exports.BossID.MEGA_FATTY] = "MEGA_FATTY"
____exports.BossID.CAGE = 48
____exports.BossID[____exports.BossID.CAGE] = "CAGE"
____exports.BossID.MAMA_GURDY = 49
____exports.BossID[____exports.BossID.MAMA_GURDY] = "MAMA_GURDY"
____exports.BossID.DARK_ONE = 50
____exports.BossID[____exports.BossID.DARK_ONE] = "DARK_ONE"
____exports.BossID.ADVERSARY = 51
____exports.BossID[____exports.BossID.ADVERSARY] = "ADVERSARY"
____exports.BossID.POLYCEPHALUS = 52
____exports.BossID[____exports.BossID.POLYCEPHALUS] = "POLYCEPHALUS"
____exports.BossID.MR_FRED = 53
____exports.BossID[____exports.BossID.MR_FRED] = "MR_FRED"
____exports.BossID.LAMB = 54
____exports.BossID[____exports.BossID.LAMB] = "LAMB"
____exports.BossID.MEGA_SATAN = 55
____exports.BossID[____exports.BossID.MEGA_SATAN] = "MEGA_SATAN"
____exports.BossID.GURGLING = 56
____exports.BossID[____exports.BossID.GURGLING] = "GURGLING"
____exports.BossID.STAIN = 57
____exports.BossID[____exports.BossID.STAIN] = "STAIN"
____exports.BossID.BROWNIE = 58
____exports.BossID[____exports.BossID.BROWNIE] = "BROWNIE"
____exports.BossID.FORSAKEN = 59
____exports.BossID[____exports.BossID.FORSAKEN] = "FORSAKEN"
____exports.BossID.LITTLE_HORN = 60
____exports.BossID[____exports.BossID.LITTLE_HORN] = "LITTLE_HORN"
____exports.BossID.RAG_MAN = 61
____exports.BossID[____exports.BossID.RAG_MAN] = "RAG_MAN"
____exports.BossID.ULTRA_GREED = 62
____exports.BossID[____exports.BossID.ULTRA_GREED] = "ULTRA_GREED"
____exports.BossID.HUSH = 63
____exports.BossID[____exports.BossID.HUSH] = "HUSH"
____exports.BossID.DANGLE = 64
____exports.BossID[____exports.BossID.DANGLE] = "DANGLE"
____exports.BossID.TURDLING = 65
____exports.BossID[____exports.BossID.TURDLING] = "TURDLING"
____exports.BossID.FRAIL = 66
____exports.BossID[____exports.BossID.FRAIL] = "FRAIL"
____exports.BossID.RAG_MEGA = 67
____exports.BossID[____exports.BossID.RAG_MEGA] = "RAG_MEGA"
____exports.BossID.SISTERS_VIS = 68
____exports.BossID[____exports.BossID.SISTERS_VIS] = "SISTERS_VIS"
____exports.BossID.BIG_HORN = 69
____exports.BossID[____exports.BossID.BIG_HORN] = "BIG_HORN"
____exports.BossID.DELIRIUM = 70
____exports.BossID[____exports.BossID.DELIRIUM] = "DELIRIUM"
____exports.BossID.ULTRA_GREEDIER = 71
____exports.BossID[____exports.BossID.ULTRA_GREEDIER] = "ULTRA_GREEDIER"
____exports.BossID.MATRIARCH = 72
____exports.BossID[____exports.BossID.MATRIARCH] = "MATRIARCH"
____exports.BossID.PILE = 73
____exports.BossID[____exports.BossID.PILE] = "PILE"
____exports.BossID.REAP_CREEP = 74
____exports.BossID[____exports.BossID.REAP_CREEP] = "REAP_CREEP"
____exports.BossID.LIL_BLUB = 75
____exports.BossID[____exports.BossID.LIL_BLUB] = "LIL_BLUB"
____exports.BossID.WORMWOOD = 76
____exports.BossID[____exports.BossID.WORMWOOD] = "WORMWOOD"
____exports.BossID.RAINMAKER = 77
____exports.BossID[____exports.BossID.RAINMAKER] = "RAINMAKER"
____exports.BossID.VISAGE = 78
____exports.BossID[____exports.BossID.VISAGE] = "VISAGE"
____exports.BossID.SIREN = 79
____exports.BossID[____exports.BossID.SIREN] = "SIREN"
____exports.BossID.TUFF_TWINS = 80
____exports.BossID[____exports.BossID.TUFF_TWINS] = "TUFF_TWINS"
____exports.BossID.HERETIC = 81
____exports.BossID[____exports.BossID.HERETIC] = "HERETIC"
____exports.BossID.HORNFEL = 82
____exports.BossID[____exports.BossID.HORNFEL] = "HORNFEL"
____exports.BossID.GREAT_GIDEON = 83
____exports.BossID[____exports.BossID.GREAT_GIDEON] = "GREAT_GIDEON"
____exports.BossID.BABY_PLUM = 84
____exports.BossID[____exports.BossID.BABY_PLUM] = "BABY_PLUM"
____exports.BossID.SCOURGE = 85
____exports.BossID[____exports.BossID.SCOURGE] = "SCOURGE"
____exports.BossID.CHIMERA = 86
____exports.BossID[____exports.BossID.CHIMERA] = "CHIMERA"
____exports.BossID.ROTGUT = 87
____exports.BossID[____exports.BossID.ROTGUT] = "ROTGUT"
____exports.BossID.MOTHER = 88
____exports.BossID[____exports.BossID.MOTHER] = "MOTHER"
____exports.BossID.MAUSOLEUM_MOM = 89
____exports.BossID[____exports.BossID.MAUSOLEUM_MOM] = "MAUSOLEUM_MOM"
____exports.BossID.MAUSOLEUM_MOMS_HEART = 90
____exports.BossID[____exports.BossID.MAUSOLEUM_MOMS_HEART] = "MAUSOLEUM_MOMS_HEART"
____exports.BossID.MIN_MIN = 91
____exports.BossID[____exports.BossID.MIN_MIN] = "MIN_MIN"
____exports.BossID.CLOG = 92
____exports.BossID[____exports.BossID.CLOG] = "CLOG"
____exports.BossID.SINGE = 93
____exports.BossID[____exports.BossID.SINGE] = "SINGE"
____exports.BossID.BUMBINO = 94
____exports.BossID[____exports.BossID.BUMBINO] = "BUMBINO"
____exports.BossID.COLOSTOMIA = 95
____exports.BossID[____exports.BossID.COLOSTOMIA] = "COLOSTOMIA"
____exports.BossID.SHELL = 96
____exports.BossID[____exports.BossID.SHELL] = "SHELL"
____exports.BossID.TURDLET = 97
____exports.BossID[____exports.BossID.TURDLET] = "TURDLET"
____exports.BossID.RAGLICH = 98
____exports.BossID[____exports.BossID.RAGLICH] = "RAGLICH"
____exports.BossID.DOGMA = 99
____exports.BossID[____exports.BossID.DOGMA] = "DOGMA"
____exports.BossID.BEAST = 100
____exports.BossID[____exports.BossID.BEAST] = "BEAST"
____exports.BossID.HORNY_BOYS = 101
____exports.BossID[____exports.BossID.HORNY_BOYS] = "HORNY_BOYS"
____exports.BossID.CLUTCH = 102
____exports.BossID[____exports.BossID.CLUTCH] = "CLUTCH"
--- For `StageID.SPECIAL_ROOMS` (0), `RoomType.MINI_BOSS` (6).
-- 
-- This matches the sub-type in the "00.special rooms.stb" file.
-- 
-- The enum is named `MinibossID` instead of` MinibossRoomSubType` in order to match the `BossID`
-- enum.
-- 
-- Also see the `BossID` enum.
____exports.MinibossID = {}
____exports.MinibossID.SLOTH = 0
____exports.MinibossID[____exports.MinibossID.SLOTH] = "SLOTH"
____exports.MinibossID.LUST = 1
____exports.MinibossID[____exports.MinibossID.LUST] = "LUST"
____exports.MinibossID.WRATH = 2
____exports.MinibossID[____exports.MinibossID.WRATH] = "WRATH"
____exports.MinibossID.GLUTTONY = 3
____exports.MinibossID[____exports.MinibossID.GLUTTONY] = "GLUTTONY"
____exports.MinibossID.GREED = 4
____exports.MinibossID[____exports.MinibossID.GREED] = "GREED"
____exports.MinibossID.ENVY = 5
____exports.MinibossID[____exports.MinibossID.ENVY] = "ENVY"
____exports.MinibossID.PRIDE = 6
____exports.MinibossID[____exports.MinibossID.PRIDE] = "PRIDE"
____exports.MinibossID.SUPER_SLOTH = 7
____exports.MinibossID[____exports.MinibossID.SUPER_SLOTH] = "SUPER_SLOTH"
____exports.MinibossID.SUPER_LUST = 8
____exports.MinibossID[____exports.MinibossID.SUPER_LUST] = "SUPER_LUST"
____exports.MinibossID.SUPER_WRATH = 9
____exports.MinibossID[____exports.MinibossID.SUPER_WRATH] = "SUPER_WRATH"
____exports.MinibossID.SUPER_GLUTTONY = 10
____exports.MinibossID[____exports.MinibossID.SUPER_GLUTTONY] = "SUPER_GLUTTONY"
____exports.MinibossID.SUPER_GREED = 11
____exports.MinibossID[____exports.MinibossID.SUPER_GREED] = "SUPER_GREED"
____exports.MinibossID.SUPER_ENVY = 12
____exports.MinibossID[____exports.MinibossID.SUPER_ENVY] = "SUPER_ENVY"
____exports.MinibossID.SUPER_PRIDE = 13
____exports.MinibossID[____exports.MinibossID.SUPER_PRIDE] = "SUPER_PRIDE"
____exports.MinibossID.ULTRA_PRIDE = 14
____exports.MinibossID[____exports.MinibossID.ULTRA_PRIDE] = "ULTRA_PRIDE"
____exports.MinibossID.KRAMPUS = 15
____exports.MinibossID[____exports.MinibossID.KRAMPUS] = "KRAMPUS"
--- For `StageID.SPECIAL_ROOMS` (0), `RoomType.CURSE` (10).
-- 
-- This matches the sub-type in the "00.special rooms.stb" file.
____exports.CurseRoomSubType = {}
____exports.CurseRoomSubType.NORMAL = 0
____exports.CurseRoomSubType[____exports.CurseRoomSubType.NORMAL] = "NORMAL"
____exports.CurseRoomSubType.VOODOO_HEAD = 1
____exports.CurseRoomSubType[____exports.CurseRoomSubType.VOODOO_HEAD] = "VOODOO_HEAD"
--- For `StageID.SPECIAL_ROOMS` (0), `RoomType.CHALLENGE` (11).
-- 
-- This matches the sub-type in the "00.special rooms.stb" file and elsewhere.
____exports.ChallengeRoomSubType = {}
____exports.ChallengeRoomSubType.NORMAL = 0
____exports.ChallengeRoomSubType[____exports.ChallengeRoomSubType.NORMAL] = "NORMAL"
____exports.ChallengeRoomSubType.BOSS = 1
____exports.ChallengeRoomSubType[____exports.ChallengeRoomSubType.BOSS] = "BOSS"
____exports.ChallengeRoomSubType.NORMAL_WAVE = 10
____exports.ChallengeRoomSubType[____exports.ChallengeRoomSubType.NORMAL_WAVE] = "NORMAL_WAVE"
____exports.ChallengeRoomSubType.BOSS_WAVE = 11
____exports.ChallengeRoomSubType[____exports.ChallengeRoomSubType.BOSS_WAVE] = "BOSS_WAVE"
____exports.ChallengeRoomSubType.GREAT_GIDEON_WAVE = 12
____exports.ChallengeRoomSubType[____exports.ChallengeRoomSubType.GREAT_GIDEON_WAVE] = "GREAT_GIDEON_WAVE"
--- For `StageID.SPECIAL_ROOMS` (0), `RoomType.LIBRARY` (12).
-- 
-- This matches the sub-type in the "00.special rooms.stb" file.
____exports.LibrarySubType = {}
____exports.LibrarySubType.LEVEL_1 = 0
____exports.LibrarySubType[____exports.LibrarySubType.LEVEL_1] = "LEVEL_1"
____exports.LibrarySubType.LEVEL_2 = 1
____exports.LibrarySubType[____exports.LibrarySubType.LEVEL_2] = "LEVEL_2"
____exports.LibrarySubType.LEVEL_3 = 2
____exports.LibrarySubType[____exports.LibrarySubType.LEVEL_3] = "LEVEL_3"
____exports.LibrarySubType.LEVEL_4 = 3
____exports.LibrarySubType[____exports.LibrarySubType.LEVEL_4] = "LEVEL_4"
____exports.LibrarySubType.LEVEL_5 = 4
____exports.LibrarySubType[____exports.LibrarySubType.LEVEL_5] = "LEVEL_5"
____exports.LibrarySubType.EXTRA_GOOD = 10
____exports.LibrarySubType[____exports.LibrarySubType.EXTRA_GOOD] = "EXTRA_GOOD"
____exports.LibrarySubType.EXTRA_BAD = 11
____exports.LibrarySubType[____exports.LibrarySubType.EXTRA_BAD] = "EXTRA_BAD"
____exports.LibrarySubType.TAINTED_KEEPER_LEVEL_1 = 100
____exports.LibrarySubType[____exports.LibrarySubType.TAINTED_KEEPER_LEVEL_1] = "TAINTED_KEEPER_LEVEL_1"
____exports.LibrarySubType.TAINTED_KEEPER_LEVEL_2 = 101
____exports.LibrarySubType[____exports.LibrarySubType.TAINTED_KEEPER_LEVEL_2] = "TAINTED_KEEPER_LEVEL_2"
____exports.LibrarySubType.TAINTED_KEEPER_LEVEL_3 = 102
____exports.LibrarySubType[____exports.LibrarySubType.TAINTED_KEEPER_LEVEL_3] = "TAINTED_KEEPER_LEVEL_3"
____exports.LibrarySubType.TAINTED_KEEPER_LEVEL_4 = 103
____exports.LibrarySubType[____exports.LibrarySubType.TAINTED_KEEPER_LEVEL_4] = "TAINTED_KEEPER_LEVEL_4"
____exports.LibrarySubType.TAINTED_KEEPER_LEVEL_5 = 104
____exports.LibrarySubType[____exports.LibrarySubType.TAINTED_KEEPER_LEVEL_5] = "TAINTED_KEEPER_LEVEL_5"
____exports.LibrarySubType.TAINTED_KEEPER_EXTRA_GOOD = 110
____exports.LibrarySubType[____exports.LibrarySubType.TAINTED_KEEPER_EXTRA_GOOD] = "TAINTED_KEEPER_EXTRA_GOOD"
____exports.LibrarySubType.TAINTED_KEEPER_EXTRA_BAD = 111
____exports.LibrarySubType[____exports.LibrarySubType.TAINTED_KEEPER_EXTRA_BAD] = "TAINTED_KEEPER_EXTRA_BAD"
--- For `StageID.SPECIAL_ROOMS` (0), `RoomType.DEVIL` (14).
-- 
-- This matches the sub-type in the "00.special rooms.stb" file.
____exports.DevilRoomSubType = {}
____exports.DevilRoomSubType.NORMAL = 0
____exports.DevilRoomSubType[____exports.DevilRoomSubType.NORMAL] = "NORMAL"
____exports.DevilRoomSubType.NUMBER_SIX_TRINKET = 1
____exports.DevilRoomSubType[____exports.DevilRoomSubType.NUMBER_SIX_TRINKET] = "NUMBER_SIX_TRINKET"
--- For `StageID.SPECIAL_ROOMS` (0), `RoomType.ANGEL` (15).
-- 
-- This matches the sub-type in the "00.special rooms.stb" file.
____exports.AngelRoomSubType = {}
____exports.AngelRoomSubType.NORMAL = 0
____exports.AngelRoomSubType[____exports.AngelRoomSubType.NORMAL] = "NORMAL"
____exports.AngelRoomSubType.SHOP = 1
____exports.AngelRoomSubType[____exports.AngelRoomSubType.SHOP] = "SHOP"
--- For `StageID.SPECIAL_ROOMS` (0), `RoomType.DUNGEON` (16).
-- 
-- This matches the sub-type in the "00.special rooms.stb" file and elsewhere.
____exports.DungeonSubType = {}
____exports.DungeonSubType.NORMAL = 0
____exports.DungeonSubType[____exports.DungeonSubType.NORMAL] = "NORMAL"
____exports.DungeonSubType.GIDEONS_GRAVE = 1
____exports.DungeonSubType[____exports.DungeonSubType.GIDEONS_GRAVE] = "GIDEONS_GRAVE"
____exports.DungeonSubType.ROTGUT_MAGGOT = 2
____exports.DungeonSubType[____exports.DungeonSubType.ROTGUT_MAGGOT] = "ROTGUT_MAGGOT"
____exports.DungeonSubType.ROTGUT_HEART = 3
____exports.DungeonSubType[____exports.DungeonSubType.ROTGUT_HEART] = "ROTGUT_HEART"
____exports.DungeonSubType.BEAST_ROOM = 4
____exports.DungeonSubType[____exports.DungeonSubType.BEAST_ROOM] = "BEAST_ROOM"
--- For `StageID.SPECIAL_ROOMS` (0), `RoomType.CLEAN_BEDROOM` (18).
-- 
-- This matches the sub-type in the "00.special rooms.stb" file.
____exports.IsaacsRoomSubType = {}
____exports.IsaacsRoomSubType.NORMAL = 0
____exports.IsaacsRoomSubType[____exports.IsaacsRoomSubType.NORMAL] = "NORMAL"
____exports.IsaacsRoomSubType.GENESIS = 99
____exports.IsaacsRoomSubType[____exports.IsaacsRoomSubType.GENESIS] = "GENESIS"
--- For `StageID.SPECIAL_ROOMS` (0), `RoomType.SECRET_EXIT` (27).
-- 
-- This matches the sub-type in the "00.special rooms.stb" file.
____exports.SecretExitSubType = {}
____exports.SecretExitSubType.DOWNPOUR = 1
____exports.SecretExitSubType[____exports.SecretExitSubType.DOWNPOUR] = "DOWNPOUR"
____exports.SecretExitSubType.MINES = 2
____exports.SecretExitSubType[____exports.SecretExitSubType.MINES] = "MINES"
____exports.SecretExitSubType.MAUSOLEUM = 3
____exports.SecretExitSubType[____exports.SecretExitSubType.MAUSOLEUM] = "MAUSOLEUM"
--- For `StageID.DOWNPOUR` (27) and `StageID.DROSS` (28), `RoomType.DEFAULT` (1).
-- 
-- This matches the sub-type in the "27.downpour.stb" and "28.dross.stb" files.
____exports.DownpourRoomSubType = {}
____exports.DownpourRoomSubType.NORMAL = 0
____exports.DownpourRoomSubType[____exports.DownpourRoomSubType.NORMAL] = "NORMAL"
____exports.DownpourRoomSubType.WHITE_FIRE = 1
____exports.DownpourRoomSubType[____exports.DownpourRoomSubType.WHITE_FIRE] = "WHITE_FIRE"
____exports.DownpourRoomSubType.MIRROR = 34
____exports.DownpourRoomSubType[____exports.DownpourRoomSubType.MIRROR] = "MIRROR"
--- For `StageID.MINES` (29) and `StageID.ASHPIT` (30), `RoomType.DEFAULT` (1).
-- 
-- This matches the sub-type in the "29.mines.stb" and "30.ashpit.stb" files.
____exports.MinesRoomSubType = {}
____exports.MinesRoomSubType.NORMAL = 0
____exports.MinesRoomSubType[____exports.MinesRoomSubType.NORMAL] = "NORMAL"
____exports.MinesRoomSubType.BUTTON_ROOM = 1
____exports.MinesRoomSubType[____exports.MinesRoomSubType.BUTTON_ROOM] = "BUTTON_ROOM"
____exports.MinesRoomSubType.MINESHAFT_ENTRANCE = 10
____exports.MinesRoomSubType[____exports.MinesRoomSubType.MINESHAFT_ENTRANCE] = "MINESHAFT_ENTRANCE"
____exports.MinesRoomSubType.MINESHAFT_LOBBY = 11
____exports.MinesRoomSubType[____exports.MinesRoomSubType.MINESHAFT_LOBBY] = "MINESHAFT_LOBBY"
____exports.MinesRoomSubType.MINESHAFT_KNIFE_PIECE = 20
____exports.MinesRoomSubType[____exports.MinesRoomSubType.MINESHAFT_KNIFE_PIECE] = "MINESHAFT_KNIFE_PIECE"
____exports.MinesRoomSubType.MINESHAFT_ROOM_PRE_CHASE = 30
____exports.MinesRoomSubType[____exports.MinesRoomSubType.MINESHAFT_ROOM_PRE_CHASE] = "MINESHAFT_ROOM_PRE_CHASE"
____exports.MinesRoomSubType.MINESHAFT_ROOM_POST_CHASE = 31
____exports.MinesRoomSubType[____exports.MinesRoomSubType.MINESHAFT_ROOM_POST_CHASE] = "MINESHAFT_ROOM_POST_CHASE"
--- For `StageID.HOME` (35), `RoomType.DEFAULT` (1).
-- 
-- This matches the sub-type in the "35.home.stb" file.
____exports.HomeRoomSubType = {}
____exports.HomeRoomSubType.ISAACS_BEDROOM = 0
____exports.HomeRoomSubType[____exports.HomeRoomSubType.ISAACS_BEDROOM] = "ISAACS_BEDROOM"
____exports.HomeRoomSubType.HALLWAY = 1
____exports.HomeRoomSubType[____exports.HomeRoomSubType.HALLWAY] = "HALLWAY"
____exports.HomeRoomSubType.MOMS_BEDROOM = 2
____exports.HomeRoomSubType[____exports.HomeRoomSubType.MOMS_BEDROOM] = "MOMS_BEDROOM"
____exports.HomeRoomSubType.LIVING_ROOM = 3
____exports.HomeRoomSubType[____exports.HomeRoomSubType.LIVING_ROOM] = "LIVING_ROOM"
____exports.HomeRoomSubType.CLOSET_RIGHT = 10
____exports.HomeRoomSubType[____exports.HomeRoomSubType.CLOSET_RIGHT] = "CLOSET_RIGHT"
____exports.HomeRoomSubType.CLOSET_LEFT = 11
____exports.HomeRoomSubType[____exports.HomeRoomSubType.CLOSET_LEFT] = "CLOSET_LEFT"
____exports.HomeRoomSubType.DEATH_CERTIFICATE_ENTRANCE = 33
____exports.HomeRoomSubType[____exports.HomeRoomSubType.DEATH_CERTIFICATE_ENTRANCE] = "DEATH_CERTIFICATE_ENTRANCE"
____exports.HomeRoomSubType.DEATH_CERTIFICATE_ITEMS = 34
____exports.HomeRoomSubType[____exports.HomeRoomSubType.DEATH_CERTIFICATE_ITEMS] = "DEATH_CERTIFICATE_ITEMS"
--- For `StageID.BACKWARDS` (36), `RoomType.DEFAULT` (1).
-- 
-- This matches the sub-type in the "36.backwards.stb" file.
____exports.BackwardsRoomSubType = {}
____exports.BackwardsRoomSubType.EXIT = 0
____exports.BackwardsRoomSubType[____exports.BackwardsRoomSubType.EXIT] = "EXIT"
____exports.BackwardsRoomSubType.BASEMENT = 1
____exports.BackwardsRoomSubType[____exports.BackwardsRoomSubType.BASEMENT] = "BASEMENT"
____exports.BackwardsRoomSubType.CAVES = 4
____exports.BackwardsRoomSubType[____exports.BackwardsRoomSubType.CAVES] = "CAVES"
____exports.BackwardsRoomSubType.DEPTHS = 7
____exports.BackwardsRoomSubType[____exports.BackwardsRoomSubType.DEPTHS] = "DEPTHS"
____exports.BackwardsRoomSubType.DOWNPOUR = 27
____exports.BackwardsRoomSubType[____exports.BackwardsRoomSubType.DOWNPOUR] = "DOWNPOUR"
____exports.BackwardsRoomSubType.MINES = 29
____exports.BackwardsRoomSubType[____exports.BackwardsRoomSubType.MINES] = "MINES"
____exports.BackwardsRoomSubType.MAUSOLEUM = 31
____exports.BackwardsRoomSubType[____exports.BackwardsRoomSubType.MAUSOLEUM] = "MAUSOLEUM"
return ____exports
