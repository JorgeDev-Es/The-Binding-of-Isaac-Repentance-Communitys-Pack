local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____APISettingCommonValidator = require("validators.api.settings.APISettingCommonValidator")
local APISettingCommonValidator = ____APISettingCommonValidator.APISettingCommonValidator
____exports.APIToggleSettingValidator = __TS__Class()
local APIToggleSettingValidator = ____exports.APIToggleSettingValidator
APIToggleSettingValidator.name = "APIToggleSettingValidator"
function APIToggleSettingValidator.prototype.____constructor(self, apiSettingCommonValidator)
    self.apiSettingCommonValidator = apiSettingCommonValidator
end
__TS__DecorateLegacy(
    {__TS__DecorateParam(
        0,
        Inject(nil, APISettingCommonValidator)
    )},
    APIToggleSettingValidator
)
function APIToggleSettingValidator.prototype.validateToggleSetting(self, toggle)
    return {
        type = "TOGGLE",
        name = self.apiSettingCommonValidator:validateName(toggle and toggle.name),
        description = self.apiSettingCommonValidator:validateDescription(toggle and toggle.description),
        initial = self.apiSettingCommonValidator:validateInitialValueGetter(toggle and toggle.initial)
    }
end
APIToggleSettingValidator = __TS__DecorateLegacy(
    {Singleton(nil)},
    APIToggleSettingValidator
)
____exports.APIToggleSettingValidator = APIToggleSettingValidator
return ____exports
