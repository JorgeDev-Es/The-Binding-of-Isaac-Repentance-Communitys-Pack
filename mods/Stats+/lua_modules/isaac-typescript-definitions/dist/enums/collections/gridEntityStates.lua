local ____exports = {}
--- Used by the following grid entity types:
-- - GridEntityType.ROCK (2)
-- - GridEntityType.ROCK_TINTED (4)
-- - GridEntityType.ROCK_BOMB (5)
-- - GridEntityType.ROCK_ALT (6)
-- - GridEntityType.STATUE (21) (only for Angel Statues)
-- - GridEntityType.ROCK_SS (22)
-- - GridEntityType.ROCK_SPIKED (25)
-- - GridEntityType.ROCK_ALT2 (26)
-- - GridEntityType.ROCK_GOLD (27)
____exports.RockState = {}
____exports.RockState.UNBROKEN = 1
____exports.RockState[____exports.RockState.UNBROKEN] = "UNBROKEN"
____exports.RockState.BROKEN = 2
____exports.RockState[____exports.RockState.BROKEN] = "BROKEN"
____exports.RockState.EXPLODING = 3
____exports.RockState[____exports.RockState.EXPLODING] = "EXPLODING"
____exports.RockState.HALF_BROKEN = 4
____exports.RockState[____exports.RockState.HALF_BROKEN] = "HALF_BROKEN"
--- For `GridEntityType.PIT` (7).
____exports.PitState = {}
____exports.PitState.NORMAL = 0
____exports.PitState[____exports.PitState.NORMAL] = "NORMAL"
____exports.PitState.FILLED = 1
____exports.PitState[____exports.PitState.FILLED] = "FILLED"
--- For `GridEntityType.SPIKES_ON_OFF` (9).
____exports.SpikesOnOffState = {}
____exports.SpikesOnOffState.ON = 0
____exports.SpikesOnOffState[____exports.SpikesOnOffState.ON] = "ON"
____exports.SpikesOnOffState.OFF = 1
____exports.SpikesOnOffState[____exports.SpikesOnOffState.OFF] = "OFF"
--- For `GridEntityType.SPIDERWEB` (10).
____exports.SpiderWebState = {}
____exports.SpiderWebState.UNBROKEN = 0
____exports.SpiderWebState[____exports.SpiderWebState.UNBROKEN] = "UNBROKEN"
____exports.SpiderWebState.BROKEN = 1
____exports.SpiderWebState[____exports.SpiderWebState.BROKEN] = "BROKEN"
--- For `GridEntityType.LOCK` (11).
____exports.LockState = {}
____exports.LockState.LOCKED = 0
____exports.LockState[____exports.LockState.LOCKED] = "LOCKED"
____exports.LockState.UNLOCKED = 1
____exports.LockState[____exports.LockState.UNLOCKED] = "UNLOCKED"
--- For `GridEntityType.TNT` (12).
-- 
-- The health of a TNT barrel is represented by its state. It starts at 0 and climbs upwards in
-- increments of 1. Once the state reaches 4, the barrel explodes, and remains at state 4.
-- 
-- Breaking a TNT barrel usually takes 4 tears. However, it is possible to take less than that if
-- the players damage is high enough. (High damage causes the tear to do two or more increments at
-- once.)
____exports.TNTState = {}
____exports.TNTState.UNDAMAGED = 0
____exports.TNTState[____exports.TNTState.UNDAMAGED] = "UNDAMAGED"
____exports.TNTState.ONE_QUARTER_DAMAGED = 1
____exports.TNTState[____exports.TNTState.ONE_QUARTER_DAMAGED] = "ONE_QUARTER_DAMAGED"
____exports.TNTState.TWO_QUARTERS_DAMAGED = 2
____exports.TNTState[____exports.TNTState.TWO_QUARTERS_DAMAGED] = "TWO_QUARTERS_DAMAGED"
____exports.TNTState.THREE_QUARTERS_DAMAGED = 3
____exports.TNTState[____exports.TNTState.THREE_QUARTERS_DAMAGED] = "THREE_QUARTERS_DAMAGED"
____exports.TNTState.EXPLODED = 4
____exports.TNTState[____exports.TNTState.EXPLODED] = "EXPLODED"
--- For `GridEntityType.POOP` (14).
-- 
-- The health of a poop is represented by its state. It starts at 0 and climbs upwards in increments
-- of 250. Once the state reaches 1000, the poop is completely broken.
-- 
-- Breaking a poop usually takes 4 tears. However, it is possible to take less than that if the
-- players damage is high enough. (High damage causes the tear to do two or more increments at
-- once.)
-- 
-- Giga Poops increment by 20 instead of 250. Thus, they take around 50 tears to destroy.
____exports.PoopState = {}
____exports.PoopState.UNDAMAGED = 0
____exports.PoopState[____exports.PoopState.UNDAMAGED] = "UNDAMAGED"
____exports.PoopState.ONE_QUARTER_DAMAGED = 250
____exports.PoopState[____exports.PoopState.ONE_QUARTER_DAMAGED] = "ONE_QUARTER_DAMAGED"
____exports.PoopState.TWO_QUARTERS_DAMAGED = 500
____exports.PoopState[____exports.PoopState.TWO_QUARTERS_DAMAGED] = "TWO_QUARTERS_DAMAGED"
____exports.PoopState.THREE_QUARTERS_DAMAGED = 750
____exports.PoopState[____exports.PoopState.THREE_QUARTERS_DAMAGED] = "THREE_QUARTERS_DAMAGED"
____exports.PoopState.COMPLETELY_DESTROYED = 1000
____exports.PoopState[____exports.PoopState.COMPLETELY_DESTROYED] = "COMPLETELY_DESTROYED"
--- For `GridEntityType.DOOR` (16).
____exports.DoorState = {}
____exports.DoorState.INIT = 0
____exports.DoorState[____exports.DoorState.INIT] = "INIT"
____exports.DoorState.CLOSED = 1
____exports.DoorState[____exports.DoorState.CLOSED] = "CLOSED"
____exports.DoorState.OPEN = 2
____exports.DoorState[____exports.DoorState.OPEN] = "OPEN"
____exports.DoorState.ONE_CHAIN = 3
____exports.DoorState[____exports.DoorState.ONE_CHAIN] = "ONE_CHAIN"
____exports.DoorState.HALF_CRACKED = 4
____exports.DoorState[____exports.DoorState.HALF_CRACKED] = "HALF_CRACKED"
--- For `GridEntityType.TRAPDOOR` (17).
____exports.TrapdoorState = {}
____exports.TrapdoorState.CLOSED = 0
____exports.TrapdoorState[____exports.TrapdoorState.CLOSED] = "CLOSED"
____exports.TrapdoorState.OPEN = 1
____exports.TrapdoorState[____exports.TrapdoorState.OPEN] = "OPEN"
--- For `GridEntityType.CRAWL_SPACE` (18).
____exports.CrawlSpaceState = {}
____exports.CrawlSpaceState.CLOSED = 0
____exports.CrawlSpaceState[____exports.CrawlSpaceState.CLOSED] = "CLOSED"
____exports.CrawlSpaceState.OPEN = 1
____exports.CrawlSpaceState[____exports.CrawlSpaceState.OPEN] = "OPEN"
--- For `GridEntityType.PRESSURE_PLATE` (20).
____exports.PressurePlateState = {}
____exports.PressurePlateState.UNPRESSED = 0
____exports.PressurePlateState[____exports.PressurePlateState.UNPRESSED] = "UNPRESSED"
____exports.PressurePlateState.STATE_1_UNKNOWN = 1
____exports.PressurePlateState[____exports.PressurePlateState.STATE_1_UNKNOWN] = "STATE_1_UNKNOWN"
____exports.PressurePlateState.STATE_2_UNKNOWN = 2
____exports.PressurePlateState[____exports.PressurePlateState.STATE_2_UNKNOWN] = "STATE_2_UNKNOWN"
____exports.PressurePlateState.PRESSURE_PLATE_PRESSED = 3
____exports.PressurePlateState[____exports.PressurePlateState.PRESSURE_PLATE_PRESSED] = "PRESSURE_PLATE_PRESSED"
____exports.PressurePlateState.REWARD_PLATE_PRESSED = 4
____exports.PressurePlateState[____exports.PressurePlateState.REWARD_PLATE_PRESSED] = "REWARD_PLATE_PRESSED"
--- For `GridEntityType.TELEPORTER` (23).
____exports.TeleporterState = {}
____exports.TeleporterState.NORMAL = 0
____exports.TeleporterState[____exports.TeleporterState.NORMAL] = "NORMAL"
____exports.TeleporterState.ACTIVATED = 1
____exports.TeleporterState[____exports.TeleporterState.ACTIVATED] = "ACTIVATED"
____exports.TeleporterState.DISABLED = 2
____exports.TeleporterState[____exports.TeleporterState.DISABLED] = "DISABLED"
return ____exports
