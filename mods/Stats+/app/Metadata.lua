local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local ____exports = {}
____exports.Metadata = __TS__Class()
local Metadata = ____exports.Metadata
Metadata.name = "Metadata"
function Metadata.prototype.____constructor(self)
end
function Metadata.setMetadata(self, identifier, key, value)
    if not ____exports.Metadata.STORAGE:has(identifier) then
        ____exports.Metadata.STORAGE:set(identifier, {})
    end
    local dependencyMetadata = ____exports.Metadata.STORAGE:get(identifier)
    dependencyMetadata[key] = value
end
function Metadata.getMetadata(self, identifier, key)
    if not ____exports.Metadata.STORAGE:has(identifier) then
        ____exports.Metadata.STORAGE:set(identifier, {})
    end
    local dependencyMetadata = ____exports.Metadata.STORAGE:get(identifier)
    local ____dependencyMetadata_1, ____key_2 = dependencyMetadata, key
    if ____dependencyMetadata_1[____key_2] == nil then
        local ____self_0 = ____exports.Metadata.DEFAULT_METADATA_VALUES
        ____dependencyMetadata_1[____key_2] = ____self_0[key](____self_0)
    end
    return dependencyMetadata[key]
end
Metadata.DEFAULT_METADATA_VALUES = {
    IS_HASHABLE = function() return false end,
    HASHABLES = function() return {} end
}
Metadata.STORAGE = __TS__New(Map)
return ____exports
