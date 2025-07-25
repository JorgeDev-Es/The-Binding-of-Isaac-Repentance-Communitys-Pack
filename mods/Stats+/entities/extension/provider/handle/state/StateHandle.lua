local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____ProviderStatePersistentEntry = require("entities.extension.provider.handle.state.entry.ProviderStatePersistentEntry")
local ProviderStatePersistentEntry = ____ProviderStatePersistentEntry.ProviderStatePersistentEntry
local ____ProviderStateMemoryEntry = require("entities.extension.provider.handle.state.entry.ProviderStateMemoryEntry")
local ProviderStateMemoryEntry = ____ProviderStateMemoryEntry.ProviderStateMemoryEntry
____exports.StateHandle = __TS__Class()
local StateHandle = ____exports.StateHandle
StateHandle.name = "StateHandle"
function StateHandle.prototype.____constructor(self, providerExtension, definition, key, stateEncoder, configService)
    self.providerExtension = providerExtension
    self.definition = definition
    self.key = key
    self.stateEncoder = stateEncoder
    self.configService = configService
    self.value = self.definition.persistent == true and __TS__New(
        ProviderStatePersistentEntry,
        self.providerExtension,
        self.key,
        self.stateEncoder,
        self.configService
    ) or __TS__New(ProviderStateMemoryEntry)
    if self.value:getValue() == nil then
        self.value:setValue(self.definition.initial())
    end
end
function StateHandle.prototype.getExternalAPI(self)
    return {
        current = function()
            local ____temp_0 = self.value:getValue()
            if ____temp_0 == nil then
                ____temp_0 = self.definition.initial()
            end
            return ____temp_0
        end,
        reset = function() return self.value:setValue(self.definition.initial()) end,
        set = function(____, value) return self.value:setValue(value) end
    }
end
return ____exports
