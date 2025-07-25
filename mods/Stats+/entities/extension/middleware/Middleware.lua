local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__InstanceOf = ____lualib.__TS__InstanceOf
local ____exports = {}
local ____ComputableExtension = require("entities.extension.provider.computable.ComputableExtension")
local ComputableExtension = ____ComputableExtension.ComputableExtension
local ____MiddlewareIntermediateValue = require("entities.extension.middleware.MiddlewareIntermediateValue")
local MiddlewareIntermediateValue = ____MiddlewareIntermediateValue.MiddlewareIntermediateValue
local ____MiddlewareExtension = require("entities.extension.middleware.MiddlewareExtension")
local MiddlewareExtension = ____MiddlewareExtension.MiddlewareExtension
local ____ProviderExtension = require("entities.extension.provider.ProviderExtension")
local ProviderExtension = ____ProviderExtension.ProviderExtension
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
____exports.Middleware = __TS__Class()
local Middleware = ____exports.Middleware
Middleware.name = "Middleware"
function Middleware.prototype.____constructor(self, addonId, middleware)
    self.addonId = addonId
    self.middleware = middleware
    self.extension = __TS__New(MiddlewareExtension, {addon = self.addonId, id = self.middleware.id})
    self.targetComputableExtension = __TS__New(
        ComputableExtension,
        __TS__New(ProviderExtension, self.middleware.target.provider),
        self.middleware.target.computable
    )
end
function Middleware.prototype.getExtension(self)
    return self.extension
end
function Middleware.prototype.getTargetComputableExtension(self)
    return self.targetComputableExtension
end
function Middleware.prototype.getPriority(self)
    return self.middleware.priority
end
function Middleware.prototype.intercept(self, args, current)
    local intermediateValue = self.middleware.intercept({
        args = args,
        current = current,
        ignore = function(self)
            return MiddlewareIntermediateValue:from({value = current, done = false})
        end,
        updateWith = function(self, value)
            return MiddlewareIntermediateValue:from({value = value, done = false})
        end,
        finishWith = function(self, value)
            return MiddlewareIntermediateValue:from({value = value, done = true})
        end
    })
    if not __TS__InstanceOf(intermediateValue, MiddlewareIntermediateValue) then
        error(
            __TS__New(ErrorWithContext, "Middleware .intercept(ctx) function must return an intermediate value" .. " from either ctx.ignore(), ctx.updateWith(value) or ctx.finishWith(value)", {intermediateValue = intermediateValue}),
            0
        )
    end
    return intermediateValue
end
return ____exports
