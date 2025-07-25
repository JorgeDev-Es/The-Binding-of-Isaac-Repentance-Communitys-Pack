local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____ExtensionService = require("services.extension.ExtensionService")
local ExtensionService = ____ExtensionService.ExtensionService
local ____TimeProvider = require("services.renderer.TimeProvider")
local TimeProvider = ____TimeProvider.TimeProvider
local ____ConditionInstanceHandle = require("entities.extension.condition.handle.ConditionInstanceHandle")
local ConditionInstanceHandle = ____ConditionInstanceHandle.ConditionInstanceHandle
local ____ConditionInstanceHandleContext = require("entities.player.condition.ConditionInstanceHandleContext")
local ConditionInstanceHandleContext = ____ConditionInstanceHandleContext.ConditionInstanceHandleContext
____exports.ConditionFactory = __TS__Class()
local ConditionFactory = ____exports.ConditionFactory
ConditionFactory.name = "ConditionFactory"
function ConditionFactory.prototype.____constructor(self, timeProvider, extensionService)
    self.timeProvider = timeProvider
    self.extensionService = extensionService
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, TimeProvider)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, ExtensionService)
        )
    },
    ConditionFactory
)
function ConditionFactory.prototype.createCondition(self, loadoutConfigEntry, player, stat, primaryProvider, secondaryProvider)
    local context = __TS__New(
        ConditionInstanceHandleContext,
        {
            player = player,
            stat = stat,
            providers = {primaryProvider, secondaryProvider},
            condition = self.extensionService:resolveCondition(loadoutConfigEntry)
        }
    )
    return __TS__New(ConditionInstanceHandle, self.timeProvider, context)
end
ConditionFactory = __TS__DecorateLegacy(
    {Singleton(nil)},
    ConditionFactory
)
____exports.ConditionFactory = ConditionFactory
return ____exports
