local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____isExtensionRef = require("util.validation.isExtensionRef")
local isExtensionRef = ____isExtensionRef.isExtensionRef
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
____exports.ProviderStateConfigDTOValidator = __TS__Class()
local ProviderStateConfigDTOValidator = ____exports.ProviderStateConfigDTOValidator
ProviderStateConfigDTOValidator.name = "ProviderStateConfigDTOValidator"
function ProviderStateConfigDTOValidator.prototype.____constructor(self)
    self.logger = Logger["for"](Logger, ____exports.ProviderStateConfigDTOValidator.name)
end
function ProviderStateConfigDTOValidator.prototype.validate(self, state)
    if state == nil or not __TS__ArrayIsArray(state.state) then
        self.logger:warn("Expected provider state to be an array.")
        return {state = {}}
    end
    return {state = __TS__ArrayFilter(
        __TS__ArrayMap(
            state.state,
            function(____, entry) return self:validateEntry(entry) end
        ),
        function(____, entry) return entry ~= nil end
    )}
end
function ProviderStateConfigDTOValidator.prototype.validateEntry(self, entry)
    if type(entry) ~= "table" then
        self.logger:warn("Expected provider state entry to be an object.")
        return
    end
    if not isExtensionRef(nil, entry.ref) then
        self.logger:warn("Expected entry ref to be a valid extension ref object.")
        return
    end
    if entry.state == nil or type(entry.state) ~= "table" or __TS__ArrayIsArray(entry.state) then
        self.logger:warn("Expected entry state to be an object.")
        return
    end
    return {ref = entry.ref, state = entry.state}
end
ProviderStateConfigDTOValidator = __TS__DecorateLegacy(
    {Singleton(nil)},
    ProviderStateConfigDTOValidator
)
____exports.ProviderStateConfigDTOValidator = ProviderStateConfigDTOValidator
return ____exports
