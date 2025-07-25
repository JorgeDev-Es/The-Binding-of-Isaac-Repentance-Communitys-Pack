local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.LoadoutEntry = __TS__Class()
local LoadoutEntry = ____exports.LoadoutEntry
LoadoutEntry.name = "LoadoutEntry"
function LoadoutEntry.prototype.____constructor(self, statSlot, condition, primaryProvider, secondaryProvider)
    self.statSlot = statSlot
    self.condition = condition
    self.primaryProvider = primaryProvider
    self.secondaryProvider = secondaryProvider
end
function LoadoutEntry.prototype.getActiveProvider(self)
    return self.condition:isActive() and self.primaryProvider or self.secondaryProvider
end
function LoadoutEntry.prototype.getInactiveProvider(self)
    return self.condition:isActive() and self.secondaryProvider or self.primaryProvider
end
function LoadoutEntry.prototype.unregister(self)
    self.condition:unregister()
    self.primaryProvider:unregister()
    self.secondaryProvider:unregister()
end
return ____exports
