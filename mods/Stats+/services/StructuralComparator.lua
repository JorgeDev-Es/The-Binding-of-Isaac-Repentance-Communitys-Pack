local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__New = ____lualib.__TS__New
local __TS__TypeOf = ____lualib.__TS__TypeOf
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__StringCharCodeAt = ____lualib.__TS__StringCharCodeAt
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Metadata = require("app.Metadata")
local Metadata = ____Metadata.Metadata
local ____Hash = require("decorators.Hash")
local getClassConstructor = ____Hash.getClassConstructor
local ____Stringifiable = require("util.types.Stringifiable")
local isStringifiable = ____Stringifiable.isStringifiable
local ____Transient = require("app.ioc.decorators.Transient")
local Transient = ____Transient.Transient
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
____exports.StructuralComparator = __TS__Class()
local StructuralComparator = ____exports.StructuralComparator
StructuralComparator.name = "StructuralComparator"
function StructuralComparator.prototype.____constructor(self)
end
function StructuralComparator.prototype.compare(self, first, second)
    return self:hash(first) == self:hash(second)
end
function StructuralComparator.prototype.hash(self, instance)
    return self:isHashable(instance) and self:hashElements(self:getHashableComponents(instance)) or instance
end
function StructuralComparator.prototype.getHashableComponents(self, instance)
    local cls = getClassConstructor(nil, instance)
    if cls == nil then
        error(
            __TS__New(Error, "Could not get a constructor for the getHashableComponents target."),
            0
        )
    end
    return __TS__ArrayFilter(
        __TS__ArrayMap(
            Metadata:getMetadata(cls, "HASHABLES"),
            function(____, fn)
                local value = fn(nil, instance)
                if self:isHashable(value) then
                    return self:hash(value)
                end
                if isStringifiable(nil, value) then
                    return value
                end
                error(
                    __TS__New(
                        ErrorWithContext,
                        "Could not hash.",
                        {
                            value = value,
                            type = __TS__TypeOf(value)
                        }
                    ),
                    0
                )
            end
        ),
        function(____, value) return value ~= nil end
    )
end
function StructuralComparator.prototype.isHashable(self, entity)
    local cls = getClassConstructor(nil, entity)
    return cls ~= nil and Metadata:getMetadata(cls, "IS_HASHABLE")
end
function StructuralComparator.prototype.hashElements(self, components)
    local concatenated = table.concat(
        __TS__ArrayMap(
            components,
            function(____, component) return tostring(component) end
        ),
        ____exports.StructuralComparator.HASH_COMPONENT_SEPARATOR or ","
    )
    local hash = 0
    do
        local i = 0
        while i < #concatenated do
            local char = __TS__StringCharCodeAt(concatenated, i)
            hash = (hash << 5) - hash + char | 0
            i = i + 1
        end
    end
    return hash
end
StructuralComparator.HASH_COMPONENT_SEPARATOR = ";"
StructuralComparator = __TS__DecorateLegacy(
    {Transient(nil)},
    StructuralComparator
)
____exports.StructuralComparator = StructuralComparator
return ____exports
