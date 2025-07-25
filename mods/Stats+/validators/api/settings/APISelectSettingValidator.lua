local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray
local __TS__TypeOf = ____lualib.__TS__TypeOf
local __TS__New = ____lualib.__TS__New
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____APISettingCommonValidator = require("validators.api.settings.APISettingCommonValidator")
local APISettingCommonValidator = ____APISettingCommonValidator.APISettingCommonValidator
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
____exports.APISelectSettingValidator = __TS__Class()
local APISelectSettingValidator = ____exports.APISelectSettingValidator
APISelectSettingValidator.name = "APISelectSettingValidator"
function APISelectSettingValidator.prototype.____constructor(self, apiSettingCommonValidator)
    self.apiSettingCommonValidator = apiSettingCommonValidator
end
__TS__DecorateLegacy(
    {__TS__DecorateParam(
        0,
        Inject(nil, APISettingCommonValidator)
    )},
    APISelectSettingValidator
)
function APISelectSettingValidator.prototype.validateSelectSetting(self, select)
    return {
        type = "SELECT",
        options = self:validateOptions(select and select.options),
        name = self.apiSettingCommonValidator:validateName(select and select.name),
        description = self.apiSettingCommonValidator:validateDescription(select and select.description),
        initial = self.apiSettingCommonValidator:validateInitialValueGetter(select and select.initial)
    }
end
function APISelectSettingValidator.prototype.validateOptions(self, options)
    if not __TS__ArrayIsArray(options) then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected select setting options (`.options`) to be an array.",
                {
                    options = options,
                    optionsType = __TS__TypeOf(options)
                }
            ),
            0
        )
    end
    return __TS__ArrayMap(
        options,
        function(____, option) return self:validateOption(option) end
    )
end
function APISelectSettingValidator.prototype.validateOption(self, option)
    if type(option) ~= "table" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected select setting options element to be an object.",
                {
                    option = option,
                    optionType = __TS__TypeOf(option)
                }
            ),
            0
        )
    end
    if type(option and option.name) ~= "string" or #option.name == 0 then
        error(
            __TS__New(Error, "Expected select setting option's name to be a non-empty string."),
            0
        )
    end
    if type(option and option.value) ~= "string" and type(option and option.value) ~= "boolean" and type(option and option.value) ~= "number" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected select setting option's value to be either a string, a number or a boolean",
                {
                    optionName = option and option.name,
                    optionValue = option and option.value,
                    optionValueType = __TS__TypeOf(option and option.value)
                }
            ),
            0
        )
    end
    return option
end
APISelectSettingValidator = __TS__DecorateLegacy(
    {Singleton(nil)},
    APISelectSettingValidator
)
____exports.APISelectSettingValidator = APISelectSettingValidator
return ____exports
