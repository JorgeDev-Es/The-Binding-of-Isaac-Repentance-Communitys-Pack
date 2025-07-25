local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__New = ____lualib.__TS__New
local __TS__TypeOf = ____lualib.__TS__TypeOf
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArraySlice = ____lualib.__TS__ArraySlice
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local PlayerType = ____isaac_2Dtypescript_2Ddefinitions.PlayerType
local ____MetricChange = require("entities.metric.MetricChange")
local MetricChange = ____MetricChange.MetricChange
local ____StatSlot = require("entities.stat.StatSlot")
local StatSlot = ____StatSlot.StatSlot
local ____FontFactory = require("services.renderer.FontFactory")
local FontFactory = ____FontFactory.FontFactory
local ____RenderPositionProvider = require("services.renderer.RenderPositionProvider")
local RenderPositionProvider = ____RenderPositionProvider.RenderPositionProvider
local ____ColorFactory = require("services.renderer.ColorFactory")
local ColorFactory = ____ColorFactory.ColorFactory
local ____ConfigService = require("services.config.ConfigService")
local ConfigService = ____ConfigService.ConfigService
local ____LoadoutService = require("services.LoadoutService")
local LoadoutService = ____LoadoutService.LoadoutService
local ____StatService = require("services.stat.StatService")
local StatService = ____StatService.StatService
local ____ProviderColor = require("entities.config.appearance.ProviderColor")
local ProviderColor = ____ProviderColor.ProviderColor
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____CORE_STAT_EXTENSIONS = require("data.stat.CORE_STAT_EXTENSIONS")
local CORE_STAT_EXTENSIONS = ____CORE_STAT_EXTENSIONS.CORE_STAT_EXTENSIONS
local ____BracketStyle = require("entities.config.appearance.BracketStyle")
local BracketStyle = ____BracketStyle.BracketStyle
local ____Time = require("entities.Time")
local Time = ____Time.Time
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
local ____TimeProvider = require("services.renderer.TimeProvider")
local TimeProvider = ____TimeProvider.TimeProvider
local ____RGBAColor = require("entities.renderer.RGBAColor")
local RGBAColor = ____RGBAColor.RGBAColor
local ____RGBColor = require("entities.renderer.RGBColor")
local RGBColor = ____RGBColor.RGBColor
local ____speed = require("core.stats.speed")
local speed = ____speed.speed
local ____Interpolation = require("entities.interpolation.Interpolation")
local Interpolation = ____Interpolation.Interpolation
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
____exports.Renderer = __TS__Class()
local Renderer = ____exports.Renderer
Renderer.name = "Renderer"
function Renderer.prototype.____constructor(self, timeProvider, configService, loadoutService, statService, renderPositionProvider, fontFactory, colorFactory)
    self.timeProvider = timeProvider
    self.configService = configService
    self.loadoutService = loadoutService
    self.statService = statService
    self.renderPositionProvider = renderPositionProvider
    self.fontFactory = fontFactory
    self.colorFactory = colorFactory
    self.logger = Logger["for"](Logger, ____exports.Renderer.name)
    self.providerFont = self.fontFactory:create("font/luaminioutlined.fnt")
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, TimeProvider)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, ConfigService)
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, LoadoutService)
        ),
        __TS__DecorateParam(
            3,
            Inject(nil, StatService)
        ),
        __TS__DecorateParam(
            4,
            Inject(nil, RenderPositionProvider)
        ),
        __TS__DecorateParam(
            5,
            Inject(nil, FontFactory)
        ),
        __TS__DecorateParam(
            6,
            Inject(nil, ColorFactory)
        )
    },
    Renderer
)
function Renderer.getProviderColorRGB(self, providerColor, player)
    if providerColor == ProviderColor.None then
        return player:isMainPlayer() and __TS__New(RGBColor, 1, 1, 1) or __TS__New(RGBColor, 1, 0.75, 0.75)
    end
    if providerColor == ProviderColor.Grey then
        return __TS__New(RGBColor, 1, 1, 1)
    end
    if providerColor == ProviderColor.Red then
        return __TS__New(RGBColor, 1, 0.568627, 0.568627)
    end
    if providerColor == ProviderColor.Green then
        return __TS__New(RGBColor, 0.568627, 1, 0.568627)
    end
    if providerColor == ProviderColor.Blue then
        return __TS__New(RGBColor, 0.568627, 0.819608, 1)
    end
    if providerColor == ProviderColor.Orange then
        return __TS__New(RGBColor, 1, 0.768627, 0.568627)
    end
    if providerColor == ProviderColor.Magenta then
        return __TS__New(RGBColor, 1, 0.568627, 0.819608)
    end
    if providerColor == ProviderColor.Cyan then
        return __TS__New(RGBColor, 0.568627, 1, 1)
    end
    error(
        __TS__New(
            ErrorWithContext,
            "Invalid provider color value.",
            {
                providerColor = providerColor,
                type = __TS__TypeOf(providerColor)
            }
        ),
        0
    )
