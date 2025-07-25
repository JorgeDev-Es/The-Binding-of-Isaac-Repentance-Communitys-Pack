local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.ProviderStateMemoryEntry = __TS__Class()
local ProviderStateMemoryEntry = ____exports.ProviderStateMemoryEntry
ProviderStateMemoryEntry.name = "ProviderStateMemoryEntry"
function ProviderStateMemoryEntry.prototype.____constructor(self)
end
function ProviderStateMemoryEntry.prototype.getValue(self)
    return self.value
end
function ProviderStateMemoryEntry.prototype.setValue(self, value)
    self.value = value
end
return ____exports
