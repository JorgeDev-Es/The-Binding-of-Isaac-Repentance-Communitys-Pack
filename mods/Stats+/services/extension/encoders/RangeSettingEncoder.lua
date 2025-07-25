local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
____exports.RangeSettingEncoder = __TS__Class()
local RangeSettingEncoder = ____exports.RangeSettingEncoder
RangeSettingEncoder.name = "RangeSettingEncoder"
function RangeSettingEncoder.prototype.____constructor(self)
end
function RangeSettingEncoder.prototype.encode(self, decoded)
    return decoded
end
function RangeSettingEncoder.prototype.decode(self, encoded)
    return encoded
end
RangeSettingEncoder = __TS__DecorateLegacy(
    {Singleton(nil)},
    RangeSettingEncoder
)
____exports.RangeSettingEncoder = RangeSettingEncoder
return ____exports
