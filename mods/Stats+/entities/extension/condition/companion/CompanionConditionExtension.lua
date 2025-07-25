local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Hashable = require("decorators.Hashable")
local Hashable = ____Hashable.Hashable
local ____Hash = require("decorators.Hash")
local Hash = ____Hash.Hash
____exports.CompanionConditionExtension = __TS__Class()
local CompanionConditionExtension = ____exports.CompanionConditionExtension
CompanionConditionExtension.name = "CompanionConditionExtension"
function CompanionConditionExtension.prototype.____constructor(self, providerExtension, companionConditionId)
    self.providerExtension = providerExtension
    self.id = companionConditionId
end
__TS__DecorateLegacy(
    {Hash(nil)},
    CompanionConditionExtension.prototype,
    "providerExtension",
    nil
)
__TS__DecorateLegacy(
    {Hash(nil)},
    CompanionConditionExtension.prototype,
    "id",
    nil
)
CompanionConditionExtension = __TS__DecorateLegacy(
    {Hashable(nil)},
    CompanionConditionExtension
)
____exports.CompanionConditionExtension = CompanionConditionExtension
return ____exports
