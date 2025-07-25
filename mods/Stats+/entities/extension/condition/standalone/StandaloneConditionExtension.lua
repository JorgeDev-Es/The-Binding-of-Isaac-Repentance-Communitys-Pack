local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Hashable = require("decorators.Hashable")
local Hashable = ____Hashable.Hashable
local ____Hash = require("decorators.Hash")
local Hash = ____Hash.Hash
local ____coreAddonConstants = require("core.coreAddonConstants")
local ALWAYS_CONDITION_ID = ____coreAddonConstants.ALWAYS_CONDITION_ID
local CORE_ADDON_ID = ____coreAddonConstants.CORE_ADDON_ID
____exports.StandaloneConditionExtension = __TS__Class()
local StandaloneConditionExtension = ____exports.StandaloneConditionExtension
StandaloneConditionExtension.name = "StandaloneConditionExtension"
function StandaloneConditionExtension.prototype.____constructor(self, ref)
    self.addonId = ref.addon
    self.standaloneConditionId = ref.id
end
function StandaloneConditionExtension.prototype.isAlwaysCondition(self)
    return self.addonId == CORE_ADDON_ID and self.standaloneConditionId == ALWAYS_CONDITION_ID
end
__TS__DecorateLegacy(
    {Hash(nil)},
    StandaloneConditionExtension.prototype,
    "addonId",
    nil
)
__TS__DecorateLegacy(
    {Hash(nil)},
    StandaloneConditionExtension.prototype,
    "standaloneConditionId",
    nil
)
StandaloneConditionExtension = __TS__DecorateLegacy(
    {Hashable(nil)},
    StandaloneConditionExtension
)
____exports.StandaloneConditionExtension = StandaloneConditionExtension
return ____exports
