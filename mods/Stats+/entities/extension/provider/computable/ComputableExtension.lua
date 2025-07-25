local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Hashable = require("decorators.Hashable")
local Hashable = ____Hashable.Hashable
local ____Hash = require("decorators.Hash")
local Hash = ____Hash.Hash
____exports.ComputableExtension = __TS__Class()
local ComputableExtension = ____exports.ComputableExtension
ComputableExtension.name = "ComputableExtension"
function ComputableExtension.prototype.____constructor(self, providerExtension, computableId)
    self.providerExtension = providerExtension
    self.computableId = computableId
end
__TS__DecorateLegacy(
    {Hash(nil)},
    ComputableExtension.prototype,
    "providerExtension",
    nil
)
__TS__DecorateLegacy(
    {Hash(nil)},
    ComputableExtension.prototype,
    "computableId",
    nil
)
ComputableExtension = __TS__DecorateLegacy(
    {Hashable(nil)},
    ComputableExtension
)
____exports.ComputableExtension = ComputableExtension
return ____exports
