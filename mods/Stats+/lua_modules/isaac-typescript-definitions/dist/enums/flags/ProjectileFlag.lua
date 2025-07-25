local ____exports = {}
--- For `EntityType.PROJECTILE` (9).
-- 
-- This enum was renamed from "ProjectileFlags" to be consistent with the other flag enums.
-- 
-- This is represented as an object instead of an enum due to limitations with TypeScript enums. (We
-- want this type to be a child of the `BitFlag` type.)
-- 
-- @enum
-- @notExported
-- @rename ProjectileFlag
local ProjectileFlagInternal = {
    SMART = 1 << 0,
    EXPLODE = 1 << 1,
    ACID_GREEN = 1 << 2,
    GOO = 1 << 3,
    GHOST = 1 << 4,
    WIGGLE = 1 << 5,
    BOOMERANG = 1 << 6,
    HIT_ENEMIES = 1 << 7,
    ACID_RED = 1 << 8,
    GREED = 1 << 9,
    RED_CREEP = 1 << 10,
    ORBIT_CW = 1 << 11,
    ORBIT_CCW = 1 << 12,
    NO_WALL_COLLIDE = 1 << 13,
    CREEP_BROWN = 1 << 14,
    FIRE = 1 << 15,
    BURST = 1 << 16,
    ANY_HEIGHT_ENTITY_HIT = 1 << 17,
    CURVE_LEFT = 1 << 18,
    CURVE_RIGHT = 1 << 19,
    TURN_HORIZONTAL = 1 << 20,
    SINE_VELOCITY = 1 << 21,
    MEGA_WIGGLE = 1 << 22,
    SAWTOOTH_WIGGLE = 1 << 23,
    SLOWED = 1 << 24,
    TRIANGLE = 1 << 25,
    MOVE_TO_PARENT = 1 << 26,
    ACCELERATE = 1 << 27,
    DECELERATE = 1 << 28,
    BURST3 = 1 << 29,
    CONTINUUM = 1 << 30,
    CANT_HIT_PLAYER = 1 << 31,
    CHANGE_FLAGS_AFTER_TIMEOUT = 1 << 32,
    CHANGE_VELOCITY_AFTER_TIMEOUT = 1 << 33,
    STASIS = 1 << 34,
    FIRE_WAVE = 1 << 35,
    FIRE_WAVE_X = 1 << 36,
    ACCELERATE_EX = 1 << 37,
    BURST8 = 1 << 38,
    FIRE_SPAWN = 1 << 39,
    ANTI_GRAVITY = 1 << 40,
    TRACTOR_BEAM = 1 << 41,
    BOUNCE = 1 << 42,
    BOUNCE_FLOOR = 1 << 43,
    SHIELDED = 1 << 44,
    BLUE_FIRE_SPAWN = 1 << 45,
    LASER_SHOT = 1 << 46,
    GODHEAD = 1 << 47,
    SMART_PERFECT = 1 << 48,
    BURST_SPLIT = 1 << 49,
    WIGGLE_ROTGUT = 1 << 50,
    FREEZE = 1 << 51,
    ACCELERATE_TO_POSITION = 1 << 52,
    BROCCOLI = 1 << 53,
    BACK_SPLIT = 1 << 54,
    SIDE_WAVE = 1 << 55,
    ORBIT_PARENT = 1 << 56,
    FADEOUT = 1 << 57
}
____exports.ProjectileFlag = ProjectileFlagInternal
____exports.ProjectileFlagZero = 0
return ____exports
