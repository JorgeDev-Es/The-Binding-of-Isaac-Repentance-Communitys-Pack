local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
____exports.ToggleSettingEncoder = __TS__Class()
local ToggleSettingEncoder = ____exports.ToggleSettingEncoder
ToggleSettingEncoder.name = "ToggleSettingEncoder"
function ToggleSettingEncoder.prototype.____constructor(self)
end
function ToggleSettingEncoder.prototype.encode(self, decoded)
    return tostring(decoded)
end
function ToggleSettingEncoder.prototype.decode(self, encoded)
    return encoded == "true"
end
ToggleSettingEncoder = __TS__DecorateLegacy(
    {Singleton(nil)},
    ToggleSettingEncoder
)
____exports.ToggleSettingEncoder = ToggleSettingEncoder
return ____exports
