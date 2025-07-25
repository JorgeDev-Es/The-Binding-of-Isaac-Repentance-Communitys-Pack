local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Hashable = require("decorators.Hashable")
local Hashable = ____Hashable.Hashable
local ____Hash = require("decorators.Hash")
local Hash = ____Hash.Hash
____exports.StatSlot = __TS__Class()
local StatSlot = ____exports.StatSlot
StatSlot.name = "StatSlot"
function StatSlot.prototype.____constructor(self, stat, player)
    self.stat = stat
    self.player = player
end
__TS__DecorateLegacy(
    {Hash(nil)},
    StatSlot.prototype,
    "stat",
    nil
)
__TS__DecorateLegacy(
    {Hash(nil)},
    StatSlot.prototype,
    "player",
    nil
)
StatSlot = __TS__DecorateLegacy(
    {Hashable(nil)},
    StatSlot
)
____exports.StatSlot = StatSlot
return ____exports
