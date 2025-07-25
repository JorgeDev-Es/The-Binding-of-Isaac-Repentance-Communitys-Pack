local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____InjectionToken = require("app.ioc.InjectionToken")
local InjectionToken = ____InjectionToken.InjectionToken
____exports.DefaultStateEncoder = __TS__Class()
local DefaultStateEncoder = ____exports.DefaultStateEncoder
DefaultStateEncoder.name = "DefaultStateEncoder"
function DefaultStateEncoder.prototype.____constructor(self, jsonSerializer)
    self.jsonSerializer = jsonSerializer
end
__TS__DecorateLegacy(
    {__TS__DecorateParam(
        0,
        Inject(nil, InjectionToken.JsonSerializer)
    )},
    DefaultStateEncoder
)
function DefaultStateEncoder.prototype.encode(self, decoded)
    return self.jsonSerializer:encode(decoded)
end
function DefaultStateEncoder.prototype.decode(self, encoded)
    return self.jsonSerializer:decode(encoded)
end
DefaultStateEncoder = __TS__DecorateLegacy(
    {Singleton(nil)},
    DefaultStateEncoder
)
____exports.DefaultStateEncoder = DefaultStateEncoder
return ____exports
