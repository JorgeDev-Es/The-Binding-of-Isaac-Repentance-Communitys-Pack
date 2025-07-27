local Helpers = {}

---@class TemporaryScheduleFunction
---@field func function
---@field frames integer
---@field params table

---@type TemporaryScheduleFunction[]
local functionsToSchedule = {}

---Adds a function to be executed in x frames.
---Doesnt carry over rooms.
---@param func function
---@param frames integer
---@param ... any
function Helpers.AddTemporarySchedule(func, frames, ...)
    functionsToSchedule[#functionsToSchedule+1] = {
        frames = frames,
        func = func,
        params = {...}
    }
end


local function OnUpdate()
    TSIL.Utils.Tables.ForEach(functionsToSchedule, function (_, scheduledFunction)
        scheduledFunction.frames = scheduledFunction.frames - 1

        if scheduledFunction.frames == 0 then
            scheduledFunction.func(table.unpack(scheduledFunction.params))
        end
    end)

    functionsToSchedule = TSIL.Utils.Tables.Filter(functionsToSchedule, function (_, scheduledFunction)
        return scheduledFunction.frames ~= 0
    end)
end
GigaBombsSynergiesMod:AddCallback(
    ModCallbacks.MC_POST_UPDATE,
    OnUpdate
)

local function OnNewRoom()
    functionsToSchedule = {}
end
GigaBombsSynergiesMod:AddCallback(
    ModCallbacks.MC_POST_NEW_ROOM,
    OnNewRoom
)

---Removes all entities just spawned of a given type, variant and subtype.
---@param type EntityType
---@param variant integer?
---@param subtype integer?
function Helpers.RemoveJustSpawnedEntities(type, variant, subtype)
    local entities = TSIL.Entities.GetEntities(
        type,
        variant,
        subtype
    )

    local spawnedEntities = TSIL.Utils.Tables.Filter(entities, function (_, entity)
        return entity.FrameCount == 0
    end)

    TSIL.Utils.Tables.ForEach(spawnedEntities, function (_, entity)
        entity:Remove()
    end)
end

GigaBombsSynergiesMod.Helpers = Helpers