local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__FunctionBind = ____lualib.__TS__FunctionBind
local __TS__New = ____lualib.__TS__New
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local ModCallback = ____isaac_2Dtypescript_2Ddefinitions.ModCallback
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
local ____LifecycleService = require("services.LifecycleService")
local LifecycleService = ____LifecycleService.LifecycleService
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____ModCallbackService = require("services.ModCallbackService")
local ModCallbackService = ____ModCallbackService.ModCallbackService
local ____ExtensionService = require("services.extension.ExtensionService")
local ExtensionService = ____ExtensionService.ExtensionService
local ____StandaloneConditionDefinition = require("entities.extension.condition.standalone.StandaloneConditionDefinition")
local StandaloneConditionDefinition = ____StandaloneConditionDefinition.StandaloneConditionDefinition
local ____Middleware = require("entities.extension.middleware.Middleware")
local Middleware = ____Middleware.Middleware
local ____InjectionToken = require("app.ioc.InjectionToken")
local InjectionToken = ____InjectionToken.InjectionToken
local ____speed = require("core.stats.speed")
local speed = ____speed.speed
local ____tears = require("core.stats.tears")
local tears = ____tears.tears
local ____damage = require("core.stats.damage")
local damage = ____damage.damage
local ____range = require("core.stats.range")
local range = ____range.range
local ____shotSpeed = require("core.stats.shotSpeed")
local shotSpeed = ____shotSpeed.shotSpeed
local ____luck = require("core.stats.luck")
local luck = ____luck.luck
local ____APIProviderMapper = require("mappers.api.APIProviderMapper")
local APIProviderMapper = ____APIProviderMapper.APIProviderMapper
local ____APIValidator = require("validators.api.APIValidator")
local APIValidator = ____APIValidator.APIValidator
____exports.API = __TS__Class()
local API = ____exports.API
API.name = "API"
function API.prototype.____constructor(self, mod, modCallbackService, extensionService, isaac, lifecycleService, apiProviderMapper, apiValidator)
    self.mod = mod
    self.modCallbackService = modCallbackService
    self.extensionService = extensionService
    self.isaac = isaac
    self.lifecycleService = lifecycleService
    self.apiProviderMapper = apiProviderMapper
    self.apiValidator = apiValidator
    self.settings = {
        toggle = function(____, options) return self.apiValidator:validateToggleSetting({type = "TOGGLE", name = options.name, description = options.description, initial = options.initial}) end,
        select = function(____, options) return self.apiValidator:validateSelectSetting({
            type = "SELECT",
            name = options.name,
            description = options.description,
            options = options.options,
            initial = options.initial
        }) end,
        range = function(____, options) return self.apiValidator:validateRangeSetting({
            type = "RANGE",
            name = options.name,
            description = options.description,
            min = options.min,
            max = options.max,
            initial = options.initial
        }) end
    }
    self.stat = {
        speed = speed:getExternalAPI(),
        tears = tears:getExternalAPI(),
        damage = damage:getExternalAPI(),
        range = range:getExternalAPI(),
        shotSpeed = shotSpeed:getExternalAPI(),
        luck = luck:getExternalAPI()
    }
    self.logger = Logger["for"](Logger, ____exports.API.name)
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, InjectionToken.ModAPI)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, ModCallbackService)
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, ExtensionService)
        ),
        __TS__DecorateParam(
            3,
            Inject(nil, InjectionToken.IsaacAPI)
        ),
        __TS__DecorateParam(
            4,
            Inject(nil, LifecycleService)
        ),
        __TS__DecorateParam(
            5,
            Inject(nil, APIProviderMapper)
        ),
        __TS__DecorateParam(
            6,
            Inject(nil, APIValidator)
        )
    },
    API
)
function API.prototype.setup(self)
    self:processStatsPlusRegisterCallbacks()
    self.modCallbackService:addCallback(
        ModCallback.POST_UPDATE,
        __TS__FunctionBind(self.processStatsPlusRegisterCallbacks, self)
    )
end
function API.prototype.middleware(self, middleware)
    return self.apiValidator:validateMiddleware(middleware)
end
function API.prototype.provider(self, provider)
    return self.apiValidator:validateProvider(provider)
end
function API.prototype.condition(self, condition)
    return self.apiValidator:validateCondition(condition)
end
function API.prototype.register(self, unvalidatedAddon)
    do
        local function ____catch(e)
            self.logger:error("An error occured during addon registration", e)
        end
        local ____try, ____hasReturned = pcall(function()
            local addon = self.apiValidator:validateAddon(unvalidatedAddon)
            local ____opt_0 = addon.middleware
            if ____opt_0 ~= nil then
                __TS__ArrayForEach(
                    addon.middleware,
                    function(____, middleware)
                        self.extensionService:registerMiddleware(__TS__New(Middleware, addon.id, middleware))
                    end
                )
            end
            local ____opt_2 = addon.providers
            if ____opt_2 ~= nil then
                __TS__ArrayForEach(
                    addon.providers,
                    function(____, provider)
                        self.extensionService:registerProvider(self.apiProviderMapper:mapAPIProvider(addon.id, provider))
                    end
                )
            end
            local ____opt_4 = addon.conditions
            if ____opt_4 ~= nil then
                __TS__ArrayForEach(
                    addon.conditions,
                    function(____, condition)
                        self.extensionService:registerStandaloneCondition(__TS__New(StandaloneConditionDefinition, addon.id, condition))
                    end
                )
            end
            self.logger:info("Requesting a full reload due to an addon register.")
            self.lifecycleService:reloadAll()
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
end
function API.prototype.compareComputableRefs(self, first, second)
    return self:compareExtensionRefs(first.provider, second.provider) and first.computable == second.computable
end
function API.prototype.compareExtensionRefs(self, first, second)
    return first.addon == second.addon and first.id == second.id
end
function API.prototype.processStatsPlusRegisterCallbacks(self)
    local callbacks = self.isaac.GetCallbacks("STATS_PLUS_REGISTER", true)
    __TS__ArrayForEach(
        callbacks,
        function(____, callback)
            if callback == nil then
                return
            end
            do
                local function ____catch(e)
                    self.logger:warn("An error occured while executing 'STATS_PLUS_REGISTER' callback", {err = e})
                end
                local ____try, ____hasReturned = pcall(function()
                    callback:Function(self)
                end)
                if not ____try then
                    ____catch(____hasReturned)
                end
                do
                    self.mod:RemoveCallback("STATS_PLUS_REGISTER", callback.Function)
                end
            end
        end
    )
end
API = __TS__DecorateLegacy(
    {Singleton(nil)},
    API
)
____exports.API = API
return ____exports
