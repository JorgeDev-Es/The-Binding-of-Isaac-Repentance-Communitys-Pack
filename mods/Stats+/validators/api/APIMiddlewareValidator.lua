local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__TypeOf = ____lualib.__TS__TypeOf
local __TS__New = ____lualib.__TS__New
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
local ____isValidId = require("util.validation.isValidId")
local isValidId = ____isValidId.isValidId
____exports.APIMiddlewareValidator = __TS__Class()
local APIMiddlewareValidator = ____exports.APIMiddlewareValidator
APIMiddlewareValidator.name = "APIMiddlewareValidator"
function APIMiddlewareValidator.prototype.____constructor(self)
end
function APIMiddlewareValidator.prototype.validate(self, middleware)
    return {
        id = self:validateId(middleware and middleware.id),
        name = self:validateName(middleware and middleware.name),
        description = self:validateDescription(middleware and middleware.description),
        target = self:validateTarget(middleware and middleware.target),
        priority = self:validatePriority(middleware and middleware.priority),
        intercept = self:validateIntercept(middleware and middleware.intercept)
    }
end
function APIMiddlewareValidator.prototype.validateId(self, id)
    if type(id) ~= "string" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected middleware id (`.id`) to be a string.",
                {
                    id = id,
                    idType = __TS__TypeOf(id)
                }
            ),
            0
        )
    end
    if #id == 0 then
        error(
            __TS__New(Error, "Expected middleware id (`.id`) to not be an empty string."),
            0
        )
    end
    if not isValidId(nil, id) then
        error(
            __TS__New(ErrorWithContext, "Expected middleware id (`.id`) to contain only lowercase letters, digits and hyphen-minus signs.", {id = id}),
            0
        )
    end
    return id
end
function APIMiddlewareValidator.prototype.validateName(self, name)
    if type(name) ~= "string" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected middleware name (`.name`) to be a string.",
                {
                    name = name,
                    nameType = __TS__TypeOf(name)
                }
            ),
            0
        )
    end
    if #name == 0 then
        error(
            __TS__New(Error, "Expected middleware name (`.name`) to not be an empty string."),
            0
        )
    end
    return name
end
function APIMiddlewareValidator.prototype.validateDescription(self, description)
    if type(description) ~= "string" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected middleware description (`.description`) to be a string.",
                {
                    description = description,
                    descriptionType = __TS__TypeOf(description)
                }
            ),
            0
        )
    end
    if #description == 0 then
        error(
            __TS__New(Error, "Expected middleware description (`.description`) to not be empty."),
            0
        )
    end
    return description
end
function APIMiddlewareValidator.prototype.validateTarget(self, target)
    if type(target) ~= "table" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected computable target (`.target`) to be an object.",
                {
                    target = target,
                    targetType = __TS__TypeOf(target)
                }
            ),
            0
        )
    end
    local ____opt_12 = target.provider
    if type(____opt_12 and ____opt_12.addon) ~= "string" then
        local ____ErrorWithContext_19 = ErrorWithContext
        local ____opt_14 = target.provider
        local ____temp_18 = ____opt_14 and ____opt_14.addon
        local ____opt_16 = target.provider
        error(
            __TS__New(
                ____ErrorWithContext_19,
                "Expected computable target provider addon (`.target.provider.addon`) to be a string.",
                {
                    addon = ____temp_18,
                    addonType = __TS__TypeOf(____opt_16 and ____opt_16.addon)
                }
            ),
            0
        )
    end
    local ____opt_20 = target.provider
    if type(____opt_20 and ____opt_20.id) ~= "string" then
        local ____ErrorWithContext_24 = ErrorWithContext
        local ____opt_22 = target.provider
        error(
            __TS__New(
                ____ErrorWithContext_24,
                "Expected computable target provider id (`.target.provider.id`) to be a string.",
                {
                    id = ____opt_22 and ____opt_22.id,
                    idType = __TS__TypeOf(target.provider.id)
                }
            ),
            0
        )
    end
    if type(target.computable) ~= "string" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected computable target computable (`.target.computable`) to be a string.",
                {
                    computable = target.computable,
                    computableType = __TS__TypeOf(target.computable)
                }
            ),
            0
        )
    end
    return target
end
function APIMiddlewareValidator.prototype.validatePriority(self, priority)
    if type(priority) ~= "number" or priority % 1 > 0 then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected middleware priority (`.priority`) to be an integer number.",
                {
                    priority = priority,
                    priorityType = __TS__TypeOf(priority)
                }
            ),
            0
        )
    end
    if 0 > priority then
        error(
            __TS__New(ErrorWithContext, "Expected middleware priority (`.priority`) to be positive.", {priority = priority}),
            0
        )
    end
    return priority
end
function APIMiddlewareValidator.prototype.validateIntercept(self, intercept)
    if type(intercept) ~= "function" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected middleware intercept function (`.intercept`) to be a function.",
                {
                    intercept = intercept,
                    interceptType = __TS__TypeOf(intercept)
                }
            ),
            0
        )
    end
    return intercept
end
APIMiddlewareValidator = __TS__DecorateLegacy(
    {Singleton(nil)},
    APIMiddlewareValidator
)
____exports.APIMiddlewareValidator = APIMiddlewareValidator
return ____exports
