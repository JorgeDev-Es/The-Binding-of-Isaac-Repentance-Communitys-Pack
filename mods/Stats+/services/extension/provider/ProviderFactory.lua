local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____ExtensionService = require("services.extension.ExtensionService")
local ExtensionService = ____ExtensionService.ExtensionService
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____ComputablesResolver = require("services.extension.provider.resolvers.ComputablesResolver")
local ComputablesResolver = ____ComputablesResolver.ComputablesResolver
local ____CompanionConditionsResolver = require("services.extension.provider.resolvers.CompanionConditionsResolver")
local CompanionConditionsResolver = ____CompanionConditionsResolver.CompanionConditionsResolver
local ____SettingsResolver = require("services.extension.provider.resolvers.SettingsResolver")
local SettingsResolver = ____SettingsResolver.SettingsResolver
local ____StateResolver = require("services.extension.provider.resolvers.StateResolver")
local StateResolver = ____StateResolver.StateResolver
local ____ProviderInstanceHandleContext = require("entities.player.provider.ProviderInstanceHandleContext")
local ProviderInstanceHandleContext = ____ProviderInstanceHandleContext.ProviderInstanceHandleContext
____exports.ProviderFactory = __TS__Class()
local ProviderFactory = ____exports.ProviderFactory
ProviderFactory.name = "ProviderFactory"
function ProviderFactory.prototype.____constructor(self, extensionService, computablesResolver, companionConditionsResolver, settingsResolver, stateResolver)
    self.extensionService = extensionService
    self.computablesResolver = computablesResolver
    self.companionConditionsResolver = companionConditionsResolver
    self.settingsResolver = settingsResolver
    self.stateResolver = stateResolver
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, ExtensionService)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, ComputablesResolver)
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, CompanionConditionsResolver)
        ),
        __TS__DecorateParam(
            3,
            Inject(nil, SettingsResolver)
        ),
        __TS__DecorateParam(
            4,
            Inject(nil, StateResolver)
        )
    },
    ProviderFactory
)
function ProviderFactory.prototype.createProvider(self, extension, stat, player)
    local provider = self.extensionService:resolveProvider(extension)
    local context = __TS__New(
        ProviderInstanceHandleContext,
        {
            player = player,
            stat = stat,
            computables = self.computablesResolver:resolveComputables(provider),
            conditions = self.companionConditionsResolver:resolveCompanionConditions(provider),
            settings = self.settingsResolver:resolveSettings(provider),
            state = self.stateResolver:resolveState(provider)
        }
    )
    return provider:mount(context)
end
ProviderFactory = __TS__DecorateLegacy(
    {Singleton(nil)},
    ProviderFactory
)
____exports.ProviderFactory = ProviderFactory
return ____exports
