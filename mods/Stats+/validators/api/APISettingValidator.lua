local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____APIToggleSettingValidator = require("validators.api.settings.APIToggleSettingValidator")
local APIToggleSettingValidator = ____APIToggleSettingValidator.APIToggleSettingValidator
local ____APISelectSettingValidator = require("validators.api.settings.APISelectSettingValidator")
local APISelectSettingValidator = ____APISelectSettingValidator.APISelectSettingValidator
local ____APIRangeSettingValidator = require("validators.api.settings.APIRangeSettingValidator")
local APIRangeSettingValidator = ____APIRangeSettingValidator.APIRangeSettingValidator
____exports.APISettingValidator = __TS__Class()
local APISettingValidator = ____exports.APISettingValidator
APISettingValidator.name = "APISettingValidator"
function APISettingValidator.prototype.____constructor(self, apiToggleSettingValidator, apiSelectSettingValidator, apiRangeSettingValidator)
    self.apiToggleSettingValidator = apiToggleSettingValidator
    self.apiSelectSettingValidator = apiSelectSettingValidator
    self.apiRangeSettingValidator = apiRangeSettingValidator
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, APIToggleSettingValidator)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, APISelectSettingValidator)
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, APIRangeSettingValidator)
        )
    },
    APISettingValidator
)
function APISettingValidator.prototype.validateSetting(self, setting)
    if (setting and setting.type) == "TOGGLE" then
        return self:validateToggleSetting(setting)
    end
    if (setting and setting.type) == "RANGE" then
        return self:validateRangeSetting(setting)
    end
    if (setting and setting.type) == "SELECT" then
        return self:validateSelectSetting(setting)
    end
    error(
        __TS__New(ErrorWithContext, "Unknown setting type.", {settingType = setting and setting.type}),
        0
    )
end
function APISettingValidator.prototype.validateToggleSetting(self, toggle)
    return self.apiToggleSettingValidator:validateToggleSetting(toggle)
end
function APISettingValidator.prototype.validateSelectSetting(self, select)
    return self.apiSelectSettingValidator:validateSelectSetting(select)
end
function APISettingValidator.prototype.validateRangeSetting(self, range)
    return self.apiRangeSettingValidator:validateRangeSetting(range)
end
APISettingValidator = __TS__DecorateLegacy(
    {Singleton(nil)},
    APISettingValidator
)
____exports.APISettingValidator = APISettingValidator
return ____exports
