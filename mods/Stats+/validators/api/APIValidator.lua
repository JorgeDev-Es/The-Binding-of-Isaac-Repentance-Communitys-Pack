local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____APIAddonValidator = require("validators.api.APIAddonValidator")
local APIAddonValidator = ____APIAddonValidator.APIAddonValidator
local ____APIProviderValidator = require("validators.api.APIProviderValidator")
local APIProviderValidator = ____APIProviderValidator.APIProviderValidator
local ____APIConditionValidator = require("validators.api.APIConditionValidator")
local APIConditionValidator = ____APIConditionValidator.APIConditionValidator
local ____APIMiddlewareValidator = require("validators.api.APIMiddlewareValidator")
local APIMiddlewareValidator = ____APIMiddlewareValidator.APIMiddlewareValidator
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____APISettingValidator = require("validators.api.APISettingValidator")
local APISettingValidator = ____APISettingValidator.APISettingValidator
____exports.APIValidator = __TS__Class()
local APIValidator = ____exports.APIValidator
APIValidator.name = "APIValidator"
function APIValidator.prototype.____constructor(self, apiAddonValidator, apiProviderValidator, apiSettingValidator, apiConditionValidator, apiMiddlewareValidator)
    self.apiAddonValidator = apiAddonValidator
    self.apiProviderValidator = apiProviderValidator
    self.apiSettingValidator = apiSettingValidator
    self.apiConditionValidator = apiConditionValidator
    self.apiMiddlewareValidator = apiMiddlewareValidator
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, APIAddonValidator)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, APIProviderValidator)
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, APISettingValidator)
        ),
        __TS__DecorateParam(
            3,
            Inject(nil, APIConditionValidator)
        ),
        __TS__DecorateParam(
            4,
            Inject(nil, APIMiddlewareValidator)
        )
    },
    APIValidator
)
function APIValidator.prototype.validateAddon(self, addon)
    return self.apiAddonValidator:validate(addon)
end
function APIValidator.prototype.validateProvider(self, provider)
    return self.apiProviderValidator:validate(provider)
end
function APIValidator.prototype.validateToggleSetting(self, toggle)
    return self.apiSettingValidator:validateToggleSetting(toggle)
end
function APIValidator.prototype.validateSelectSetting(self, select)
    return self.apiSettingValidator:validateSelectSetting(select)
end
function APIValidator.prototype.validateRangeSetting(self, range)
    return self.apiSettingValidator:validateRangeSetting(range)
end
function APIValidator.prototype.validateCondition(self, condition)
    return self.apiConditionValidator:validateStandaloneCondition(condition)
end
function APIValidator.prototype.validateMiddleware(self, middleware)
    return self.apiMiddlewareValidator:validate(middleware)
end
APIValidator = __TS__DecorateLegacy(
    {Singleton(nil)},
    APIValidator
)
____exports.APIValidator = APIValidator
return ____exports
