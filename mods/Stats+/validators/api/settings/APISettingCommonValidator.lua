local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__TypeOf = ____lualib.__TS__TypeOf
local __TS__New = ____lualib.__TS__New
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
____exports.APISettingCommonValidator = __TS__Class()
local APISettingCommonValidator = ____exports.APISettingCommonValidator
APISettingCommonValidator.name = "APISettingCommonValidator"
function APISettingCommonValidator.prototype.____constructor(self)
end
function APISettingCommonValidator.prototype.validateName(self, name)
    if type(name) ~= "string" or #name == 0 then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected setting name (`.name`) to be a non-empty string.",
                {
                    name = name,
                    nameType = __TS__TypeOf(name)
                }
            ),
            0
        )
    end
    return name
end
function APISettingCommonValidator.prototype.validateDescription(self, description)
    if type(description) ~= "string" or #description == 0 then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected setting description (`.description`) to be a non-empty string.",
                {
                    description = description,
                    descriptionType = __TS__TypeOf(description)
                }
            ),
            0
        )
    end
    return description
end
function APISettingCommonValidator.prototype.validateInitialValueGetter(self, initial)
    if type(initial) ~= "function" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected setting initial value getter (`.initial`) to be a function.",
                {initialValueGetterType = __TS__TypeOf(initial)}
            ),
            0
        )
    end
    return initial
end
APISettingCommonValidator = __TS__DecorateLegacy(
    {Singleton(nil)},
    APISettingCommonValidator
)
____exports.APISettingCommonValidator = APISettingCommonValidator
return ____exports
