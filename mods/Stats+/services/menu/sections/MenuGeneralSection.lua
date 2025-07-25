local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____common = require("lua_modules.@isaac-stats-plus.common.dist.index")
local toFixedFormatted = ____common.toFixedFormatted
local ____ConfigService = require("services.config.ConfigService")
local ConfigService = ____ConfigService.ConfigService
local ____AppearanceConfig = require("entities.config.appearance.AppearanceConfig")
local AppearanceConfig = ____AppearanceConfig.AppearanceConfig
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____BracketStyle = require("entities.config.appearance.BracketStyle")
local BracketStyle = ____BracketStyle.BracketStyle
local applicationConstants = require("app.applicationConstants")
local ____ProviderSelectSettingOption = require("entities.extension.provider.settings.ProviderSelectSettingOption")
local ProviderSelectSettingOption = ____ProviderSelectSettingOption.ProviderSelectSettingOption
____exports.MenuGeneralSection = __TS__Class()
local MenuGeneralSection = ____exports.MenuGeneralSection
MenuGeneralSection.name = "MenuGeneralSection"
function MenuGeneralSection.prototype.____constructor(self, configService)
    self.configService = configService
end
__TS__DecorateLegacy(
    {__TS__DecorateParam(
        0,
        Inject(nil, ConfigService)
    )},
    MenuGeneralSection
)
function MenuGeneralSection.prototype.getIdentifier(self)
    return ____exports.MenuGeneralSection.SUBCATEGORY_NAME
end
function MenuGeneralSection.prototype.register(self, menu)
    self:registerModInformationSection(menu)
    menu:space()
    self:registerApperanceSubsection(menu)
end
function MenuGeneralSection.prototype.registerModInformationSection(self, menu)
    menu:heading({text = "Mod Information"}):readonly({name = "Version", value = applicationConstants.APPLICATION_VERSION})
end
function MenuGeneralSection.prototype.registerApperanceSubsection(self, menu)
    menu:heading({text = "Appearance"}):range({
        name = "Text Opacity",
        description = {"The opacity of the text rendered by Stats+."},
        format = function(____, value) return tostring(math.floor(value * 100 + 0.5)) .. "%" end,
        min = AppearanceConfig.MIN_TEXT_OPACITY,
        max = AppearanceConfig.MAX_TEXT_OPACITY,
        retrieve = function() return self.configService:getConfig().appearance:getTextOpacity() end,
        update = function(____, textOpacity)
            self.configService:updateConfigAndReload(function(____, config)
                config.appearance:setTextOpacity(textOpacity)
            end)
        end
    }):select({
        name = "Bracket Style",
        description = {"Prefix and suffix characters of the text rendered by Stats+."},
        options = {
            __TS__New(ProviderSelectSettingOption, "None", BracketStyle.None),
            __TS__New(ProviderSelectSettingOption, "Square", BracketStyle.Square),
            __TS__New(ProviderSelectSettingOption, "Round", BracketStyle.Round),
            __TS__New(ProviderSelectSettingOption, "Curly", BracketStyle.Curly),
            __TS__New(ProviderSelectSettingOption, "Angle", BracketStyle.Angle)
        },
        fallback = function() return __TS__New(
            ProviderSelectSettingOption,
            self.configService:getConfig().appearance:getBracketStyle(),
            self.configService:getConfig().appearance:getBracketStyle()
        ) end,
        retrieve = function() return self.configService:getConfig().appearance:getBracketStyle() end,
        update = function(____, bracketStyle)
            self.configService:updateConfigAndReload(function(____, config)
                config.appearance:setBracketStyle(bracketStyle)
            end)
        end
    }):range({
        name = "Spacing",
        description = {"A distance between a stat and a provider text."},
        format = function(____, value) return toFixedFormatted(nil, value, 1) .. " px" end,
        min = AppearanceConfig.MIN_SPACING,
        max = AppearanceConfig.MAX_SPACING,
        retrieve = function() return self.configService:getConfig().appearance:getSpacing() end,
        update = function(____, spacing)
            self.configService:updateConfigAndReload(function(____, config)
                config.appearance:setSpacing(spacing)
            end)
        end
    }):toggle({
        name = "Show provider changes",
        description = {"Displays a changed value when the provider is updated."},
        retrieve = function() return self.configService:getConfig().appearance:showsProviderChanges() end,
        update = function(____, showProviderChanges)
            self.configService:updateConfigAndReload(function(____, config)
                config.appearance:setShowingOfProviderChanges(showProviderChanges)
            end)
        end
    }):toggle({
        name = "Use shader color fix",
        description = {"(REQUIRES RESTART) Renders Stats+ without being affected by the stage colors."},
        retrieve = function() return self.configService:getConfig().appearance:usesShaderColorFix() end,
        update = function(____, usesShaderColorFix)
            self.configService:updateConfigAndReload(function(____, config)
                config.appearance:setShaderColorFixUsage(usesShaderColorFix)
            end)
        end
    })
end
MenuGeneralSection.SUBCATEGORY_NAME = "General"
MenuGeneralSection = __TS__DecorateLegacy(
    {Singleton(nil)},
    MenuGeneralSection
)
____exports.MenuGeneralSection = MenuGeneralSection
return ____exports
