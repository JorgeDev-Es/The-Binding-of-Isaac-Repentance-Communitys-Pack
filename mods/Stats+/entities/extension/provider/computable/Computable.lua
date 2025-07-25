local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local __TS__ArraySort = ____lualib.__TS__ArraySort
local ____exports = {}
local ____MiddlewareIntermediateValue = require("entities.extension.middleware.MiddlewareIntermediateValue")
local MiddlewareIntermediateValue = ____MiddlewareIntermediateValue.MiddlewareIntermediateValue
local ____HashMap = require("structures.HashMap")
local HashMap = ____HashMap.HashMap
____exports.Computable = __TS__Class()
local Computable = ____exports.Computable
Computable.name = "Computable"
function Computable.prototype.____constructor(self)
    self.middleware = __TS__New(HashMap)
    self.sortedMiddleware = {}
end
function Computable.prototype.registerMiddleware(self, middleware)
    if self:has(middleware:getExtension()) then
        return
    end
    self.middleware:set(
        middleware:getExtension(),
        middleware
    )
    self:sortMiddlewareByPriority()
end
function Computable.prototype.has(self, middleware)
    return self.middleware:has(middleware)
end
function Computable.prototype.compute(self, args, initial)
    local current = MiddlewareIntermediateValue:from({value = initial, done = false})
    for ____, middleware in ipairs(self.sortedMiddleware) do
        current = middleware:intercept(args, current.value)
        if current.done then
            break
        end
    end
    return current.value
end
function Computable.prototype.sortMiddlewareByPriority(self)
    self.sortedMiddleware = __TS__ArraySort(
        __TS__ArrayFrom(self.middleware:values()),
        function(____, a, b) return a:getPriority() - b:getPriority() end
    )
end
return ____exports
