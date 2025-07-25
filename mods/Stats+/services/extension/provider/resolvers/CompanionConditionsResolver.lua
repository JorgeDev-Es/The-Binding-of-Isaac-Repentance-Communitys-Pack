local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ObjectFromEntries = ____lualib.__TS__ObjectFromEntries
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____ResolvedCompanionConditions = require("entities.extension.provider.handle.ResolvedCompanionConditions")
local ResolvedCompanionConditions = ____ResolvedCompanionConditions.ResolvedCompanionConditions
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____CompanionConditionContext = require("entities.extension.condition.companion.CompanionConditionContext")
local CompanionConditionContext = ____CompanionConditionContext.CompanionConditionContext
____exports.CompanionConditionsResolver = __TS__Class()
local CompanionConditionsResolver = ____exports.CompanionConditionsResolver
CompanionConditionsResolver.name = "CompanionConditionsResolver"
function CompanionConditionsResolver.prototype.____constructor(self)
end
function CompanionConditionsResolver.prototype.resolveCompanionConditions(self, provider)
    local companionConditionEntries = provider:getCompanionConditions():getConditions():entries()
    local resolvedCompanionConditionEntries = __TS__ArrayMap(
        __TS__ArrayFrom(companionConditionEntries),
        function(____, ____bindingPattern0)
            local definition
            local key
            key = ____bindingPattern0[1]
            definition = ____bindingPattern0[2]
            return {
                key,
                __TS__New(
                    CompanionConditionContext,
                    definition:getId()
                )
            }
        end
    )
    return __TS__New(
        ResolvedCompanionConditions,
        __TS__ObjectFromEntries(resolvedCompanionConditionEntries)
    )
end
CompanionConditionsResolver = __TS__DecorateLegacy(
    {Singleton(nil)},
    CompanionConditionsResolver
)
____exports.CompanionConditionsResolver = CompanionConditionsResolver
return ____exports
