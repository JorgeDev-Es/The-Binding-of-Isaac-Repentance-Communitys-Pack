local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
____exports.FontFactory = __TS__Class()
local FontFactory = ____exports.FontFactory
FontFactory.name = "FontFactory"
function FontFactory.prototype.____constructor(self)
end
function FontFactory.prototype.create(self, filePath)
    local font = Font()
    font:Load(filePath)
    return font
end
FontFactory = __TS__DecorateLegacy(
    {Singleton(nil)},
    FontFactory
)
____exports.FontFactory = FontFactory
return ____exports
