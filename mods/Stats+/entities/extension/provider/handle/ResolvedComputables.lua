local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.ResolvedComputables = __TS__Class()
local ResolvedComputables = ____exports.ResolvedComputables
ResolvedComputables.name = "ResolvedComputables"
function ResolvedComputables.prototype.____constructor(self, computables)
    self.computables = computables
end
function ResolvedComputables.prototype.getExternalAPI(self)
    return self.computables
end
return ____exports
