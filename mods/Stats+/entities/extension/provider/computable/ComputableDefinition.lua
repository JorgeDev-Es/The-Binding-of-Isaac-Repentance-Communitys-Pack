local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.ComputableDefinition = __TS__Class()
local ComputableDefinition = ____exports.ComputableDefinition
ComputableDefinition.name = "ComputableDefinition"
function ComputableDefinition.prototype.____constructor(self, name, definition)
    self.name = name
    self.definition = definition
end
function ComputableDefinition.prototype.getName(self)
    return self.name
end
function ComputableDefinition.prototype.compute(self, resolvedComputables, args)
    return self.definition(
        resolvedComputables,
        table.unpack(args)
    )
end
return ____exports
