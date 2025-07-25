local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__ArraySlice = ____lualib.__TS__ArraySlice
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__InstanceOf = ____lualib.__TS__InstanceOf
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
local ____InjectionToken = require("app.ioc.InjectionToken")
local InjectionToken = ____InjectionToken.InjectionToken
____exports.ModCallbackService = __TS__Class()
local ModCallbackService = ____exports.ModCallbackService
ModCallbackService.name = "ModCallbackService"
function ModCallbackService.prototype.____constructor(self, jsonSerializer, mod)
    self.jsonSerializer = jsonSerializer
    self.mod = mod
    self.logger = Logger["for"](Logger, ____exports.ModCallbackService.name)
    self.callbackToWrappedCallbackMapping = __TS__New(Map)
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, InjectionToken.JsonSerializer)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, InjectionToken.ModAPI)
        )
    },
    ModCallbackService
)
function ModCallbackService.prototype.addCallback(self, callbackType, ...)
    local callbackData = {...}
    self.logger:debug("Adding a callback.", {callbackType = callbackType})
    local ____callbackData_0 = callbackData
    local callbackFn = ____callbackData_0[1]
    local callbackArgs = __TS__ArraySlice(____callbackData_0, 1)
    local wrappedCallbackFn = self:wrapCallbackWithErrorLogging(callbackType, callbackFn)
    self.callbackToWrappedCallbackMapping:set(callbackFn, wrappedCallbackFn)
    self.mod:AddCallback(
        callbackType,
        wrappedCallbackFn,
        table.unpack(callbackArgs)
    )
    self.logger:debug("Successfully added a callback.", {callbackType = callbackType})
end
function ModCallbackService.prototype.addPriorityCallback(self, callbackType, priority, ...)
    local callbackData = {...}
    self.logger:debug("Adding a priority callback.", {callbackType = callbackType})
    local ____callbackData_1 = callbackData
    local callbackFn = ____callbackData_1[1]
    local callbackArgs = __TS__ArraySlice(____callbackData_1, 1)
    local wrappedCallbackFn = self:wrapCallbackWithErrorLogging(callbackType, callbackFn)
    self.callbackToWrappedCallbackMapping:set(callbackFn, wrappedCallbackFn)
    self.mod:AddPriorityCallback(
        callbackType,
        priority,
        wrappedCallbackFn,
        table.unpack(callbackArgs)
    )
    self.logger:debug("Successfully added a priority callback.", {callbackType = callbackType})
end
function ModCallbackService.prototype.removeCallback(self, callbackType, callbackFn)
    self.logger:debug("Removing a callback.", {callbackType = callbackType})
    local wrappedCallbackFn = self.callbackToWrappedCallbackMapping:get(callbackFn)
    if wrappedCallbackFn == nil then
        return
    end
    self.callbackToWrappedCallbackMapping:delete(callbackFn)
    self.mod:RemoveCallback(callbackType, wrappedCallbackFn)
    self.logger:debug("Successfully removed a callback.", {callbackType = callbackType})
end
function ModCallbackService.prototype.wrapCallbackWithErrorLogging(self, callbackType, callbackFn)
    return function(____, ...)
        local args = {...}
        do
            local function ____catch(e)
                local err = __TS__InstanceOf(e, Error) and e or __TS__New(
                    Error,
                    self.jsonSerializer:encode(e)
                )
                error(
                    __TS__New(ErrorWithContext, "Uncaught error in mod callback", {callbackType = callbackType}, err):getFullMessage(self.jsonSerializer),
                    0
                )
            end
            local ____try, ____hasReturned, ____returnValue = pcall(function()
                return true, callbackFn(
                    nil,
                    table.unpack(args)
                )
            end)
            if not ____try then
                ____hasReturned, ____returnValue = ____catch(____hasReturned)
            end
            if ____hasReturned then
                return ____returnValue
            end
        end
    end
end
ModCallbackService = __TS__DecorateLegacy(
    {Singleton(nil)},
    ModCallbackService
)
____exports.ModCallbackService = ModCallbackService
return ____exports
