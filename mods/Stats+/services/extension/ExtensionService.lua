local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread
local __TS__InstanceOf = ____lualib.__TS__InstanceOf
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Computable = require("entities.extension.provider.computable.Computable")
local Computable = ____Computable.Computable
local ____CompanionConditionExtension = require("entities.extension.condition.companion.CompanionConditionExtension")
local CompanionConditionExtension = ____CompanionConditionExtension.CompanionConditionExtension
local ____ProviderExtension = require("entities.extension.provider.ProviderExtension")
local ProviderExtension = ____ProviderExtension.ProviderExtension
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____HashMap = require("structures.HashMap")
local HashMap = ____HashMap.HashMap
local ____StandaloneConditionExtension = require("entities.extension.condition.standalone.StandaloneConditionExtension")
local StandaloneConditionExtension = ____StandaloneConditionExtension.StandaloneConditionExtension
local ____HashSet = require("structures.HashSet")
local HashSet = ____HashSet.HashSet
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
local ____coreAddonConstants = require("core.coreAddonConstants")
local ALWAYS_CONDITION_ID = ____coreAddonConstants.ALWAYS_CONDITION_ID
local CORE_ADDON_ID = ____coreAddonConstants.CORE_ADDON_ID
local NULL_PROVIDER_ID = ____coreAddonConstants.NULL_PROVIDER_ID
____exports.ExtensionService = __TS__Class()
local ExtensionService = ____exports.ExtensionService
ExtensionService.name = "ExtensionService"
function ExtensionService.prototype.____constructor(self)
    self.computables = __TS__New(HashMap)
    self.providers = __TS__New(HashMap)
    self.conditions = __TS__New(HashMap)
end
function ExtensionService.prototype.registerMiddleware(self, middleware)
    local targetComputableExtension = middleware:getTargetComputableExtension()
    if not self.computables:has(targetComputableExtension) then
        self.computables:set(
            targetComputableExtension,
            __TS__New(Computable)
        )
    end
    local computable = self.computables:get(targetComputableExtension)
    if computable:has(middleware:getExtension()) then
        error(
            __TS__New(
                ErrorWithContext,
                "Middleware already registered.",
                {
                    addon = middleware:getExtension().addonId,
                    id = middleware:getExtension().middlewareId
                }
            ),
            0
        )
    end
    computable:registerMiddleware(middleware)
end
function ExtensionService.prototype.registerProvider(self, provider)
    if self.providers:has(provider:getExtension()) then
        error(
            __TS__New(
                ErrorWithContext,
                "Provider already registered.",
                {
                    addon = provider:getExtension().addonId,
                    id = provider:getExtension().providerId
                }
            ),
            0
        )
    end
    self.providers:set(
        provider:getExtension(),
        provider
    )
    __TS__ArrayForEach(
        __TS__ArrayFrom(provider:getCompanionConditions():getConditions():values()),
        function(____, condition)
            local conditionExtension = __TS__New(
                CompanionConditionExtension,
                provider:getExtension(),
                condition:getId()
            )
            self:registerCondition(conditionExtension, condition)
        end
    )
end
function ExtensionService.prototype.registerStandaloneCondition(self, condition)
    local extension = __TS__New(
        StandaloneConditionExtension,
        {
            addon = condition:getExtension().addonId,
            id = condition:getId()
        }
    )
    if self.conditions:has(extension) then
        error(
            __TS__New(
                ErrorWithContext,
                "Condition already registered.",
                {
                    addon = condition:getExtension().addonId,
                    id = condition:getId()
                }
            ),
            0
        )
    end
    self:registerCondition(extension, condition)
end
function ExtensionService.prototype.registerCondition(self, extension, condition)
    self.conditions:set(extension, condition)
end
function ExtensionService.prototype.getComputable(self, ref)
    return self.computables:get(ref) or __TS__New(Computable)
end
function ExtensionService.prototype.getAvailableProviders(self)
    return __TS__ArrayFrom(self.providers:keys())
