local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____ConfigRepository = require("repositories.config.ConfigRepository")
local ConfigRepository = ____ConfigRepository.ConfigRepository
local ____LifecycleService = require("services.LifecycleService")
local LifecycleService = ____LifecycleService.LifecycleService
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
____exports.ConfigService = __TS__Class()
local ConfigService = ____exports.ConfigService
ConfigService.name = "ConfigService"
function ConfigService.prototype.____constructor(self, configRepository, lifecycleService)
    self.configRepository = configRepository
    self.lifecycleService = lifecycleService
    self.logger = Logger["for"](Logger, ____exports.ConfigService.name)
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, ConfigRepository)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, LifecycleService)
        )
    },
    ConfigService
)
function ConfigService.prototype.getConfig(self)
    return self.configRepository:get()
end
function ConfigService.prototype.updateConfigAndReload(self, update)
    self:updateConfig(update)
    self.logger:info("Requesting a full reload due to the config changes...")
    self.lifecycleService:reloadAll()
end
function ConfigService.prototype.updateConfig(self, update)
    do
        local function ____catch(e)
            error(
                __TS__New(ErrorWithContext, "Error during config update and save.", {}, e),
                0
            )
        end
        local ____try, ____hasReturned = pcall(function()
            local config = self:getConfig():clone()
            update(nil, config)
            self.configRepository:save(config)
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
end
function ConfigService.prototype.reload(self)
    self.logger:debug("Reloading the ConfigService...")
    self.configRepository:reload()
    self.logger:debug("ConfigService reloaded.")
end
ConfigService = __TS__DecorateLegacy(
    {Singleton(nil)},
    ConfigService
)
____exports.ConfigService = ConfigService
return ____exports
