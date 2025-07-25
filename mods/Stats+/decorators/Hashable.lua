local ____lualib = require("lualib_bundle")
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread
local ____exports = {}
local ____Metadata = require("app.Metadata")
local Metadata = ____Metadata.Metadata
function ____exports.Hashable(self)
    return function(____, target)
        Metadata:setMetadata(target, "IS_HASHABLE", true)
        local ____Metadata_2 = Metadata
        local ____Metadata_setMetadata_3 = Metadata.setMetadata
        local ____target_1 = target
        local ____array_0 = __TS__SparseArrayNew(table.unpack(Metadata:getMetadata(target, "HASHABLES")))
        __TS__SparseArrayPush(
            ____array_0,
            function() return target.name end
        )
        ____Metadata_setMetadata_3(
            ____Metadata_2,
            ____target_1,
            "HASHABLES",
            {__TS__SparseArraySpread(____array_0)}
        )
    end
end
return ____exports
