local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__FunctionBind = ____lualib.__TS__FunctionBind
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray
local __TS__New = ____lualib.__TS__New
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local ModCallback = ____isaac_2Dtypescript_2Ddefinitions.ModCallback
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____ModCallbackService = require("services.ModCallbackService")
local ModCallbackService = ____ModCallbackService.ModCallbackService
local ____Time = require("entities.Time")
local Time = ____Time.Time
local ____InjectionToken = require("app.ioc.InjectionToken")
local InjectionToken = ____InjectionToken.InjectionToken
local ____constrain = require("util.math.constrain")
local constrain = ____constrain.constrain
local ____Interpolation = require("entities.interpolation.Interpolation")
local Interpolation = ____Interpolation.Interpolation
____exports.TimeProvider = __TS__Class()
local TimeProvider = ____exports.TimeProvider
TimeProvider.name = "TimeProvider"
function TimeProvider.prototype.____constructor(self, modCallbackService, game, isaac)
    self.modCallbackService = modCallbackService
    self.game = game
    self.isaac = isaac
    self.onPostRenderCallback = __TS__FunctionBind(self.onPostRender, self)
    self.lastRenderTime = Time:never()
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, ModCallbackService)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, InjectionToken.GameAPI)
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, InjectionToken.IsaacAPI)
        )
    },
    TimeProvider
)
function TimeProvider.prototype.getLastRenderTime(self)
    return self.lastRenderTime
end
function TimeProvider.prototype.reload(self)
    self.modCallbackService:removeCallback(ModCallback.POST_RENDER, self.onPostRenderCallback)
    self.modCallbackService:addCallback(ModCallback.POST_RENDER, self.onPostRenderCallback)
end
function TimeProvider.prototype.interpolate(self, options)
    local min, max = table.unpack(options.output)
    local start = options.start or Time:never()
    local time = constrain(
        nil,
        (self:getLastRenderTime():getTicks() - start:getTicks()) / options.duration:getTicks(),
        {0, 1}
    )
    local value = __TS__ArrayIsArray(min) and __TS__ArrayIsArray(max) and self:interpolateArray(
        min,
        max,
        options:easing(time)
    ) or self:interpolateScalar(
        min,
        max,
        options:easing(time)
    )
    return __TS__New(
        Interpolation,
        value,
        start,
        Time:ticks(start:getTicks() + options.duration:getTicks())
    )
end
function TimeProvider.prototype.interpolateArray(self, min, max, progress)
    if #min ~= #max then
        error(
            __TS__New(Error, "Both arrays must have an equal length when interpolating."),
            0
        )
    end
    return __TS__ArrayMap(
        min,
        function(____, _, i) return self:interpolateScalar(min[i + 1], max[i + 1], progress) end
    )
end
function TimeProvider.prototype.interpolateScalar(self, min, max, progress)
    return min + (max - min) * progress
end
function TimeProvider.prototype.onPostRender(self)
    if self.game:IsPaused() then
        return
    end
    local currentTicksInterpolated = self.game:GetFrameCount() + (1 - self.isaac.GetFrameCount() % 2) / 2
    self.lastRenderTime = Time:ticks(currentTicksInterpolated)
end
TimeProvider = __TS__DecorateLegacy(
    {Singleton(nil)},
    TimeProvider
)
____exports.TimeProvider = TimeProvider
return ____exports
