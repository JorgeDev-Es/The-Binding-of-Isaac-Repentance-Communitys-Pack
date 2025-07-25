local ____exports = {}
--- Corresponds to the "type" attribute in the "pocketitems.xml" file.
-- 
-- Matches the `ItemConfig.CARDTYPE_` members of the `ItemConfig` class. In IsaacScript, we
-- reimplement this as an enum instead, since it is cleaner.
-- 
-- Note that this enum is not to be confused with the `CardType` enum; the latter denotes the
-- in-game sub-type of the card, which is completely different.
____exports.ItemConfigCardType = {}
____exports.ItemConfigCardType.NULL = -1
____exports.ItemConfigCardType[____exports.ItemConfigCardType.NULL] = "NULL"
____exports.ItemConfigCardType.TAROT = 0
____exports.ItemConfigCardType[____exports.ItemConfigCardType.TAROT] = "TAROT"
____exports.ItemConfigCardType.SUIT = 1
____exports.ItemConfigCardType[____exports.ItemConfigCardType.SUIT] = "SUIT"
____exports.ItemConfigCardType.RUNE = 2
____exports.ItemConfigCardType[____exports.ItemConfigCardType.RUNE] = "RUNE"
____exports.ItemConfigCardType.SPECIAL = 3
____exports.ItemConfigCardType[____exports.ItemConfigCardType.SPECIAL] = "SPECIAL"
____exports.ItemConfigCardType.SPECIAL_OBJECT = 4
____exports.ItemConfigCardType[____exports.ItemConfigCardType.SPECIAL_OBJECT] = "SPECIAL_OBJECT"
____exports.ItemConfigCardType.TAROT_REVERSE = 5
____exports.ItemConfigCardType[____exports.ItemConfigCardType.TAROT_REVERSE] = "TAROT_REVERSE"
____exports.ItemConfigCardType.MODDED = 6
____exports.ItemConfigCardType[____exports.ItemConfigCardType.MODDED] = "MODDED"
return ____exports
