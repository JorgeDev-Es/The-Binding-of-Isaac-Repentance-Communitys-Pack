local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.ProviderStatePersistentEntry = __TS__Class()
local ProviderStatePersistentEntry = ____exports.ProviderStatePersistentEntry
ProviderStatePersistentEntry.name = "ProviderStatePersistentEntry"
function ProviderStatePersistentEntry.prototype.____constructor(self, providerExtension, key, stateEncoder, configService)
    self.providerExtension = providerExtension
    self.key = key
    self.stateEncoder = stateEncoder
    self.configService = configService
end
function ProviderStatePersistentEntry.prototype.getValue(self)
    local encoded = self.configService:getConfig().providerState:get(self.providerExtension, self.key)
    if encoded == nil then
        return nil
    end
    return self.stateEncoder:decode(encoded)
end
function ProviderStatePersistentEntry.prototype.setValue(self, value)
    self.configService:updateConfig(function(____, config)
        config.providerState:set(
            self.providerExtension,
            self.key,
            self.stateEncoder:encode(value)
        )
    end)
end
return ____exports
