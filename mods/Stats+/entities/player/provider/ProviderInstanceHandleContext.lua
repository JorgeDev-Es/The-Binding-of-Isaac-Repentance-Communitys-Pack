local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.ProviderInstanceHandleContext = __TS__Class()
local ProviderInstanceHandleContext = ____exports.ProviderInstanceHandleContext
ProviderInstanceHandleContext.name = "ProviderInstanceHandleContext"
function ProviderInstanceHandleContext.prototype.____constructor(self, options)
    self.player = options.player
    self.stat = options.stat
    self.computables = options.computables
    self.conditions = options.conditions
    self.settings = options.settings
    self.state = options.state
end
function ProviderInstanceHandleContext.prototype.getExternalAPI(self)
    return {
        player = self.player.entityPlayer,
        playerIndex = self.player.index,
        stat = self.stat:getExternalAPI(),
        state = self.state:getExternalAPI(),
        computables = self.computables:getExternalAPI(),
        conditions = self.conditions:getExternalAPI(),
        settings = self.settings:getExternalAPI()
    }
end
return ____exports
