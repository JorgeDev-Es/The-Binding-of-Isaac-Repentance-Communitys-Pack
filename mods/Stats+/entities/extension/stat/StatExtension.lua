local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Hashable = require("decorators.Hashable")
local Hashable = ____Hashable.Hashable
local ____Hash = require("decorators.Hash")
local Hash = ____Hash.Hash
____exports.StatExtension = __TS__Class()
local StatExtension = ____exports.StatExtension
StatExtension.name = "StatExtension"
function StatExtension.prototype.____constructor(self, ref)
    self.addonId = ref.addon
    self.statId = ref.id
end
function StatExtension.prototype.getExternalAPI(self)
    return {addon = self.addonId, id = self.statId}
end
__TS__DecorateLegacy(
    {Hash(nil)},
    StatExtension.prototype,
    "addonId",
    nil
)
__TS__DecorateLegacy(
    {Hash(nil)},
    StatExtension.prototype,
    "statId",
    nil
)
StatExtension = __TS__DecorateLegacy(
    {Hashable(nil)},
    StatExtension
)
____exports.StatExtension = StatExtension
return ____exports
