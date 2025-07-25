local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local __TS__SetDescriptor = ____lualib.__TS__SetDescriptor
local ____exports = {}
local ____StructuralComparator = require("services.StructuralComparator")
local StructuralComparator = ____StructuralComparator.StructuralComparator
____exports.HashSet = __TS__Class()
local HashSet = ____exports.HashSet
HashSet.name = "HashSet"
function HashSet.prototype.____constructor(self, entries)
    self.structuralComparator = __TS__New(StructuralComparator)
    local ____Map_2 = Map
    local ____opt_0 = entries
    self.elements = __TS__New(
        ____Map_2,
        ____opt_0 and __TS__ArrayMap(
            entries,
            function(____, element) return {
                self.structuralComparator:hash(element),
                element
            } end
        )
    )
end
function HashSet.prototype.clone(self)
    return __TS__New(
        ____exports.HashSet,
        __TS__ArrayFrom(self:values())
    )
end
function HashSet.prototype.has(self, value)
    return self.elements:has(self.structuralComparator:hash(value))
end
function HashSet.prototype.add(self, value)
    self.elements:set(
        self.structuralComparator:hash(value),
        value
    )
    return self
end
function HashSet.prototype.clear(self)
    self.elements:clear()
end
function HashSet.prototype.delete(self, value)
    return self.elements:delete(self.structuralComparator:hash(value))
end
function HashSet.prototype.values(self)
    return self.elements:values()
end
__TS__SetDescriptor(
    HashSet.prototype,
    "size",
    {get = function(self)
        return self.elements.size
    end},
    true
)
return ____exports
