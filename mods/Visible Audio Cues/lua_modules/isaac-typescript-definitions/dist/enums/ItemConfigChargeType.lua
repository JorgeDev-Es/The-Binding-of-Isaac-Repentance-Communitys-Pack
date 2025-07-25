local ____exports = {}
--- Matches the `ItemConfig.CHARGE_` members of the `ItemConfig` class. In IsaacScript, we
-- reimplement this as an enum instead, since it is cleaner.
____exports.ItemConfigChargeType = {}
____exports.ItemConfigChargeType.NORMAL = 0
____exports.ItemConfigChargeType[____exports.ItemConfigChargeType.NORMAL] = "NORMAL"
____exports.ItemConfigChargeType.TIMED = 1
____exports.ItemConfigChargeType[____exports.ItemConfigChargeType.TIMED] = "TIMED"
____exports.ItemConfigChargeType.SPECIAL = 2
____exports.ItemConfigChargeType[____exports.ItemConfigChargeType.SPECIAL] = "SPECIAL"
return ____exports
