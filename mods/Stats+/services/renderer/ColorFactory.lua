local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
____exports.ColorFactory = __TS__Class()
local ColorFactory = ____exports.ColorFactory
ColorFactory.name = "ColorFactory"
function ColorFactory.prototype.____constructor(self)
end
function ColorFactory.prototype.createFontColor(self, color)
    return KColor(color.red, color.green, color.blue, color.alpha)
end
ColorFactory = __TS__DecorateLegacy(
    {Singleton(nil)},
    ColorFactory
)
____exports.ColorFactory = ColorFactory
return ____exports