end
function Renderer.prototype.render(self, players)
    __TS__ArrayForEach(
        __TS__ArraySlice(players, 0, ____exports.Renderer.MAX_RENDERED_PLAYERS),
        function(____, player)
            __TS__ArrayForEach(
                CORE_STAT_EXTENSIONS,
                function(____, statType)
                    local slot = __TS__New(StatSlot, statType, player)
                    if self:shouldRenderSlot(slot) then
                        self:renderSlot(slot)
                    end
                end
            )
        end
    )
end
function Renderer.prototype.renderSlot(self, slot)
    local loadoutEntry = self.loadoutService:getEntry(slot)
    if loadoutEntry == nil then
        self.logger:warn("No loadout entry found for the given stat slot.", {playerIndex = slot.player.index, stat = slot.stat})
        return
    end
    self:renderValue(slot, loadoutEntry)
    self:renderChange(slot, loadoutEntry)
end
function Renderer.prototype.renderValue(self, slot, loadoutEntry)
    local ____temp_6
    local ____opt_0 = loadoutEntry:getActiveProvider():getValue()
    if (____opt_0 and ____opt_0:getFormattedValue()) == nil then
        local ____opt_2 = loadoutEntry:getInactiveProvider():getValue()
        ____temp_6 = ____opt_2 and ____opt_2:getFormattedValue()
    else
        local ____opt_4 = loadoutEntry:getActiveProvider():getValue()
        ____temp_6 = ____opt_4 and ____opt_4:getFormattedValue()
    end
    local formattedValue = ____temp_6
    if formattedValue == nil then
        return
    end
    local ____self_10 = self.renderPositionProvider
    local ____self_10_getPosition_11 = ____self_10.getPosition
    local ____slot_9 = slot
    local ____opt_7 = self.statService:getStatValue(slot)
    local x, y = table.unpack(____self_10_getPosition_11(
        ____self_10,
        ____slot_9,
        ____opt_7 and ____opt_7:getFormattedValue()
    ))
    local previousColor = ____exports.Renderer:getProviderColorRGB(
        loadoutEntry:getInactiveProvider():getProviderColor(),
        slot.player
    ):asRGBA(self:getProviderValueOpacity(loadoutEntry:getInactiveProvider():getValue()))
    local currentColor = ____exports.Renderer:getProviderColorRGB(
        loadoutEntry:getActiveProvider():getProviderColor(),
        slot.player
    ):asRGBA(self:getProviderValueOpacity(loadoutEntry:getActiveProvider():getValue()))
    local finalColor = self:getInterpolatedColor(loadoutEntry, previousColor, currentColor)
    self.providerFont:DrawStringUTF8(
        self:getValueWithBrackets(formattedValue),
        x,
        y,
        self.colorFactory:createFontColor(finalColor),
        0,
        false
    )
