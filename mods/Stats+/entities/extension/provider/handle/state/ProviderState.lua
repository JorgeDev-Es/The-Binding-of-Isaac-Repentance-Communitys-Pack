local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ObjectFromEntries = ____lualib.__TS__ObjectFromEntries
local ____exports = {}
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
____exports.ProviderState = __TS__Class()
local ProviderState = ____exports.ProviderState
ProviderState.name = "ProviderState"
function ProviderState.prototype.____constructor(self, definition, handles, displayStateHandle)
    self.definition = definition
    self.handles = handles
    self.displayStateHandle = displayStateHandle
end
function ProviderState.prototype.getExternalAPI(self)
    local entries = __TS__ArrayMap(
        self.definition:entries(),
        function(____, ____bindingPattern0)
            local state
            local stateIdentifier
            stateIdentifier = ____bindingPattern0[1]
            state = ____bindingPattern0[2]
            local ____stateIdentifier_2 = stateIdentifier
            local ____opt_0 = self.displayStateHandle
            if ____stateIdentifier_2 == (____opt_0 and ____opt_0:getKey()) then
                return {
                    stateIdentifier,
                    self:getDisplayStateHandle():getExternalAPI()
                }
            end
            local handle = self.handles:get(state)
            if handle == nil then
                error(
                    __TS__New(ErrorWithContext, "Could not find an internal state handle for the provider state.", {stateIdentifier = stateIdentifier}),
                    0
                )
            end
            return {
                stateIdentifier,
                handle:getExternalAPI()
            }
        end
    )
    return __TS__ObjectFromEntries(entries)
end
function ProviderState.prototype.getDisplayStateHandle(self)
    return self.displayStateHandle
end
return ____exports
