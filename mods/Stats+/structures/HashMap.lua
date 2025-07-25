local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor
local ____exports = {}
local ____mapIterator = require("util.iterator.mapIterator")
local mapIterator = ____mapIterator.mapIterator
local ____StructuralComparator = require("services.StructuralComparator")
local StructuralComparator = ____StructuralComparator.StructuralComparator
____exports.HashMap = __TS__Class()
local HashMap = ____exports.HashMap
HashMap.name = "HashMap"
function HashMap.prototype.____constructor(self, entries)
    self.structuralComparator = __TS__New(StructuralComparator)
    local ____Map_2 = Map
    local ____opt_0 = entries
    self.hashToValueMapping = __TS__New(
        ____Map_2,
        ____opt_0 and __TS__ArrayMap(
            entries,
            function(____, ____bindingPattern0)
                local value
                local key
                key = ____bindingPattern0[1]
                value = ____bindingPattern0[2]
                return {
                    self.structuralComparator:hash(key),
                    value
                }
            end
        )
    )
    local ____Map_5 = Map
    local ____opt_3 = entries
    self.hashToKeyMapping = __TS__New(
        ____Map_5,
        ____opt_3 and __TS__ArrayMap(
            entries,
            function(____, ____bindingPattern0)
                local key
                key = ____bindingPattern0[1]
                return {
                    self.structuralComparator:hash(key),
                    key
                }
            end
        )
    )
end
function HashMap.prototype.clone(self)
    return __TS__New(
        ____exports.HashMap,
        __TS__ArrayFrom(self:entries())
    )
end
function HashMap.prototype.has(self, key)
    return self.hashToValueMapping:has(self.structuralComparator:hash(key))
end
function HashMap.prototype.get(self, key)
    return self.hashToValueMapping:get(self.structuralComparator:hash(key))
end
function HashMap.prototype.set(self, key, value)
    local hash = self.structuralComparator:hash(key)
    self.hashToValueMapping:set(hash, value)
    self.hashToKeyMapping:set(hash, key)
    return self
end
function HashMap.prototype.clear(self)
    self.hashToValueMapping:clear()
    self.hashToKeyMapping:clear()
end
function HashMap.prototype.delete(self, key)
    local hash = self.structuralComparator:hash(key)
    local mapEntryDeleted = self.hashToValueMapping:delete(hash)
    local hashToKeyMappingEntryDeleted = self.hashToKeyMapping:delete(hash)
    return mapEntryDeleted or hashToKeyMappingEntryDeleted
end
function HashMap.prototype.keys(self)
    return self.hashToKeyMapping:values()
end
function HashMap.prototype.values(self)
    return self.hashToValueMapping:values()
end
function HashMap.prototype.entries(self)
    return mapIterator(
        nil,
        self.hashToKeyMapping:entries(),
        function(____, ____bindingPattern0)
            local key
            local hash
            hash = ____bindingPattern0[1]
            key = ____bindingPattern0[2]
            local value = self.hashToValueMapping:get(hash)
            if value == nil then
                local ____Error_8 = Error
                local ____opt_6 = hash
                if ____opt_6 ~= nil then
                    ____opt_6 = tostring(hash)
                end
                error(
                    __TS__New(
                        ____Error_8,
                        ("Could not find a value by \"" .. tostring(____opt_6)) .. "\" hash."
                    ),
                    0
                )
            end
            return {key, value}
        end
    )
end
__TS__SetDescriptor(
    HashMap.prototype,
    "size",
    {get = function(self)
        return self.hashToValueMapping.size
    end},
    true
)
return ____exports
