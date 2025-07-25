local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__TypeOf = ____lualib.__TS__TypeOf
local __TS__New = ____lualib.__TS__New
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____APIProviderValidator = require("validators.api.APIProviderValidator")
local APIProviderValidator = ____APIProviderValidator.APIProviderValidator
local ____APIConditionValidator = require("validators.api.APIConditionValidator")
local APIConditionValidator = ____APIConditionValidator.APIConditionValidator
local ____APIMiddlewareValidator = require("validators.api.APIMiddlewareValidator")
local APIMiddlewareValidator = ____APIMiddlewareValidator.APIMiddlewareValidator
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
local ____isValidId = require("util.validation.isValidId")
local isValidId = ____isValidId.isValidId
____exports.APIAddonValidator = __TS__Class()
local APIAddonValidator = ____exports.APIAddonValidator
APIAddonValidator.name = "APIAddonValidator"
function APIAddonValidator.prototype.____constructor(self, apiProviderValidator, apiConditionValidator, apiMiddlewareValidator)
    self.apiProviderValidator = apiProviderValidator
    self.apiConditionValidator = apiConditionValidator
    self.apiMiddlewareValidator = apiMiddlewareValidator
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, APIProviderValidator)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, APIConditionValidator)
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, APIMiddlewareValidator)
        )
    },
    APIAddonValidator
)
function APIAddonValidator.prototype.validate(self, addon)
    return {
        id = self:validateId(addon and addon.id),
        name = self:validateName(addon and addon.name),
        providers = self:validateProviders(addon and addon.providers),
        conditions = self:validateConditions(addon and addon.conditions),
        middleware = self:validateMiddleware(addon and addon.middleware)
    }
end
function APIAddonValidator.prototype.validateId(self, addonId)
    if type(addonId) ~= "string" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected addon id (`.id`) to be a string.",
                {
                    addonId = addonId,
                    addonIdType = __TS__TypeOf(addonId)
                }
            ),
            0
        )
    end
    if #addonId == 0 then
        error(
            __TS__New(Error, "Expected addon id (`.id`) to not be of 0-length."),
            0
        )
    end
    if not isValidId(nil, addonId) then
        error(
            __TS__New(Error, "Expected addon id (`.id`) to contain only lowercase letters, digits and hyphen-minus signs."),
            0
        )
    end
    return addonId
end
function APIAddonValidator.prototype.validateName(self, addonName)
    if type(addonName) ~= "string" then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected addon name (`.name`) to be a string.",
                {
                    addonName = addonName,
                    addonNameType = __TS__TypeOf(addonName)
                }
            ),
            0
        )
    end
    if #addonName == 0 then
        error(
            __TS__New(Error, "Expected addon name (`.name`) to not be of 0-length."),
            0
        )
    end
    return addonName
end
function APIAddonValidator.prototype.validateProviders(self, providers)
    if providers == nil then
        return nil
    end
    if not __TS__ArrayIsArray(providers) then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected addon providers (`.providers`) to be an array.",
                {
                    providers = providers,
                    providersType = __TS__TypeOf(providers)
                }
            ),
            0
        )
    end
    return __TS__ArrayMap(
        providers,
        function(____, provider) return self.apiProviderValidator:validate(provider) end
    )
end
function APIAddonValidator.prototype.validateConditions(self, conditions)
    if conditions == nil then
        return conditions
    end
    if not __TS__ArrayIsArray(conditions) then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected addon conditions (`.conditions`) to be an array.",
                {
                    conditions = conditions,
                    conditionsType = __TS__TypeOf(conditions)
                }
            ),
            0
        )
    end
    return __TS__ArrayMap(
        conditions,
        function(____, condition) return self.apiConditionValidator:validateStandaloneCondition(condition) end
    )
end
function APIAddonValidator.prototype.validateMiddleware(self, middlewareArray)
    if middlewareArray == nil then
        return middlewareArray
    end
    if not __TS__ArrayIsArray(middlewareArray) then
        error(
            __TS__New(
                ErrorWithContext,
                "Expected addon middleware (`.middleware`) to be an array.",
                {
                    middleware = middlewareArray,
                    middlewareType = __TS__TypeOf(middlewareArray)
                }
            ),
            0
        )
    end
    return __TS__ArrayMap(
        middlewareArray,
        function(____, middleware) return self.apiMiddlewareValidator:validate(middleware) end
    )
end
APIAddonValidator = __TS__DecorateLegacy(
    {Singleton(nil)},
    APIAddonValidator
)
____exports.APIAddonValidator = APIAddonValidator
return ____exports
