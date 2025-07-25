local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__ClassExtends = ____lualib.__TS__ClassExtends
local __TS__InstanceOf = ____lualib.__TS__InstanceOf
local ____exports = {}
local ____tryCatch = require("util.functional.tryCatch")
local tryCatch = ____tryCatch.tryCatch
____exports.ErrorWithContext = __TS__Class()
local ErrorWithContext = ____exports.ErrorWithContext
ErrorWithContext.name = "ErrorWithContext"
__TS__ClassExtends(ErrorWithContext, Error)
function ErrorWithContext.prototype.____constructor(self, message, context, relatedError)
    Error.prototype.____constructor(self, message)
    self.context = context
    self.relatedError = relatedError
end
function ErrorWithContext.prototype.getFullMessage(self, jsonSerializer)
    local encodedContext = tryCatch(
        nil,
        function() return jsonSerializer:encode(self.context) end,
        function() return "(context encode error)" end
    )
    if self.relatedError == nil then
        return ((self.message .. " (") .. encodedContext) .. ")"
    end
    local relatedErrorMessage = __TS__InstanceOf(self.relatedError, ____exports.ErrorWithContext) and self.relatedError:getFullMessage(jsonSerializer) or (self.relatedError.message or tostring(self.relatedError))
    return (((self.message .. " (") .. encodedContext) .. ") -> ") .. relatedErrorMessage
end
return ____exports
