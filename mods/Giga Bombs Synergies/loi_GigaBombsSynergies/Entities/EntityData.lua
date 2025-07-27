local EntityDatas = {}

function TSIL.Entities.SetEntityData(mod, entity, field, value)
    local ptrHash = GetPtrHash(entity)

    if not EntityDatas[mod.Name] then
        EntityDatas[mod.Name] = {}
    end
    local modEntityDatas = EntityDatas[mod.Name]

    if not modEntityDatas[ptrHash] then
        modEntityDatas[ptrHash] = {}
    end

    local data = modEntityDatas[ptrHash]
    data[field] = value
end


function TSIL.Entities.GetEntityData(mod, entity, field)
    local ptrHash = GetPtrHash(entity)

    if not EntityDatas[mod.Name] then
        return nil
    end
    local modEntityDatas = EntityDatas[mod.Name]

    if not modEntityDatas[ptrHash] then
        return nil
    end

    local data = modEntityDatas[ptrHash]
    return data[field]
end


local function OnEntityRemove(_, entity)
    local ptrHash = GetPtrHash(entity)

    TSIL.Utils.Functions.RunInFrames(function ()
        for _, modEntityDatas in pairs(EntityDatas) do
            modEntityDatas[ptrHash] = nil
        end
    end, 1)
end
TSIL.__AddInternalCallback(
    "ENTITY_DATA_ON_ENTITY_REMOVE",
    ModCallbacks.MC_POST_ENTITY_REMOVE,
    OnEntityRemove
)