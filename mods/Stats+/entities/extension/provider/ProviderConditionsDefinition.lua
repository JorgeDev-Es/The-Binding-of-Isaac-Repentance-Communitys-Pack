local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ObjectEntries = ____lualib.__TS__ObjectEntries
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____CompanionConditionExtension = require("entities.extension.condition.companion.CompanionConditionExtension")
local CompanionConditionExtension = ____CompanionConditionExtension.CompanionConditionExtension
local ____CompanionConditionDefinition = require("entities.extension.condition.companion.CompanionConditionDefinition")
local CompanionConditionDefinition = ____CompanionConditionDefinition.CompanionConditionDefinition
local ____HashMap = require("structures.HashMap")
local HashMap = ____HashMap.HashMap
____exports.ProviderConditionsDefinition = __TS__Class()
local ProviderConditionsDefinition = ____exports.ProviderConditionsDefinition
ProviderConditionsDefinition.name = "ProviderConditionsDefinition"
function ProviderConditionsDefinition.prototype.____constructor(self, providerExtension, conditions, modCallbackService)
    self.providerExtension = providerExtension
    self.conditions = conditions
    self.modCallbackService = modCallbackService
end
function ProviderConditionsDefinition.prototype.getConditions(self)
    local entries = __TS__ArrayMap(
        __TS__ObjectEntries(self.conditions),
        function(____, ____bindingPattern0)
            local definition
            local conditionKey
            conditionKey = ____bindingPattern0[1]
            definition = ____bindingPattern0[2]
            return {
                conditionKey,
                __TS__New(
                    CompanionConditionDefinition,
                    __TS__New(CompanionConditionExtension, self.providerExtension, definition.id),
                    definition,
                    self.modCallbackService
                )
            }
        end
    )
    return __TS__New(HashMap, entries)
end
return ____exports
