local ____exports = {}
local getTearFlag
function getTearFlag(self, shift)
    return shift >= 64 and BitSet128(0, 1 << shift - 64) or BitSet128(1 << shift, 0)
end
--- For `EntityType.TEAR` (2).
-- 
-- This enum was renamed from "TearFlags" to be consistent with the other flag enums.
-- 
-- This is represented as an object instead of an enum due to limitations with TypeScript enums. (We
-- want this type to be a child of the `BitFlag` type. Furthermore, enums cannot be instantiated
-- with `BitSet128` objects.)
-- 
-- Generally, the `TearVariant` affects the graphics of the tear, while the `TearFlag` affects the
-- gameplay mechanic. For example, the Euthanasia collectible grants a chance for needle tears that
-- explode. `TearVariant.NEEDLE` makes the tear look like a needle, and the exploding effect comes
-- from `TearFlag.NEEDLE`.
-- 
-- However, there are some exceptions. For example, Sharp Key makes Isaac shoot key tears that deal
-- extra damage. Both the graphical effect and the extra damage are granted by
-- `TearVariant.KEY_BLOOD`.
-- 
-- @enum
-- @notExported
-- @rename TearFlag
local TearFlagInternal = {
    NORMAL = BitSet128(0, 0),
    SPECTRAL = getTearFlag(nil, 0),
    PIERCING = getTearFlag(nil, 1),
    HOMING = getTearFlag(nil, 2),
    SLOW = getTearFlag(nil, 3),
    POISON = getTearFlag(nil, 4),
    FREEZE = getTearFlag(nil, 5),
    SPLIT = getTearFlag(nil, 6),
    GROW = getTearFlag(nil, 7),
    BOOMERANG = getTearFlag(nil, 8),
    PERSISTENT = getTearFlag(nil, 9),
    WIGGLE = getTearFlag(nil, 10),
    MULLIGAN = getTearFlag(nil, 11),
    EXPLOSIVE = getTearFlag(nil, 12),
    CHARM = getTearFlag(nil, 13),
    CONFUSION = getTearFlag(nil, 14),
    HP_DROP = getTearFlag(nil, 15),
    ORBIT = getTearFlag(nil, 16),
    WAIT = getTearFlag(nil, 17),
    QUAD_SPLIT = getTearFlag(nil, 18),
    BOUNCE = getTearFlag(nil, 19),
    FEAR = getTearFlag(nil, 20),
    SHRINK = getTearFlag(nil, 21),
    BURN = getTearFlag(nil, 22),
    ATTRACTOR = getTearFlag(nil, 23),
    KNOCKBACK = getTearFlag(nil, 24),
    PULSE = getTearFlag(nil, 25),
    SPIRAL = getTearFlag(nil, 26),
    FLAT = getTearFlag(nil, 27),
    SAD_BOMB = getTearFlag(nil, 28),
    BUTT_BOMB = getTearFlag(nil, 29),
    SQUARE = getTearFlag(nil, 30),
    GLOW = getTearFlag(nil, 31),
    GISH = getTearFlag(nil, 32),
    MYSTERIOUS_LIQUID_CREEP = getTearFlag(nil, 33),
    SHIELDED = getTearFlag(nil, 34),
    GLITTER_BOMB = getTearFlag(nil, 35),
    SCATTER_BOMB = getTearFlag(nil, 36),
    STICKY = getTearFlag(nil, 37),
    CONTINUUM = getTearFlag(nil, 38),
    LIGHT_FROM_HEAVEN = getTearFlag(nil, 39),
    COIN_DROP = getTearFlag(nil, 40),
    BLACK_HP_DROP = getTearFlag(nil, 41),
    TRACTOR_BEAM = getTearFlag(nil, 42),
    GODS_FLESH = getTearFlag(nil, 43),
    GREED_COIN = getTearFlag(nil, 44),
    CROSS_BOMB = getTearFlag(nil, 45),
    BIG_SPIRAL = getTearFlag(nil, 46),
    PERMANENT_CONFUSION = getTearFlag(nil, 47),
    BOOGER = getTearFlag(nil, 48),
    EGG = getTearFlag(nil, 49),
    ACID = getTearFlag(nil, 50),
    BONE = getTearFlag(nil, 51),
    BELIAL = getTearFlag(nil, 52),
    MIDAS = getTearFlag(nil, 53),
    NEEDLE = getTearFlag(nil, 54),
    JACOBS = getTearFlag(nil, 55),
    HORN = getTearFlag(nil, 56),
    LASER = getTearFlag(nil, 57),
    POP = getTearFlag(nil, 58),
    ABSORB = getTearFlag(nil, 59),
    LASER_SHOT = getTearFlag(nil, 60),
    HYDRO_BOUNCE = getTearFlag(nil, 61),
    BURST_SPLIT = getTearFlag(nil, 62),
    CREEP_TRAIL = getTearFlag(nil, 63),
    PUNCH = getTearFlag(nil, 64),
    ICE = getTearFlag(nil, 65),
    MAGNETIZE = getTearFlag(nil, 66),
    BAIT = getTearFlag(nil, 67),
    OCCULT = getTearFlag(nil, 68),
    ORBIT_ADVANCED = getTearFlag(nil, 69),
    ROCK = getTearFlag(nil, 70),
    TURN_HORIZONTAL = getTearFlag(nil, 71),
    BLOOD_BOMB = getTearFlag(nil, 72),
    ECOLI = getTearFlag(nil, 73),
    COIN_DROP_DEATH = getTearFlag(nil, 74),
    BRIMSTONE_BOMB = getTearFlag(nil, 75),
    RIFT = getTearFlag(nil, 76),
    SPORE = getTearFlag(nil, 77),
    GHOST_BOMB = getTearFlag(nil, 78),
    CARD_DROP_DEATH = getTearFlag(nil, 79),
    RUNE_DROP_DEATH = getTearFlag(nil, 80),
    TELEPORT = getTearFlag(nil, 81),
    TEAR_DECELERATE = getTearFlag(nil, 82),
    TEAR_ACCELERATE = getTearFlag(nil, 83),
    BOUNCE_WALLS_ONLY = getTearFlag(nil, 104),
    NO_GRID_DAMAGE = getTearFlag(nil, 105),
    BACKSTAB = getTearFlag(nil, 106),
    FETUS_SWORD = getTearFlag(nil, 107),
    FETUS_BONE = getTearFlag(nil, 108),
    FETUS_KNIFE = getTearFlag(nil, 109),
    FETUS_TECH_X = getTearFlag(nil, 110),
    FETUS_TECH = getTearFlag(nil, 111),
    FETUS_BRIMSTONE = getTearFlag(nil, 112),
    FETUS_BOMBER = getTearFlag(nil, 113),
    FETUS = getTearFlag(nil, 114),
    REROLL_ROCK_WISP = getTearFlag(nil, 115),
    MOM_STOMP_WISP = getTearFlag(nil, 116),
    ENEMY_TO_WISP = getTearFlag(nil, 117),
    REROLL_ENEMY = getTearFlag(nil, 118),
    GIGA_BOMB = getTearFlag(nil, 119),
    EXTRA_GORE = getTearFlag(nil, 120),
    RAINBOW = getTearFlag(nil, 121),
    DETONATE = getTearFlag(nil, 122),
    CHAIN = getTearFlag(nil, 123),
    DARK_MATTER = getTearFlag(nil, 124),
    GOLDEN_BOMB = getTearFlag(nil, 125),
    FAST_BOMB = getTearFlag(nil, 126),
    LUDOVICO = getTearFlag(nil, 127)
}
____exports.TearFlag = TearFlagInternal
____exports.TearFlagZero = ____exports.TearFlag.NORMAL
return ____exports
