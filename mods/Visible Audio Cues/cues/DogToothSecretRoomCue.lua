local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ObjectValues = ____lualib.__TS__ObjectValues
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArraySome = ____lualib.__TS__ArraySome
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local CollectibleType = ____isaac_2Dtypescript_2Ddefinitions.CollectibleType
local DoorSlot = ____isaac_2Dtypescript_2Ddefinitions.DoorSlot
local ModCallback = ____isaac_2Dtypescript_2Ddefinitions.ModCallback
local RoomType = ____isaac_2Dtypescript_2Ddefinitions.RoomType
local ____CueTypeAnimationName = require("CueTypeAnimationName")
local CueTypeAnimationName = ____CueTypeAnimationName.CueTypeAnimationName
local ____doesSomePlayerHaveItem = require("doesSomePlayerHaveItem")
local doesSomePlayerHaveItem = ____doesSomePlayerHaveItem.doesSomePlayerHaveItem
local ____CueRenderer = require("CueRenderer")
local CueRenderer = ____CueRenderer.CueRenderer
local ____CueAnimationName = require("CueAnimationName")
local CueAnimationName = ____CueAnimationName.CueAnimationName
local ____once = require("once")
local once = ____once.once
____exports.DogToothSecretRoomCue = __TS__Class()
local DogToothSecretRoomCue = ____exports.DogToothSecretRoomCue
DogToothSecretRoomCue.name = "DogToothSecretRoomCue"
function DogToothSecretRoomCue.prototype.____constructor(self)
    self.renderer = __TS__New(CueRenderer, CueTypeAnimationName.Info, CueAnimationName.DogToothSecretRoom)
end
function DogToothSecretRoomCue.prototype.getRenderer(self)
    return self.renderer
end
function DogToothSecretRoomCue.prototype.register(self, mod, trigger)
    mod:AddCallback(
        ModCallback.POST_UPDATE,
        once(nil, mod, trigger)
    )
    mod:AddCallback(ModCallback.POST_NEW_ROOM, trigger)
end
function DogToothSecretRoomCue.prototype.evaluate(self)
    if not doesSomePlayerHaveItem(nil, CollectibleType.DOG_TOOTH) then
        return false
    end
    local slots = __TS__ArrayFilter(
        __TS__ObjectValues(DoorSlot),
        function(____, slot) return type(slot) == "number" end
    )
    local adjacentRooms = {}
    __TS__ArrayForEach(
        slots,
        function(____, slot)
            local door = Game():GetRoom():GetDoor(slot)
            if door ~= nil then
                adjacentRooms[#adjacentRooms + 1] = Game():GetLevel():GetRoomByIdx(door.TargetRoomIndex)
            end
        end
    )
    local adjacentSecretRooms = __TS__ArrayFilter(
        adjacentRooms,
        function(____, room)
            local ____opt_0 = room.Data
            local ____temp_4 = (____opt_0 and ____opt_0.Type) == RoomType.SECRET
            if not ____temp_4 then
                local ____opt_2 = room.Data
                ____temp_4 = (____opt_2 and ____opt_2.Type) == RoomType.SUPER_SECRET
            end
            return ____temp_4
        end
    )
    return __TS__ArraySome(
        adjacentSecretRooms,
        function(____, room) return room.VisitedCount == 0 end
    )
end
return ____exports