end
function Renderer.prototype.renderChange(self, slot, loadoutEntry)
    if not self.configService:getConfig().appearance:showsProviderChanges() then
        return
    end
    local ANIMATION_START_TIME = MetricChange.ANIMATION_DURATION:plus(Time:ms(1000))
    local FADE_IN_DURATION = Time:ms(500)
    local FADE_OUT_DURATION = Time:ms(750)
    local SLIDE_IN_DURATION = Time:ms(400)
    local timeBeforeAnimationStart = self.timeProvider:getLastRenderTime():minus(ANIMATION_START_TIME):minus(FADE_IN_DURATION):minus(FADE_OUT_DURATION)
    local ____opt_12 = self.statService:getStatValue(slot)
    local statChange = ____opt_12 and ____opt_12:getChangeAt(timeBeforeAnimationStart)
    local activeProviderValue = loadoutEntry:getActiveProvider():getValue()
    local activeProviderChange = activeProviderValue and activeProviderValue:getChangeAt(timeBeforeAnimationStart)
    local inactiveProviderValue = loadoutEntry:getInactiveProvider():getValue()
    local inactiveProviderChange = inactiveProviderValue and inactiveProviderValue:getChangeAt(timeBeforeAnimationStart)
    local fadeInOpacity = self.timeProvider:interpolate({
        output = {0, 1},
        easing = Interpolation.linear,
        duration = FADE_IN_DURATION,
        start = Time:max(
            statChange and statChange.lastUpdate:plus(ANIMATION_START_TIME),
            activeProviderChange and activeProviderChange.lastUpdate:minus(FADE_OUT_DURATION),
            activeProviderValue and activeProviderValue:getChangeStartTime():plus(FADE_IN_DURATION)
        )
    })
    local fadeOutOpacity = self.timeProvider:interpolate({
        output = {1, 0},
        easing = Interpolation.linear,
        duration = FADE_OUT_DURATION,
        start = fadeInOpacity:getFinishTime():plus(MetricChange.ANIMATION_DURATION)
    })
    local slideInOffset = self.timeProvider:interpolate({
        output = {0, ____exports.Renderer.PROVIDER_CHANGE_SLIDE_PX},
        easing = Interpolation.easeOut,
        duration = SLIDE_IN_DURATION,
        start = fadeInOpacity:getStartTime()
    })
    local ____self_getChangeColor_30 = self.getChangeColor
    local ____temp_28 = inactiveProviderChange and inactiveProviderChange.isPositive
    if ____temp_28 == nil then
        ____temp_28 = activeProviderChange and activeProviderChange.isPositive
    end
    local ____temp_28_29 = ____temp_28
    if ____temp_28_29 == nil then
        ____temp_28_29 = false
    end
    local previousColor = ____self_getChangeColor_30(
        self,
        ____temp_28_29,
        self:getProviderChangeOpacity(inactiveProviderChange) * fadeInOpacity:getValue() * fadeOutOpacity:getValue()
    )
    local ____self_getChangeColor_37 = self.getChangeColor
    local ____temp_35 = activeProviderChange and activeProviderChange.isPositive
    if ____temp_35 == nil then
        ____temp_35 = inactiveProviderChange and inactiveProviderChange.isPositive
    end
    local ____temp_35_36 = ____temp_35
    if ____temp_35_36 == nil then
        ____temp_35_36 = false
    end
    local currentColor = ____self_getChangeColor_37(
        self,
        ____temp_35_36,
        self:getProviderChangeOpacity(activeProviderChange) * fadeInOpacity:getValue() * fadeOutOpacity:getValue()
    )
    local finalColor = self:getInterpolatedColor(loadoutEntry, previousColor, currentColor)
    local fontColor = self.colorFactory:createFontColor(finalColor)
    local displayProviderValue = activeProviderValue and activeProviderValue:getFormattedValue() or inactiveProviderValue and inactiveProviderValue:getFormattedValue()
    local displayProviderChange = activeProviderChange and activeProviderChange.formattedValue or inactiveProviderChange and inactiveProviderChange.formattedValue
    if displayProviderValue == nil or displayProviderChange == nil then
        return
    end
    local ____opt_46 = self.statService:getStatValue(slot)
    local statText = ____opt_46 and ____opt_46:getFormattedValue()
    local providerText = self:getValueWithBrackets(displayProviderValue)
    local x, y = table.unpack(self.renderPositionProvider:getPosition(slot, statText == nil and providerText or statText .. providerText))
    self.providerFont:DrawStringUTF8(
        self:getValueWithBrackets(displayProviderChange),
        x + slideInOffset:getValue(),
        y,
        fontColor,
        0,
        false
    )
