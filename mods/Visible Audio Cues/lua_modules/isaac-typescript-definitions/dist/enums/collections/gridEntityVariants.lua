local ____exports = {}
--- For `GridEntityType.ROCK` (2).
-- 
-- Note that this does not always apply to `GridEntityRock`, since that class can be equal to other
-- grid entity types.
____exports.RockVariant = {}
____exports.RockVariant.NORMAL = 0
____exports.RockVariant[____exports.RockVariant.NORMAL] = "NORMAL"
____exports.RockVariant.EVENT = 1
____exports.RockVariant[____exports.RockVariant.EVENT] = "EVENT"
--- For GridEntityType.ROCK_ALT (6), RockAltType.URN.
-- 
-- Note that you are unable to spawn specific urn variants. The game will pick a random variant
-- regardless of which one you select.
____exports.UrnVariant = {}
____exports.UrnVariant.NORMAL = 0
____exports.UrnVariant[____exports.UrnVariant.NORMAL] = "NORMAL"
____exports.UrnVariant.CHIPPED_TOP_LEFT = 1
____exports.UrnVariant[____exports.UrnVariant.CHIPPED_TOP_LEFT] = "CHIPPED_TOP_LEFT"
____exports.UrnVariant.NARROW = 2
____exports.UrnVariant[____exports.UrnVariant.NARROW] = "NARROW"
--- For GridEntityType.ROCK_ALT (6), RockAltType.MUSHROOM.
-- 
-- Note that you are unable to spawn specific mushroom variants. The game will pick a random variant
-- regardless of which one you select.
____exports.MushroomVariant = {}
____exports.MushroomVariant.NORMAL = 0
____exports.MushroomVariant[____exports.MushroomVariant.NORMAL] = "NORMAL"
____exports.MushroomVariant.CHIPPED_TOP_RIGHT = 1
____exports.MushroomVariant[____exports.MushroomVariant.CHIPPED_TOP_RIGHT] = "CHIPPED_TOP_RIGHT"
____exports.MushroomVariant.NARROW = 2
____exports.MushroomVariant[____exports.MushroomVariant.NARROW] = "NARROW"
--- For GridEntityType.ROCK_ALT (6), RockAltType.SKULL.
-- 
-- Note that you are unable to spawn specific skull variants. The game will pick a random variant
-- regardless of which one you select.
____exports.SkullVariant = {}
____exports.SkullVariant.NORMAL = 0
____exports.SkullVariant[____exports.SkullVariant.NORMAL] = "NORMAL"
____exports.SkullVariant.FACING_RIGHT = 1
____exports.SkullVariant[____exports.SkullVariant.FACING_RIGHT] = "FACING_RIGHT"
____exports.SkullVariant.FACING_LEFT = 2
____exports.SkullVariant[____exports.SkullVariant.FACING_LEFT] = "FACING_LEFT"
--- For GridEntityType.ROCK_ALT (6), RockAltType.POLYP.
-- 
-- Note that you are unable to spawn specific polyp variants. The game will pick a random variant
-- regardless of which one you select.
____exports.PolypVariant = {}
____exports.PolypVariant.NORMAL = 0
____exports.PolypVariant[____exports.PolypVariant.NORMAL] = "NORMAL"
____exports.PolypVariant.MANY_FINGERS = 1
____exports.PolypVariant[____exports.PolypVariant.MANY_FINGERS] = "MANY_FINGERS"
____exports.PolypVariant.FLIPPED_AND_SHIFTED_UPWARDS = 2
____exports.PolypVariant[____exports.PolypVariant.FLIPPED_AND_SHIFTED_UPWARDS] = "FLIPPED_AND_SHIFTED_UPWARDS"
--- For GridEntityType.ROCK_ALT (6), RockAltType.BUCKET.
-- 
-- Note that you are unable to spawn specific bucket variants. The game will pick a random variant
-- regardless of which one you select.
____exports.BucketVariant = {}
____exports.BucketVariant.EMPTY = 0
____exports.BucketVariant[____exports.BucketVariant.EMPTY] = "EMPTY"
____exports.BucketVariant.FULL = 1
____exports.BucketVariant[____exports.BucketVariant.FULL] = "FULL"
____exports.BucketVariant.EMPTY_AND_SHIFTED_UPWARDS = 2
____exports.BucketVariant[____exports.BucketVariant.EMPTY_AND_SHIFTED_UPWARDS] = "EMPTY_AND_SHIFTED_UPWARDS"
--- For `GridEntityType.PIT` (7).
____exports.PitVariant = {}
____exports.PitVariant.NORMAL = 0
____exports.PitVariant[____exports.PitVariant.NORMAL] = "NORMAL"
____exports.PitVariant.FISSURE_SPAWNER = 16
____exports.PitVariant[____exports.PitVariant.FISSURE_SPAWNER] = "FISSURE_SPAWNER"
--- For `GridEntityType.FIREPLACE` (13).
-- 
-- This only partially corresponds to the `FireplaceVariant` for non-grid entities. (Spawning a grid
-- entity fireplace with a variant higher than 1 will result in a normal fireplace.)
____exports.FireplaceGridEntityVariant = {}
____exports.FireplaceGridEntityVariant.NORMAL = 0
____exports.FireplaceGridEntityVariant[____exports.FireplaceGridEntityVariant.NORMAL] = "NORMAL"
____exports.FireplaceGridEntityVariant.RED = 1
____exports.FireplaceGridEntityVariant[____exports.FireplaceGridEntityVariant.RED] = "RED"
--- For `GridEntityType.POOP` (14).
____exports.PoopGridEntityVariant = {}
____exports.PoopGridEntityVariant.NORMAL = 0
____exports.PoopGridEntityVariant[____exports.PoopGridEntityVariant.NORMAL] = "NORMAL"
____exports.PoopGridEntityVariant.RED = 1
____exports.PoopGridEntityVariant[____exports.PoopGridEntityVariant.RED] = "RED"
____exports.PoopGridEntityVariant.CORNY = 2
____exports.PoopGridEntityVariant[____exports.PoopGridEntityVariant.CORNY] = "CORNY"
____exports.PoopGridEntityVariant.GOLDEN = 3
____exports.PoopGridEntityVariant[____exports.PoopGridEntityVariant.GOLDEN] = "GOLDEN"
____exports.PoopGridEntityVariant.RAINBOW = 4
____exports.PoopGridEntityVariant[____exports.PoopGridEntityVariant.RAINBOW] = "RAINBOW"
____exports.PoopGridEntityVariant.BLACK = 5
____exports.PoopGridEntityVariant[____exports.PoopGridEntityVariant.BLACK] = "BLACK"
____exports.PoopGridEntityVariant.WHITE = 6
____exports.PoopGridEntityVariant[____exports.PoopGridEntityVariant.WHITE] = "WHITE"
____exports.PoopGridEntityVariant.GIANT_TOP_LEFT = 7
____exports.PoopGridEntityVariant[____exports.PoopGridEntityVariant.GIANT_TOP_LEFT] = "GIANT_TOP_LEFT"
____exports.PoopGridEntityVariant.GIANT_TOP_RIGHT = 8
____exports.PoopGridEntityVariant[____exports.PoopGridEntityVariant.GIANT_TOP_RIGHT] = "GIANT_TOP_RIGHT"
____exports.PoopGridEntityVariant.GIANT_BOTTOM_LEFT = 9
____exports.PoopGridEntityVariant[____exports.PoopGridEntityVariant.GIANT_BOTTOM_LEFT] = "GIANT_BOTTOM_LEFT"
____exports.PoopGridEntityVariant.GIANT_BOTTOM_RIGHT = 10
____exports.PoopGridEntityVariant[____exports.PoopGridEntityVariant.GIANT_BOTTOM_RIGHT] = "GIANT_BOTTOM_RIGHT"
____exports.PoopGridEntityVariant.CHARMING = 11
____exports.PoopGridEntityVariant[____exports.PoopGridEntityVariant.CHARMING] = "CHARMING"
--- For `GridEntityType.DOOR` (16).
____exports.DoorVariant = {}
____exports.DoorVariant.UNSPECIFIED = 0
____exports.DoorVariant[____exports.DoorVariant.UNSPECIFIED] = "UNSPECIFIED"
____exports.DoorVariant.LOCKED = 1
____exports.DoorVariant[____exports.DoorVariant.LOCKED] = "LOCKED"
____exports.DoorVariant.LOCKED_DOUBLE = 2
____exports.DoorVariant[____exports.DoorVariant.LOCKED_DOUBLE] = "LOCKED_DOUBLE"
____exports.DoorVariant.LOCKED_CRACKED = 3
____exports.DoorVariant[____exports.DoorVariant.LOCKED_CRACKED] = "LOCKED_CRACKED"
____exports.DoorVariant.LOCKED_BARRED = 4
____exports.DoorVariant[____exports.DoorVariant.LOCKED_BARRED] = "LOCKED_BARRED"
____exports.DoorVariant.LOCKED_KEY_FAMILIAR = 5
____exports.DoorVariant[____exports.DoorVariant.LOCKED_KEY_FAMILIAR] = "LOCKED_KEY_FAMILIAR"
____exports.DoorVariant.LOCKED_GREED = 6
____exports.DoorVariant[____exports.DoorVariant.LOCKED_GREED] = "LOCKED_GREED"
____exports.DoorVariant.HIDDEN = 7
____exports.DoorVariant[____exports.DoorVariant.HIDDEN] = "HIDDEN"
____exports.DoorVariant.UNLOCKED = 8
____exports.DoorVariant[____exports.DoorVariant.UNLOCKED] = "UNLOCKED"
--- For `GridEntityType.TRAPDOOR` (17).
____exports.TrapdoorVariant = {}
____exports.TrapdoorVariant.NORMAL = 0
____exports.TrapdoorVariant[____exports.TrapdoorVariant.NORMAL] = "NORMAL"
____exports.TrapdoorVariant.VOID_PORTAL = 1
____exports.TrapdoorVariant[____exports.TrapdoorVariant.VOID_PORTAL] = "VOID_PORTAL"
--- For `GridEntityType.CRAWL_SPACE` (18).
____exports.CrawlSpaceVariant = {}
____exports.CrawlSpaceVariant.NORMAL = 0
____exports.CrawlSpaceVariant[____exports.CrawlSpaceVariant.NORMAL] = "NORMAL"
____exports.CrawlSpaceVariant.GREAT_GIDEON = 1
____exports.CrawlSpaceVariant[____exports.CrawlSpaceVariant.GREAT_GIDEON] = "GREAT_GIDEON"
____exports.CrawlSpaceVariant.SECRET_SHOP = 2
____exports.CrawlSpaceVariant[____exports.CrawlSpaceVariant.SECRET_SHOP] = "SECRET_SHOP"
____exports.CrawlSpaceVariant.PASSAGE_TO_BEGINNING_OF_FLOOR = 3
____exports.CrawlSpaceVariant[____exports.CrawlSpaceVariant.PASSAGE_TO_BEGINNING_OF_FLOOR] = "PASSAGE_TO_BEGINNING_OF_FLOOR"
____exports.CrawlSpaceVariant.NULL = 4
____exports.CrawlSpaceVariant[____exports.CrawlSpaceVariant.NULL] = "NULL"
--- For `GridEntityType.PRESSURE_PLATE` (20).
____exports.PressurePlateVariant = {}
____exports.PressurePlateVariant.PRESSURE_PLATE = 0
____exports.PressurePlateVariant[____exports.PressurePlateVariant.PRESSURE_PLATE] = "PRESSURE_PLATE"
____exports.PressurePlateVariant.REWARD_PLATE = 1
____exports.PressurePlateVariant[____exports.PressurePlateVariant.REWARD_PLATE] = "REWARD_PLATE"
____exports.PressurePlateVariant.GREED_PLATE = 2
____exports.PressurePlateVariant[____exports.PressurePlateVariant.GREED_PLATE] = "GREED_PLATE"
____exports.PressurePlateVariant.RAIL_PLATE = 3
____exports.PressurePlateVariant[____exports.PressurePlateVariant.RAIL_PLATE] = "RAIL_PLATE"
____exports.PressurePlateVariant.KILL_ALL_ENEMIES_PLATE = 9
____exports.PressurePlateVariant[____exports.PressurePlateVariant.KILL_ALL_ENEMIES_PLATE] = "KILL_ALL_ENEMIES_PLATE"
____exports.PressurePlateVariant.SPAWN_ROCKS_PLATE = 10
____exports.PressurePlateVariant[____exports.PressurePlateVariant.SPAWN_ROCKS_PLATE] = "SPAWN_ROCKS_PLATE"
--- For `GridEntityType.STATUE` (21).
____exports.StatueVariant = {}
____exports.StatueVariant.DEVIL = 0
____exports.StatueVariant[____exports.StatueVariant.DEVIL] = "DEVIL"
____exports.StatueVariant.ANGEL = 1
____exports.StatueVariant[____exports.StatueVariant.ANGEL] = "ANGEL"
return ____exports
