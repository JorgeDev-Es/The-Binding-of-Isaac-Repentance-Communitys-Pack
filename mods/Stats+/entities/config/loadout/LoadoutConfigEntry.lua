local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.LoadoutConfigEntry = __TS__Class()
local LoadoutConfigEntry = ____exports.LoadoutConfigEntry
LoadoutConfigEntry.name = "LoadoutConfigEntry"
function LoadoutConfigEntry.prototype.____constructor(self, options)
    self.stat = options.stat
    self.primaryProvider = options.primaryProvider
    self.secondaryProvider = options.secondaryProvider
    self.condition = options.condition
end
function LoadoutConfigEntry.prototype.getStat(self)
    return self.stat
end
function LoadoutConfigEntry.prototype.getPrimaryProvider(self)
    return self.primaryProvider
end
function LoadoutConfigEntry.prototype.setPrimaryProvider(self, provider)
    self.primaryProvider = provider
end
function LoadoutConfigEntry.prototype.getSecondaryProvider(self)
    return self.secondaryProvider
end
function LoadoutConfigEntry.prototype.setSecondaryProvider(self, provider)
    self.secondaryProvider = provider
end
function LoadoutConfigEntry.prototype.getCondition(self)
    return self.condition
end
function LoadoutConfigEntry.prototype.setCondition(self, condition)
    self.condition = condition
end
return ____exports
