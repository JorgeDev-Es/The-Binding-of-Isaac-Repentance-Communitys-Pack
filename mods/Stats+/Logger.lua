local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____Transient = require("app.ioc.decorators.Transient")
local Transient = ____Transient.Transient
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
local ____APPLICATION_CONTAINER = require("app.APPLICATION_CONTAINER")
local APPLICATION_CONTAINER = ____APPLICATION_CONTAINER.APPLICATION_CONTAINER
local ____InjectionToken = require("app.ioc.InjectionToken")
local InjectionToken = ____InjectionToken.InjectionToken
local ____tryCatch = require("util.functional.tryCatch")
local tryCatch = ____tryCatch.tryCatch
____exports.Logger = __TS__Class()
local Logger = ____exports.Logger
Logger.name = "Logger"
function Logger.prototype.____constructor(self, isaac, jsonSerializer)
    self.isaac = isaac
    self.jsonSerializer = jsonSerializer
    self.nameSpace = ____exports.Logger.DEFAULT_NAMESPACE
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, InjectionToken.IsaacAPI)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, InjectionToken.JsonSerializer)
        )
    },
    Logger
)
Logger["for"] = function(self, id)
    local logger = APPLICATION_CONTAINER:resolve(____exports.Logger)
    logger:setNamespace(id)
    return logger
end
function Logger.prototype.setNamespace(self, nameSpace)
    self.nameSpace = nameSpace
end
function Logger.prototype.debug(self, message, context)
    self:logMessage(self:getFullMessage("DEBUG", message, context))
end
function Logger.prototype.info(self, message, context)
    self:logMessage(self:getFullMessage("INFO", message, context))
end
function Logger.prototype.warn(self, message, context)
    self:logMessage(self:getFullMessage("WARN", message, context))
end
function Logger.prototype.error(self, errorMessage, relatedError, context)
    local message = relatedError == nil and errorMessage or __TS__New(ErrorWithContext, errorMessage, context or ({}), relatedError):getFullMessage(self.jsonSerializer)
    self:logMessage(self:getFullMessage("ERROR", message))
end
function Logger.prototype.getFullMessage(self, logLevel, baseMessage, context)
    local messageWithoutContext = (((((("(" .. logLevel) .. ") [") .. ____exports.Logger.LOG_MESSAGE_PREFIX) .. "@") .. self.nameSpace) .. "] ") .. baseMessage
    if context == nil then
        return messageWithoutContext
    end
    local encodedContext = tryCatch(
        nil,
        function() return self.jsonSerializer:encode(context) end,
        function() return "(context encode error)" end
    )
    return (messageWithoutContext .. " | ") .. encodedContext
end
function Logger.prototype.logMessage(self, message)
    self.isaac.DebugString(message)
    if ____exports.Logger.LOG_TO_CONSOLE_DEVELOPMENT_FLAG then
        print(message)
    end
end
Logger.LOG_TO_CONSOLE_DEVELOPMENT_FLAG = false
Logger.LOG_MESSAGE_PREFIX = "Stats+"
Logger.DEFAULT_NAMESPACE = "?"
Logger = __TS__DecorateLegacy(
    {Transient(nil)},
    Logger
)
____exports.Logger = Logger
return ____exports
