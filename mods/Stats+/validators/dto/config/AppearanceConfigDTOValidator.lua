local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__TypeOf = ____lualib.__TS__TypeOf
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
local ____Config = require("entities.config.Config")
local Config = ____Config.Config
local ____AppearanceConfig = require("entities.config.appearance.AppearanceConfig")
local AppearanceConfig = ____AppearanceConfig.AppearanceConfig
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
____exports.AppearanceConfigDTOValidator = __TS__Class()
local AppearanceConfigDTOValidator = ____exports.AppearanceConfigDTOValidator
AppearanceConfigDTOValidator.name = "AppearanceConfigDTOValidator"
function AppearanceConfigDTOValidator.prototype.____constructor(self)
    self.logger = Logger["for"](Logger, ____exports.AppearanceConfigDTOValidator.name)
end
function AppearanceConfigDTOValidator.prototype.validate(self, appearance)
    if appearance == nil then
        return Config.DEFAULT_CONFIG.appearance
    end
    return {
        textOpacity = self:getValidatedTextOpacity(appearance.textOpacity),
        bracketStyle = self:getValidatedBracketStyle(appearance.bracketStyle),
        spacing = self:getValidatedSpacing(appearance.spacing),
        showProviderChanges = self:getValidatedShowProviderChanges(appearance.showProviderChanges),
        useShaderColorFix = self:getValidatedUseShaderColorFix(appearance.useShaderColorFix)
    }
end
function AppearanceConfigDTOValidator.prototype.getValidatedTextOpacity(self, textOpacity)
    if type(textOpacity) ~= "number" then
        self.logger:warn(
            "Expected text opacity to be a number.",
            {
                textOpacity = textOpacity,
                type = __TS__TypeOf(textOpacity)
            }
        )
        return Config.DEFAULT_CONFIG.appearance.textOpacity
    end
    if textOpacity > AppearanceConfig.MAX_TEXT_OPACITY then
        self.logger:warn(
            ("Expected text opacity to be less than " .. tostring(AppearanceConfig.MAX_TEXT_OPACITY)) .. ".",
            {textOpacity = textOpacity}
        )
        return Config.DEFAULT_CONFIG.appearance.textOpacity
    end
    if AppearanceConfig.MIN_TEXT_OPACITY > textOpacity then
        self.logger:warn(
            ("Expected text opacity to be greater than " .. tostring(AppearanceConfig.MIN_TEXT_OPACITY)) .. ".",
            {textOpacity = textOpacity}
        )
        return Config.DEFAULT_CONFIG.appearance.textOpacity
    end
    return textOpacity
end
function AppearanceConfigDTOValidator.prototype.getValidatedBracketStyle(self, bracketStyle)
    if bracketStyle == nil or not __TS__ArrayIncludes(AppearanceConfig.AVAILABLE_BRACKET_STYLES, bracketStyle) then
        self.logger:warn(
            "Expected bracket style to be a valid enum value.",
            {
                bracketStyle = bracketStyle,
                type = __TS__TypeOf(bracketStyle),
                availableBracketStyles = AppearanceConfig.AVAILABLE_BRACKET_STYLES
            }
        )
        return Config.DEFAULT_CONFIG.appearance.bracketStyle
    end
    return bracketStyle
end
function AppearanceConfigDTOValidator.prototype.getValidatedSpacing(self, spacing)
    if type(spacing) ~= "number" then
        self.logger:warn(
            "Expected spacing to be a number.",
            {
                spacing = spacing,
                type = __TS__TypeOf(spacing)
            }
        )
        return Config.DEFAULT_CONFIG.appearance.spacing
    end
    if spacing > AppearanceConfig.MAX_SPACING then
        self.logger:warn(
            ("Expected spacing to be less than " .. tostring(AppearanceConfig.MAX_SPACING)) .. ".",
            {spacing = spacing}
        )
        return Config.DEFAULT_CONFIG.appearance.spacing
    end
    if AppearanceConfig.MIN_SPACING > spacing then
        self.logger:warn(
            ("Expected spacing to be greater than " .. tostring(AppearanceConfig.MIN_SPACING)) .. ".",
            {spacing = spacing}
        )
        return Config.DEFAULT_CONFIG.appearance.spacing
    end
    return spacing
end
function AppearanceConfigDTOValidator.prototype.getValidatedShowProviderChanges(self, showProviderChanges)
    if type(showProviderChanges) ~= "boolean" then
        self.logger:warn(
            "Expected 'show provider changes' option to be a boolean value.",
            {
                showProviderChanges = showProviderChanges,
                type = __TS__TypeOf(showProviderChanges)
            }
        )
        return Config.DEFAULT_CONFIG.appearance.showProviderChanges
    end
    return showProviderChanges
end
function AppearanceConfigDTOValidator.prototype.getValidatedUseShaderColorFix(self, useShaderColorFix)
    if type(useShaderColorFix) ~= "boolean" then
        self.logger:warn(
            "Expected 'use shader color fix' option to be a boolean value.",
            {
                useShaderColorFix = useShaderColorFix,
                type = __TS__TypeOf(useShaderColorFix)
            }
        )
        return Config.DEFAULT_CONFIG.appearance.useShaderColorFix
    end
    return useShaderColorFix
end
AppearanceConfigDTOValidator = __TS__DecorateLegacy(
    {Singleton(nil)},
    AppearanceConfigDTOValidator
)
____exports.AppearanceConfigDTOValidator = AppearanceConfigDTOValidator
return ____exports
