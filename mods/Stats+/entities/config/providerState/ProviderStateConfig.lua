local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
____exports.ProviderStateConfig = __TS__Class()
local ProviderStateConfig = ____exports.ProviderStateConfig
ProviderStateConfig.name = "ProviderStateConfig"
function ProviderStateConfig.prototype.____constructor(self, options)
    self.providerState = options.providerState
end
function ProviderStateConfig.prototype.clone(self)
    return __TS__New(
        ____exports.ProviderStateConfig,
        {providerState = self.providerState:clone()}
    )
end
function ProviderStateConfig.prototype.getProviderStateMap(self)
    return self.providerState:clone()
end
function ProviderStateConfig.prototype.get(self, provider, key)
    local ____opt_0 = self.providerState:get(provider)
    return ____opt_0 and ____opt_0[key]
end
function ProviderStateConfig.prototype.set(self, provider, key, value)
    local state = self.providerState:get(provider) or ({})
    state[key] = value
    self.providerState:set(provider, state)
end
return ____exports
