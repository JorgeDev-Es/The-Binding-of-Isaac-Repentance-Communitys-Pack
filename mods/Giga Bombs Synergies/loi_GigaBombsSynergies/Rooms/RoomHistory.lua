
local function OnTSILLoaded()
    TSIL.SaveManager.AddPersistentVariable(TSIL.__MOD, "roomHistory_ROOM_HISTORY", {}, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
end
TSIL.__AddInternalCallback(
    "ROOM_HISTORY_ON_TSIL_LOADED",
    TSIL.Enums.CustomCallback.POST_TSIL_LOAD,
    OnTSILLoaded
)


local function OnNewRoomEarly(_, isFromNewRoomCallback)
    local level = Game():GetLevel();
    local stage = level:GetStage();
    local stageType = level:GetStageType();
    local room = Game():GetRoom();
    local roomType = room:GetType();
    local roomDescriptor = level:GetCurrentRoomDesc()
    local roomData = roomDescriptor.Data
    local stageID = roomData.StageID
    local dimension = TSIL.Dimensions.GetDimension()
    local roomVariant = roomData.Variant
    local roomSubType = roomData.Subtype
    local roomName = roomData.Name
    local roomGridIndex = roomDescriptor.SafeGridIndex
    local roomListIndex = roomDescriptor.ListIndex
    local roomVisitedCount = roomDescriptor.VisitedCount

    if not isFromNewRoomCallback then
        roomVisitedCount = roomVisitedCount + 1
    end

    local roomHistoryData = {
        Stage = stage,
        StageType = stageType,
        RoomType = roomType,
        StageID = stageID,
        Dimension = dimension,
        RoomVariant = roomVariant,
        RoomSubType = roomSubType,
        RoomName = roomName,
        RoomGridIndex = roomGridIndex,
        RoomListIndex = roomListIndex,
        RoomVisitedCount = roomVisitedCount
    }

    local roomHistory = TSIL.SaveManager.GetPersistentVariable(TSIL.__MOD, "roomHistory_ROOM_HISTORY")
    roomHistory[#roomHistory+1] = roomHistoryData
end
TSIL.__AddInternalCallback(
    "ROOM_HISTORY_POST_NEW_ROOM_EARLY",
    TSIL.Enums.CustomCallback.POST_NEW_ROOM_EARLY,
    OnNewRoomEarly
)


local function MakeRoomHistoryDataReadOnly(roomHistoryData)
    local proxy = {}

    local mt = {
        __type = "RoomHistoryData",
        __index = roomHistoryData,
        __newindex = function()
            error("Attempt to update a read-only table", 2)
        end,
        __eq = function(t1, t2)
            local ci1 = getmetatable(t1).__proxy
            local ci2 = getmetatable(t2).__proxy

            for key, value in pairs(ci1) do
                if value ~= ci2[key] then
                    return false
                end
            end

            return true
        end,
        __proxy = roomHistoryData
    }

    setmetatable(proxy, mt)

    return proxy
end






function TSIL.Rooms.GetLatestRoomDescription()
    local roomHistory = TSIL.SaveManager.GetPersistentVariable(TSIL.__MOD, "roomHistory_ROOM_HISTORY")

    local lastRoomData = roomHistory[#roomHistory]

    return MakeRoomHistoryDataReadOnly(lastRoomData)
end


function TSIL.Rooms.IsLeavingRoom()
    local level = Game():GetLevel()
    local stageType = level:GetStageType()
    local stage = level:GetStage()
    local roomDescriptor = level:GetCurrentRoomDesc()
    local roomListIndex = roomDescriptor.ListIndex
    local roomVisitedCount = roomDescriptor.VisitedCount
    local latestRoomDescription = TSIL.Rooms.GetLatestRoomDescription()

    if latestRoomDescription == nil then
        return false
    end

    return (
      stage ~= latestRoomDescription.Stage or
      stageType ~= latestRoomDescription.StageType or
      roomListIndex ~= latestRoomDescription.RoomListIndex or
      roomVisitedCount ~= latestRoomDescription.RoomVisitedCount
    )
end