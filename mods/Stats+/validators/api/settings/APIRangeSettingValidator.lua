local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__TypeOf = ____lualib.__TS__TypeOf
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____APISettingCommonValidator = require("validators.api.settings.APISettingCommonValidator")
local APISettingCommonValidator = ____APISettingCommonValidator.APISettingCommonValidator
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
____exports.APIRangeSettingValidator = __TS__Class()
local APIRangeSettingValidator = ____exports.APIRangeSettingValidator
APIRangeSettingValidator.name = "APIRangeSettingValidator"
function APIRangeSettingValidator.prototype.____constructor(self, apiSettingCommonValidator)
    self.apiSettingCommonValidator = apiSettingCommonValidator
end
__TS__DecorateLegacy(
    {__TS__DecorateParam(
        0,
        Inject(nil, APISettingCommonValidator)
    )},
    APIRangeSettingValidator
)
function APIRangeSettingValidator.prototype.validateRangeSetting(self, range)
    local min, max = table.unpack(self:validateMinAndMaxValues(range and range.min, range and range.max))
    return {
        type = "RANGE",
        min = min,
        max = max,
        name = self.apiSettingCommonValidator:validateName(range and range.name),
        description = self.apiSettingCommonValidator:validateDescription(range and range.description),
        initial = self.apiSettingCommonValidator:validateInitialValueGetter(range and range.initial)
    }
end
function APIRangeSettingValidator.prototype.validateMinAndMaxValues(self, min, max)
    if type(min) ~= "number" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected range setting min value (`.min`) to be a number.",
                {
                    min = min,
                    minType = __TS__TypeOf(min)
                }
            ),
            0
        )
    end
    if type(max) ~= "number" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected range setting max value (`.max`) to be a number.",
                {
                    max = max,
                    maxType = __TS__TypeOf(max)
                }
            ),
            0
        )
    end
    if min >= max then
        error(
            __TS__New(ErrorWithContext, "Expected range setting min value (`.min`) to be greater than the max value (`.max`).", {min = min, max = max}),
            0
        )
    end
    return {min, max}
end
APIRangeSettingValidator = __TS__DecorateLegacy(
    {Singleton(nil)},
    APIRangeSettingValidator
)
____exports.APIRangeSettingValidator = APIRangeSettingValidator
return ____exports
