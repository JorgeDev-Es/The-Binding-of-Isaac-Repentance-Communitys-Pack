local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____StandaloneConditionExtension = require("entities.extension.condition.standalone.StandaloneConditionExtension")
local StandaloneConditionExtension = ____StandaloneConditionExtension.StandaloneConditionExtension
____exports.StandaloneConditionDefinition = __TS__Class()
local StandaloneConditionDefinition = ____exports.StandaloneConditionDefinition
StandaloneConditionDefinition.name = "StandaloneConditionDefinition"
function StandaloneConditionDefinition.prototype.____constructor(self, addonId, standaloneCondition)
    self.addonId = addonId
    self.standaloneCondition = standaloneCondition
    self.extension = __TS__New(StandaloneConditionExtension, {addon = self.addonId, id = self.standaloneCondition.id})
end
function StandaloneConditionDefinition.prototype.getId(self)
    return self.standaloneCondition.id
end
function StandaloneConditionDefinition.prototype.getName(self)
    return self.standaloneCondition.name
end
function StandaloneConditionDefinition.prototype.getDescription(self)
    return self.standaloneCondition.description
end
function StandaloneConditionDefinition.prototype.getExtension(self)
    return self.extension
end
function StandaloneConditionDefinition.prototype.mount(self, providers, context)
    return self.standaloneCondition.mount(context)
end
return ____exports
