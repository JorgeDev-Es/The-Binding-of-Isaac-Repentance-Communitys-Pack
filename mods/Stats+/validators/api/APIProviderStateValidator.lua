local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__TypeOf = ____lualib.__TS__TypeOf
local __TS__New = ____lualib.__TS__New
local __TS__ObjectEntries = ____lualib.__TS__ObjectEntries
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ObjectFromEntries = ____lualib.__TS__ObjectFromEntries
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
____exports.APIProviderStateValidator = __TS__Class()
local APIProviderStateValidator = ____exports.APIProviderStateValidator
APIProviderStateValidator.name = "APIProviderStateValidator"
function APIProviderStateValidator.prototype.____constructor(self)
end
function APIProviderStateValidator.prototype.validateState(self, state)
    if state == nil then
        return nil
    end
    if type(state) ~= "table" or state == nil then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider state (`.state`) to be an object.",
                {
                    state = state,
                    stateType = __TS__TypeOf(state)
                }
            ),
            0
        )
    end
    return __TS__ObjectFromEntries(__TS__ArrayMap(
        __TS__ObjectEntries(state),
        function(____, ____bindingPattern0)
            local entry
            local key
            key = ____bindingPattern0[1]
            entry = ____bindingPattern0[2]
            return {
                key,
                self:validateStateEntry(entry)
            }
        end
    ))
end
function APIProviderStateValidator.prototype.validateStateEntry(self, stateEntry)
    local persistent = self:validatePersistent(stateEntry and stateEntry.persistent)
    local ____persistent_9 = persistent
    local ____self_validateEncoder_6 = self.validateEncoder
    local ____temp_5 = stateEntry and stateEntry.encoder
    local ____persistent_4 = persistent
    if ____persistent_4 == nil then
        ____persistent_4 = false
    end
    return {
        persistent = ____persistent_9,
        encoder = ____self_validateEncoder_6(self, ____temp_5, ____persistent_4),
        initial = self:validateInitialValueGetter(stateEntry and stateEntry.initial)
    }
end
function APIProviderStateValidator.prototype.validatePersistent(self, persistent)
    if persistent == nil then
        return nil
    end
    if type(persistent) ~= "boolean" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected provider state persistency (`.persistent`) to be a boolean.",
                {
                    persistent = persistent,
                    persistentType = __TS__TypeOf(persistent)
                }
            ),
            0
        )
    end
    return persistent
end
function APIProviderStateValidator.prototype.validateEncoder(self, stateEncoder, isPersistent)
    if stateEncoder == nil then
        return nil
    end
    if not isPersistent then
        error(
            __TS__New(Error, "Expected state encoder (`.encoder`) to not be defined for non-persistent state entries."),
            0
        )
    end
    return {
        encode = self:validateEncodeFunction(stateEncoder and stateEncoder.encode),
        decode = self:validateDecodeFunction(stateEncoder and stateEncoder.decode)
    }
end
function APIProviderStateValidator.prototype.validateEncodeFunction(self, encode)
    if type(encode) ~= "function" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected state encoder encode function (`.encode`) to be a function.",
                {
                    encode = encode,
                    encodeType = __TS__TypeOf(encode)
                }
            ),
            0
        )
    end
    return encode
end
function APIProviderStateValidator.prototype.validateDecodeFunction(self, decode)
    if type(decode) ~= "function" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected state encoder decode function (`.decode`) to be a function.",
                {
                    decode = decode,
                    decodeType = __TS__TypeOf(decode)
                }
            ),
            0
        )
    end
    return decode
end
function APIProviderStateValidator.prototype.validateInitialValueGetter(self, initial)
    if type(initial) ~= "function" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected state initial value getter (`.initial`) to be a function.",
                {initialValueGetterType = __TS__TypeOf(initial)}
            ),
            0
        )
    end
    return initial
end
APIProviderStateValidator = __TS__DecorateLegacy(
    {Singleton(nil)},
    APIProviderStateValidator
)
____exports.APIProviderStateValidator = APIProviderStateValidator
return ____exports
