local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ObjectEntries = ____lualib.__TS__ObjectEntries
local ____exports = {}
____exports.ProviderStateDefinition = __TS__Class()
local ProviderStateDefinition = ____exports.ProviderStateDefinition
ProviderStateDefinition.name = "ProviderStateDefinition"
function ProviderStateDefinition.prototype.____constructor(self, stateList)
    self.stateList = stateList
end
function ProviderStateDefinition.prototype.entries(self)
    return __TS__ObjectEntries(self.stateList or ({}))
end
function ProviderStateDefinition.prototype.getExternalAPI(self)
    return self.stateList
end
function ProviderStateDefinition.prototype.getByKey(self, key)
    local ____opt_0 = self.stateList
    return ____opt_0 and ____opt_0[key]
end
return ____exports
