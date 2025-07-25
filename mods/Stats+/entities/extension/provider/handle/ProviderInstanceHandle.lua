local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.ProviderInstanceHandle = __TS__Class()
local ProviderInstanceHandle = ____exports.ProviderInstanceHandle
ProviderInstanceHandle.name = "ProviderInstanceHandle"
function ProviderInstanceHandle.prototype.____constructor(self, provider, context, cleanup)
    self.provider = provider
    self.context = context
    self.cleanup = cleanup
end
function ProviderInstanceHandle.prototype.unregister(self)
    local ____opt_0 = self.cleanup
    if ____opt_0 ~= nil then
        ____opt_0()
    end
end
function ProviderInstanceHandle.prototype.getProvider(self)
    return self.provider
end
function ProviderInstanceHandle.prototype.getValue(self)
    local ____opt_2 = self.context.state:getDisplayStateHandle()
    return ____opt_2 and ____opt_2:getMetricValue()
end
function ProviderInstanceHandle.prototype.getProviderColor(self)
    return self.context.settings:getProviderColor()
end
function ProviderInstanceHandle.prototype.isCompanionConditionActive(self, companionConditionIdentifier)
    return self.context.conditions:isActive(companionConditionIdentifier)
end
function ProviderInstanceHandle.prototype.getExternalAPI(self)
    return {
        player = self.context.player.entityPlayer,
        playerIndex = self.context.player.index,
        stat = self.context.stat:getExternalAPI(),
        computables = self.context.computables:getExternalAPI(),
        conditions = self.context.conditions:getExternalAPI(),
        settings = self.context.settings:getExternalAPI(),
        state = self.context.state:getExternalAPI()
    }
end
return ____exports