end
function Renderer.prototype.getInterpolatedColor(self, loadoutEntry, previousColor, currentColor)
    local gameStartOpacity = self.timeProvider:interpolate({
        output = {0, 1},
        easing = Interpolation.linear,
        duration = Time:ms(150),
        start = Time:ms(250)
    })
    local ____self_53 = self.timeProvider
    local ____self_53_interpolate_54 = ____self_53.interpolate
    local ____temp_50 = {0, 1}
    local ____Interpolation_linear_51 = Interpolation.linear
    local ____temp_52 = Time:ms(500)
    local ____opt_48 = self.statService:getStatValue(loadoutEntry.statSlot)
    local statUpdateDuckOpacity = ____self_53_interpolate_54(
        ____self_53,
        {
            output = ____temp_50,
            easing = ____Interpolation_linear_51,
            duration = ____temp_52,
            start = ____opt_48 and ____opt_48:getChange().lastUpdate:plus(MetricChange.ANIMATION_DURATION)
        }
    )
    local interpolatedColor = self.timeProvider:interpolate({
        output = {
            previousColor:withAlpha(previousColor.alpha * gameStartOpacity:getValue() * statUpdateDuckOpacity:getValue()):asArray(),
            currentColor:withAlpha(currentColor.alpha * gameStartOpacity:getValue() * statUpdateDuckOpacity:getValue()):asArray()
        },
        easing = Interpolation.linear,
        duration = Time:ms(150),
        start = loadoutEntry.condition:getLastChange()
    })
    return RGBAColor:fromArray(interpolatedColor:getValue())
end
function Renderer.prototype.getProviderChangeOpacity(self, providerChange)
    if (providerChange and providerChange.formattedValue) == nil then
        return 0
    end
    return ____exports.Renderer.PROVIDER_CHANGE_OPACITY
end
function Renderer.prototype.getProviderValueOpacity(self, providerValue)
    if (providerValue and providerValue:getFormattedValue()) == nil then
        return 0
    end
    return self.configService:getConfig().appearance:getTextOpacity()
end
function Renderer.prototype.getChangeColor(self, isPositive, opacity)
    return isPositive and ____exports.Renderer.POSITIVE_CHANGE_COLOR:asRGBA(opacity) or ____exports.Renderer.NEGATIVE_CHANGE_COLOR:asRGBA(opacity)
end
function Renderer.prototype.getValueWithBrackets(self, value)
    local ____temp_59 = self:getBracketCharacters()
    local prefix = ____temp_59.prefix
    local suffix = ____temp_59.suffix
    return (prefix .. value) .. suffix
end
function Renderer.prototype.getBracketCharacters(self)
    local bracketStyle = self.configService:getConfig().appearance:getBracketStyle()
    local bracketCharacters = ____exports.Renderer.BRACKET_STYLE_SIGNS[bracketStyle]
    if bracketCharacters == nil then
        error(
            __TS__New(
                ErrorWithContext,
                "Unknown bracket style.",
                {
                    bracketStyle = bracketStyle,
                    bracketStyleType = __TS__TypeOf(bracketStyle)
                }
            ),
            0
        )
    end
    return bracketCharacters
end
function Renderer.prototype.shouldRenderSlot(self, slot)
    local isEsauSpeed = slot.stat == speed and slot.player.entityPlayer:GetPlayerType() == PlayerType.ESAU
    return not isEsauSpeed
end
Renderer.MAX_RENDERED_PLAYERS = 2
Renderer.PROVIDER_CHANGE_OPACITY = 0.5
Renderer.PROVIDER_CHANGE_SLIDE_PX = 8
Renderer.POSITIVE_CHANGE_COLOR = __TS__New(RGBColor, 0, 1, 0)
Renderer.NEGATIVE_CHANGE_COLOR = __TS__New(RGBColor, 1, 0, 0)
Renderer.BRACKET_STYLE_SIGNS = {
    [BracketStyle.None] = {prefix = "", suffix = ""},
    [BracketStyle.Round] = {prefix = "(", suffix = ")"},
    [BracketStyle.Square] = {prefix = "[", suffix = "]"},
    [BracketStyle.Curly] = {prefix = "{", suffix = "}"},
    [BracketStyle.Angle] = {prefix = "<", suffix = ">"}
}
Renderer = __TS__DecorateLegacy(
    {Singleton(nil)},
    Renderer
)
____exports.Renderer = Renderer
return ____exports
