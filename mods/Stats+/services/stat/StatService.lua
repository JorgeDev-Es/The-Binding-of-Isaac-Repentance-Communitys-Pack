local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____StatValueWatcher = require("services.stat.StatValueWatcher")
local StatValueWatcher = ____StatValueWatcher.StatValueWatcher
____exports.StatService = __TS__Class()
local StatService = ____exports.StatService
StatService.name = "StatService"
function StatService.prototype.____constructor(self, statValueWatcher)
    self.statValueWatcher = statValueWatcher
end
__TS__DecorateLegacy(
    {__TS__DecorateParam(
        0,
        Inject(nil, StatValueWatcher)
    )},
    StatService
)
function StatService.prototype.reload(self)
    self.statValueWatcher:reload()
end
function StatService.prototype.getStatValue(self, slot)
    return self.statValueWatcher:getStatValue(slot)
end
StatService = __TS__DecorateLegacy(
    {Singleton(nil)},
    StatService
)
____exports.StatService = StatService
return ____exports
