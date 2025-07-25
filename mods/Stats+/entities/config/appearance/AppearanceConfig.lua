local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____BracketStyle = require("entities.config.appearance.BracketStyle")
local BracketStyle = ____BracketStyle.BracketStyle
____exports.AppearanceConfig = __TS__Class()
local AppearanceConfig = ____exports.AppearanceConfig
AppearanceConfig.name = "AppearanceConfig"
function AppearanceConfig.prototype.____constructor(self, options)
    self.textOpacity = options.textOpacity
    self.bracketStyle = options.bracketStyle
    self.spacing = options.spacing
    self.showProviderChanges = options.showProviderChanges
    self.useShaderColorFix = options.useShaderColorFix
end
function AppearanceConfig.prototype.clone(self)
    return __TS__New(____exports.AppearanceConfig, {
        textOpacity = self.textOpacity,
        bracketStyle = self.bracketStyle,
        spacing = self.spacing,
        showProviderChanges = self.showProviderChanges,
        useShaderColorFix = self.useShaderColorFix
    })
end
function AppearanceConfig.prototype.getTextOpacity(self)
    return self.textOpacity
end
function AppearanceConfig.prototype.getBracketStyle(self)
    return self.bracketStyle
end
function AppearanceConfig.prototype.getSpacing(self)
    return self.spacing
end
function AppearanceConfig.prototype.showsProviderChanges(self)
    return self.showProviderChanges
end
function AppearanceConfig.prototype.usesShaderColorFix(self)
    return self.useShaderColorFix
end
function AppearanceConfig.prototype.setTextOpacity(self, textOpacity)
    self.textOpacity = textOpacity
end
function AppearanceConfig.prototype.setBracketStyle(self, bracketStyle)
    self.bracketStyle = bracketStyle
end
function AppearanceConfig.prototype.setSpacing(self, spacing)
    self.spacing = spacing
end
function AppearanceConfig.prototype.setShowingOfProviderChanges(self, showProviderChanges)
    self.showProviderChanges = showProviderChanges
end
function AppearanceConfig.prototype.setShaderColorFixUsage(self, useShaderColorFix)
    self.useShaderColorFix = useShaderColorFix
end
AppearanceConfig.MIN_TEXT_OPACITY = 0.1
AppearanceConfig.MAX_TEXT_OPACITY = 0.6
AppearanceConfig.AVAILABLE_BRACKET_STYLES = {
    BracketStyle.None,
    BracketStyle.Square,
    BracketStyle.Round,
    BracketStyle.Curly,
    BracketStyle.Angle
}
AppearanceConfig.MIN_SPACING = 0
AppearanceConfig.MAX_SPACING = 10
return ____exports
