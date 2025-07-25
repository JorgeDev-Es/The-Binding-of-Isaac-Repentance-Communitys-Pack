local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.ConditionInstanceHandleContext = __TS__Class()
local ConditionInstanceHandleContext = ____exports.ConditionInstanceHandleContext
ConditionInstanceHandleContext.name = "ConditionInstanceHandleContext"
function ConditionInstanceHandleContext.prototype.____constructor(self, options)
    self.player = options.player
    self.stat = options.stat
    self.providers = options.providers
    self.condition = options.condition
end
return ____exports
