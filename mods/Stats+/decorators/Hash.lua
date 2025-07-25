local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread
local ____exports = {}
local ____Metadata = require("app.Metadata")
local Metadata = ____Metadata.Metadata
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
function ____exports.getClassConstructor(self, arg)
    if type(arg) == "table" and arg.constructor ~= nil then
        return arg.constructor
    end
    if type(arg) == "function" then
        return arg
    end
    return nil
end
function ____exports.Hash(self, transform)
    return function(____, target, propertyKey)
        local ctor = ____exports.getClassConstructor(nil, target)
        if ctor == nil then
            error(
                __TS__New(ErrorWithContext, "Could not get a constructor for the @Hash() target.", {propertyKey = propertyKey}),
                0
            )
        end
        local ____Metadata_1 = Metadata
        local ____Metadata_setMetadata_2 = Metadata.setMetadata
        local ____array_0 = __TS__SparseArrayNew(table.unpack(Metadata:getMetadata(ctor, "HASHABLES")))
        __TS__SparseArrayPush(
            ____array_0,
            transform == nil and (function(____, instance) return instance[propertyKey] end) or (function(____, instance) return transform(nil, instance) end)
        )
        ____Metadata_setMetadata_2(
            ____Metadata_1,
            ctor,
            "HASHABLES",
            {__TS__SparseArraySpread(____array_0)}
        )
    end
end
return ____exports
