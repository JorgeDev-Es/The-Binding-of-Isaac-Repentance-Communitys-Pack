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
____exports.APIConditionValidator = __TS__Class()
local APIConditionValidator = ____exports.APIConditionValidator
APIConditionValidator.name = "APIConditionValidator"
function APIConditionValidator.prototype.____constructor(self)
end
function APIConditionValidator.prototype.validateStandaloneCondition(self, condition)
    return {
        id = self:validateId(condition and condition.id),
        name = self:validateName(condition and condition.name),
        description = self:validateDescription(condition and condition.description),
        mount = self:validateMountFunction(condition and condition.mount)
    }
end
function APIConditionValidator.prototype.validateCompanionCondition(self, condition)
    return {
        id = self:validateId(condition and condition.id),
        name = self:validateName(condition and condition.name),
        description = self:validateDescription(condition and condition.description)
    }
end
function APIConditionValidator.prototype.validateId(self, id)
    if type(id) ~= "string" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected condition id (`.id`) to be a string.",
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
            __TS__New(Error, "Expected condition id (`.id`) to not be empty."),
            0
        )
    end
    if not isValidId(nil, id) then
        error(
            __TS__New(ErrorWithContext, "Expected condition id (`.id`) to contain only lowercase letters, digits and hyphen-minus signs.", {id = id}),
            0
        )
    end
    return id
end
function APIConditionValidator.prototype.validateName(self, name)
    if type(name) ~= "string" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected condition name (`.name`) to be a string.",
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
            __TS__New(Error, "Expected condition name (`.name`) to not be empty."),
            0
        )
    end
    return name
end
function APIConditionValidator.prototype.validateDescription(self, description)
    if type(description) ~= "string" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected condition description (`.description`) to be a string.",
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
            __TS__New(Error, "Expected condition description (`.description`) to not be empty."),
            0
        )
    end
    return description
end
function APIConditionValidator.prototype.validateMountFunction(self, mount)
    if type(mount) ~= "function" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected condition mount function (`.mount`) to be a function.",
                {
                    mount = mount,
                    mountType = __TS__TypeOf(mount)
                }
            ),
            0
        )
    end
    return mount
end
APIConditionValidator = __TS__DecorateLegacy(
    {Singleton(nil)},
    APIConditionValidator
)
____exports.APIConditionValidator = APIConditionValidator
return ____exports
