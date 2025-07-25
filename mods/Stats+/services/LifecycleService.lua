local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____EventEmitter = require("util.events.EventEmitter")
local EventEmitter = ____EventEmitter.EventEmitter
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
____exports.LifecycleService = __TS__Class()
local LifecycleService = ____exports.LifecycleService
LifecycleService.name = "LifecycleService"
function LifecycleService.prototype.____constructor(self)
    self.events = __TS__New(EventEmitter)
end
function LifecycleService.prototype.reloadAll(self)
    self.events:broadcast("reload")
end
function LifecycleService.prototype.getEvents(self)
    return self.events:asClient()
end
LifecycleService = __TS__DecorateLegacy(
    {Singleton(nil)},
    LifecycleService
)
____exports.LifecycleService = LifecycleService
return ____exports
