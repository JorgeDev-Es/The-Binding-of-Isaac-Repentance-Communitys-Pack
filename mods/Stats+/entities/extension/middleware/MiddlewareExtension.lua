local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Hashable = require("decorators.Hashable")
local Hashable = ____Hashable.Hashable
local ____Hash = require("decorators.Hash")
local Hash = ____Hash.Hash
____exports.MiddlewareExtension = __TS__Class()
local MiddlewareExtension = ____exports.MiddlewareExtension
MiddlewareExtension.name = "MiddlewareExtension"
function MiddlewareExtension.prototype.____constructor(self, ref)
    self.addonId = ref.addon
    self.middlewareId = ref.id
end
__TS__DecorateLegacy(
    {Hash(nil)},
    MiddlewareExtension.prototype,
    "addonId",
    nil
)
__TS__DecorateLegacy(
    {Hash(nil)},
    MiddlewareExtension.prototype,
    "middlewareId",
    nil
)
MiddlewareExtension = __TS__DecorateLegacy(
    {Hashable(nil)},
    MiddlewareExtension
)
____exports.MiddlewareExtension = MiddlewareExtension
return ____exports
