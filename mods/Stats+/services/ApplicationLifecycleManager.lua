local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__FunctionBind = ____lualib.__TS__FunctionBind
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local ModCallback = ____isaac_2Dtypescript_2Ddefinitions.ModCallback
local ____PlayerService = require("services.PlayerService")
local PlayerService = ____PlayerService.PlayerService
local ____MenuService = require("services.menu.MenuService")
local MenuService = ____MenuService.MenuService
local ____StatService = require("services.stat.StatService")
local StatService = ____StatService.StatService
local ____RenderService = require("services.renderer.RenderService")
local RenderService = ____RenderService.RenderService
local ____LifecycleService = require("services.LifecycleService")
local LifecycleService = ____LifecycleService.LifecycleService
local ____ConfigService = require("services.config.ConfigService")
local ConfigService = ____ConfigService.ConfigService
local ____LoadoutService = require("services.LoadoutService")
local LoadoutService = ____LoadoutService.LoadoutService
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____API = require("services.extension.API")
local API = ____API.API
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
local ____ModCallbackService = require("services.ModCallbackService")
local ModCallbackService = ____ModCallbackService.ModCallbackService
local ____GameService = require("services.GameService")
local GameService = ____GameService.GameService
____exports.ApplicationLifecycleManager = __TS__Class()
local ApplicationLifecycleManager = ____exports.ApplicationLifecycleManager
ApplicationLifecycleManager.name = "ApplicationLifecycleManager"
function ApplicationLifecycleManager.prototype.____constructor(self, lifecycleService, configService, menuService, playerService, loadoutService, statService, renderService, modCallbackService, gameService, api)
    self.lifecycleService = lifecycleService
    self.configService = configService
    self.menuService = menuService
    self.playerService = playerService
    self.loadoutService = loadoutService
    self.statService = statService
    self.renderService = renderService
    self.modCallbackService = modCallbackService
    self.gameService = gameService
    self.api = api
    self.logger = Logger["for"](Logger, ____exports.ApplicationLifecycleManager.name)
    self.onPreGameExitListener = __TS__FunctionBind(self.onPreGameExit, self)
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, LifecycleService)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, ConfigService)
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, MenuService)
        ),
        __TS__DecorateParam(
            3,
            Inject(nil, PlayerService)
        ),
        __TS__DecorateParam(
            4,
            Inject(nil, LoadoutService)
        ),
        __TS__DecorateParam(
            5,
            Inject(nil, StatService)
        ),
        __TS__DecorateParam(
            6,
            Inject(nil, RenderService)
        ),
        __TS__DecorateParam(
            7,
            Inject(nil, ModCallbackService)
        ),
        __TS__DecorateParam(
            8,
            Inject(nil, GameService)
        ),
        __TS__DecorateParam(
            9,
            Inject(nil, API)
        )
    },
    ApplicationLifecycleManager
)
function ApplicationLifecycleManager.prototype.setup(self)
    self.modCallbackService:addCallback(ModCallback.PRE_GAME_EXIT, self.onPreGameExitListener)
    self.api:setup()
    self.lifecycleService:getEvents():subscribe(
        "reload",
        function() return self:reload() end
    )
    self.logger:info("Requesting an initial mod state reload.")
    self:reload()
    self.logger:info("Initial mod state reload finished.")
end
function ApplicationLifecycleManager.prototype.reload(self)
    self.logger:info("Reloading the state of the mod.")
    do
        local function ____catch(e)
            error(
                __TS__New(ErrorWithContext, "Error during the mod state reload", {}, e),
                0
            )
        end
        local ____try, ____hasReturned = pcall(function()
            self.configService:reload()
            self.menuService:reload()
            self.playerService:reload()
            self.gameService:reload()
            self.statService:reload()
            self.loadoutService:reload()
            self.renderService:reload()
            self.logger:info("Mod state reloaded successfully.")
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
end
function ApplicationLifecycleManager.prototype.onPreGameExit(self)
    self.logger:info("Unregistering the mod loadout due to the game exit.")
    do
        local function ____catch(e)
            error(
                __TS__New(ErrorWithContext, "Error during the mod loadout unregister.", {}, e),
                0
            )
        end
        local ____try, ____hasReturned = pcall(function()
            self.loadoutService:unregister()
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
end
ApplicationLifecycleManager = __TS__DecorateLegacy(
    {Singleton(nil)},
    ApplicationLifecycleManager
)
____exports.ApplicationLifecycleManager = ApplicationLifecycleManager
return ____exports
