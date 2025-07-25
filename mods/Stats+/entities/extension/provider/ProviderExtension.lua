local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Hashable = require("decorators.Hashable")
local Hashable = ____Hashable.Hashable
local ____Hash = require("decorators.Hash")
local Hash = ____Hash.Hash
local ____coreAddonConstants = require("core.coreAddonConstants")
local CORE_ADDON_ID = ____coreAddonConstants.CORE_ADDON_ID
____exports.ProviderExtension = __TS__Class()
local ProviderExtension = ____exports.ProviderExtension
ProviderExtension.name = "ProviderExtension"
function ProviderExtension.prototype.____constructor(self, ref)
    self.addonId = ref.addon
    self.providerId = ref.id
end
function ProviderExtension.prototype.isCoreExtension(self)
    return self.addonId == CORE_ADDON_ID
end
__TS__DecorateLegacy(
    {Hash(nil)},
    ProviderExtension.prototype,
    "addonId",
    nil
)
__TS__DecorateLegacy(
    {Hash(nil)},
    ProviderExtension.prototype,
    "providerId",
    nil
)
ProviderExtension = __TS__DecorateLegacy(
    {Hashable(nil)},
    ProviderExtension
)
____exports.ProviderExtension = ProviderExtension
return ____exports
