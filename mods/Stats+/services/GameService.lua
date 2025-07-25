local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__FunctionBind = ____lualib.__TS__FunctionBind
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local ModCallback = ____isaac_2Dtypescript_2Ddefinitions.ModCallback
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____ModCallbackService = require("services.ModCallbackService")
local ModCallbackService = ____ModCallbackService.ModCallbackService
local ____InjectionToken = require("app.ioc.InjectionToken")
local InjectionToken = ____InjectionToken.InjectionToken
____exports.GameService = __TS__Class()
local GameService = ____exports.GameService
GameService.name = "GameService"
function GameService.prototype.____constructor(self, modCallbackService, isaac)
    self.modCallbackService = modCallbackService
    self.isaac = isaac
    self.onPostGameStartedListener = __TS__FunctionBind(self.onPostGameStarted, self)
    self.achievementsEnabled = false
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, ModCallbackService)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, InjectionToken.IsaacAPI)
        )
    },
    GameService
)
function GameService.prototype.areAchievementsEnabled(self)
    return self.achievementsEnabled
end
function GameService.prototype.reload(self)
    self.modCallbackService:removeCallback(ModCallback.POST_GAME_STARTED, self.onPostGameStartedListener)
    self.modCallbackService:addCallback(ModCallback.POST_GAME_STARTED, self.onPostGameStartedListener)
end
function GameService.prototype.onPostGameStarted(self)
    local machine = self.isaac.Spawn(
        6,
        11,
        0,
        Vector(0, 0),
        Vector(0, 0),
        nil
    )
    local achievementsEnabled = machine:Exists()
    machine:Remove()
    self.achievementsEnabled = achievementsEnabled
end
GameService = __TS__DecorateLegacy(
    {Singleton(nil)},
    GameService
)
____exports.GameService = GameService
return ____exports