end
function ExtensionService.prototype.getAvailableConditions(self, loadoutEntry)
    local ____array_0 = __TS__SparseArrayNew(table.unpack(self:getAvailableStandaloneConditions()))
    __TS__SparseArrayPush(
        ____array_0,
        table.unpack(self:getAvailableCompanionConditionsFor(loadoutEntry))
    )
    return {__TS__SparseArraySpread(____array_0)}
end
function ExtensionService.prototype.getAvailableStandaloneConditions(self)
    return __TS__ArrayFilter(
        __TS__ArrayFrom(self.conditions:keys()),
        function(____, condition) return __TS__InstanceOf(condition, StandaloneConditionExtension) end
    )
end
function ExtensionService.prototype.getAvailableCompanionConditionsFor(self, loadoutConfigEntry)
    local primaryProvider = self:getProvider(loadoutConfigEntry:getPrimaryProvider())
    local secondaryProvider = self:getProvider(loadoutConfigEntry:getSecondaryProvider())
    local ____opt_1 = primaryProvider and primaryProvider:getCompanionConditions()
    local primaryProviderConditions = ____opt_1 and ____opt_1:getConditions() or __TS__New(HashMap)
    local ____opt_5 = secondaryProvider and secondaryProvider:getCompanionConditions()
    local secondaryProviderConditions = ____opt_5 and ____opt_5:getConditions() or __TS__New(HashMap)
    local primaryProviderCompanionConditions = __TS__ArrayMap(
        __TS__ArrayFrom(primaryProviderConditions:values()),
        function(____, condition) return __TS__New(
            CompanionConditionExtension,
            loadoutConfigEntry:getPrimaryProvider(),
            condition:getId()
        ) end
    )
    local secondaryProviderCompanionConditions = __TS__ArrayMap(
        __TS__ArrayFrom(secondaryProviderConditions:values()),
        function(____, condition) return __TS__New(
            CompanionConditionExtension,
            loadoutConfigEntry:getSecondaryProvider(),
            condition:getId()
        ) end
    )
    local hashSet = __TS__New(
        HashSet,
        __TS__ArrayConcat(primaryProviderCompanionConditions, secondaryProviderCompanionConditions)
    )
    return __TS__ArrayFrom(hashSet:values())
end
function ExtensionService.prototype.resolveProvider(self, extension)
    return self:getProvider(extension) or self:getFallbackProvider()
end
function ExtensionService.prototype.resolveCondition(self, loadoutEntry)
    local companionConditions = __TS__New(
        HashSet,
        self:getAvailableCompanionConditionsFor(loadoutEntry)
    )
    if __TS__InstanceOf(
        loadoutEntry:getCondition(),
        CompanionConditionExtension
    ) and not companionConditions:has(loadoutEntry:getCondition()) then
        return self:getFallbackCondition()
    end
    return self:getCondition(loadoutEntry:getCondition()) or self:getFallbackCondition()
end
function ExtensionService.prototype.getProvider(self, extension)
    return self.providers:get(extension)
end
function ExtensionService.prototype.getCondition(self, extension)
    return self.conditions:get(extension)
end
function ExtensionService.prototype.getFallbackProvider(self)
    local provider = self.providers:get(____exports.ExtensionService.FALLBACK_PROVIDER)
    if provider == nil then
        error(
            __TS__New(Error, "Could not find the built-in fallback provider definition."),
            0
        )
    end
    return provider
end
function ExtensionService.prototype.getFallbackCondition(self)
    local conditionDefinition = self.conditions:get(____exports.ExtensionService.FALLBACK_CONDITION)
    if conditionDefinition == nil then
        error(
            __TS__New(Error, "Could not find the built-in fallback condition definition."),
            0
        )
    end
    return conditionDefinition
end
ExtensionService.FALLBACK_PROVIDER = __TS__New(ProviderExtension, {addon = CORE_ADDON_ID, id = NULL_PROVIDER_ID})
ExtensionService.FALLBACK_CONDITION = __TS__New(StandaloneConditionExtension, {addon = CORE_ADDON_ID, id = ALWAYS_CONDITION_ID})
ExtensionService = __TS__DecorateLegacy(
    {Singleton(nil)},
    ExtensionService
)
____exports.ExtensionService = ExtensionService
return ____exports
