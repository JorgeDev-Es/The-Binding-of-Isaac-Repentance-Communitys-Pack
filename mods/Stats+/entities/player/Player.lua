local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Hash = require("decorators.Hash")
local Hash = ____Hash.Hash
local ____Hashable = require("decorators.Hashable")
local Hashable = ____Hashable.Hashable
____exports.Player = __TS__Class()
local Player = ____exports.Player
Player.name = "Player"
function Player.prototype.____constructor(self, entityPlayer, index)
    self.entityPlayer = entityPlayer
    self.index = index
end
function Player.prototype.isMainPlayer(self)
    return self.index == 0
end
__TS__DecorateLegacy(
    {Hash(nil)},
    Player.prototype,
    "index",
    nil
)
Player = __TS__DecorateLegacy(
    {Hashable(nil)},
    Player
)
____exports.Player = Player
return ____exports
