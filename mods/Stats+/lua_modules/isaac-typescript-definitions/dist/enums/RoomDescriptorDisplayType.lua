local ____exports = {}
--- Matches the `RoomDescriptor.DISPLAY_*` members of the `RoomDescriptor` class. In IsaacScript, we
-- reimplement this as an enum instead, since it is cleaner.
____exports.RoomDescriptorDisplayType = {}
____exports.RoomDescriptorDisplayType.NONE = 0
____exports.RoomDescriptorDisplayType[____exports.RoomDescriptorDisplayType.NONE] = "NONE"
____exports.RoomDescriptorDisplayType.BOX = 1
____exports.RoomDescriptorDisplayType[____exports.RoomDescriptorDisplayType.BOX] = "BOX"
____exports.RoomDescriptorDisplayType.LOCK = 2
____exports.RoomDescriptorDisplayType[____exports.RoomDescriptorDisplayType.LOCK] = "LOCK"
____exports.RoomDescriptorDisplayType.ICON = 4
____exports.RoomDescriptorDisplayType[____exports.RoomDescriptorDisplayType.ICON] = "ICON"
____exports.RoomDescriptorDisplayType.ALL = 5
____exports.RoomDescriptorDisplayType[____exports.RoomDescriptorDisplayType.ALL] = "ALL"
return ____exports
