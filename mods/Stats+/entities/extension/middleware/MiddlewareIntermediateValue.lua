local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
____exports.MiddlewareIntermediateValue = __TS__Class()
local MiddlewareIntermediateValue = ____exports.MiddlewareIntermediateValue
MiddlewareIntermediateValue.name = "MiddlewareIntermediateValue"
function MiddlewareIntermediateValue.prototype.____constructor(self, done, value)
    self.done = done
    self.value = value
end
function MiddlewareIntermediateValue.from(self, intermediateValue)
    return __TS__New(____exports.MiddlewareIntermediateValue, intermediateValue.done, intermediateValue.value)
end
return ____exports
