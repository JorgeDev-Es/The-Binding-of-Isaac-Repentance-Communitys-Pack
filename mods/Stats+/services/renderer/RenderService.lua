local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__FunctionBind = ____lualib.__TS__FunctionBind
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local CallbackPriority = ____isaac_2Dtypescript_2Ddefinitions.CallbackPriority
local LevelStage = ____isaac_2Dtypescript_2Ddefinitions.LevelStage
local ModCallback = ____isaac_2Dtypescript_2Ddefinitions.ModCallback
local RoomType = ____isaac_2Dtypescript_2Ddefinitions.RoomType
local SeedEffect = ____isaac_2Dtypescript_2Ddefinitions.SeedEffect
local ____Renderer = require("services.renderer.Renderer")
local Renderer = ____Renderer.Renderer
local ____PlayerService = require("services.PlayerService")
local PlayerService = ____PlayerService.PlayerService
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____ModCallbackService = require("services.ModCallbackService")
local ModCallbackService = ____ModCallbackService.ModCallbackService
local ____TimeProvider = require("services.renderer.TimeProvider")
local TimeProvider = ____TimeProvider.TimeProvider
local ____ConfigService = require("services.config.ConfigService")
local ConfigService = ____ConfigService.ConfigService
local ____InjectionToken = require("app.ioc.InjectionToken")
local InjectionToken = ____InjectionToken.InjectionToken
____exports.RenderService = __TS__Class()
local RenderService = ____exports.RenderService
RenderService.name = "RenderService"
function RenderService.prototype.____constructor(self, game, isaac, options, configService, modCallbackService, timeProvider, playerService, renderer)
    self.game = game
    self.isaac = isaac
    self.options = options
    self.configService = configService
    self.modCallbackService = modCallbackService
    self.timeProvider = timeProvider
    self.playerService = playerService
    self.renderer = renderer
    self.logger = Logger["for"](Logger, ____exports.RenderService.name)
    self.onPostRenderCallback = __TS__FunctionBind(self.onPostRender, self)
    self.onGetShaderParamsCallback = __TS__FunctionBind(self.onGetShaderParams, self)
    self.shaderInitialized = false
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, InjectionToken.GameAPI)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, InjectionToken.IsaacAPI)
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, InjectionToken.OptionsAPI)
        ),
        __TS__DecorateParam(
            3,
            Inject(nil, ConfigService)
        ),
        __TS__DecorateParam(
            4,
            Inject(nil, ModCallbackService)
        ),
        __TS__DecorateParam(
            5,
            Inject(nil, TimeProvider)
        ),
        __TS__DecorateParam(
            6,
            Inject(nil, PlayerService)
        ),
        __TS__DecorateParam(
            7,
            Inject(nil, Renderer)
        )
    },
    RenderService
)
function RenderService.prototype.reload(self)
    if self.usesShaderColorFix == nil then
        self.usesShaderColorFix = self.configService:getConfig().appearance:usesShaderColorFix()
    end
    if self:getMemoizedShaderColorFixUsage() and not self.shaderInitialized and self.playerService:getMainPlayer() ~= nil then
        self.isaac.ExecuteCommand("reloadshaders")
        self.shaderInitialized = true
    end
    self.timeProvider:reload()
    self.modCallbackService:removeCallback(ModCallback.POST_RENDER, self.onPostRenderCallback)
    self.modCallbackService:removeCallback(ModCallback.GET_SHADER_PARAMS, self.onGetShaderParamsCallback)
    self.modCallbackService:addPriorityCallback(ModCallback.POST_RENDER, CallbackPriority.IMPORTANT, self.onPostRenderCallback)
    self.modCallbackService:addPriorityCallback(ModCallback.GET_SHADER_PARAMS, CallbackPriority.IMPORTANT, self.onGetShaderParamsCallback)
end
function RenderService.prototype.onPostRender(self)
    if self:getMemoizedShaderColorFixUsage() and (not self.game:IsPaused() or not Isaac.GetPlayer(0).ControlsEnabled) then
        return
    end
    if self:shouldRender() then
        self:render()
    end
end
function RenderService.prototype.onGetShaderParams(self, shaderName)
    if not self:getMemoizedShaderColorFixUsage() then
        return
    end
    if shaderName ~= ____exports.RenderService.SHADER_NAME then
        return
    end
    if self.game:IsPaused() and Isaac.GetPlayer(0).ControlsEnabled then
        return
    end
    if self:shouldRender() then
        self:render()
    end
end
function RenderService.prototype.render(self)
    local players = self.playerService:getPlayers()
    do
        local function ____catch(e)
            self.logger:error("Error during render.", e)
            error(e, 0)
        end
        local ____try, ____hasReturned = pcall(function()
            self.renderer:render(players)
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
end
function RenderService.prototype.shouldRender(self)
    return self.options.FoundHUD and self.game:GetHUD():IsVisible() and (self.game:GetRoom():GetType() ~= RoomType.DUNGEON or self.game:GetLevel():GetAbsoluteStage() ~= LevelStage.HOME) and not self.game:GetSeeds():HasSeedEffect(SeedEffect.NO_HUD)
end
function RenderService.prototype.getMemoizedShaderColorFixUsage(self)
    if self.usesShaderColorFix == nil then
        error(
            __TS__New(Error, "Could not determine whether to use the shader color fix; RenderService was not initialized."),
            0
        )
    end
    return self.usesShaderColorFix
end
RenderService.SHADER_NAME = "STATS_PLUS_SHADER"
RenderService = __TS__DecorateLegacy(
    {Singleton(nil)},
    RenderService
)
____exports.RenderService = RenderService
return ____exports
