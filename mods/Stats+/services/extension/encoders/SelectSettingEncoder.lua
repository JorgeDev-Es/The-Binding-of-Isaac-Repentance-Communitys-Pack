local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex
local __TS__New = ____lualib.__TS__New
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
____exports.SelectSettingEncoder = __TS__Class()
local SelectSettingEncoder = ____exports.SelectSettingEncoder
SelectSettingEncoder.name = "SelectSettingEncoder"
function SelectSettingEncoder.prototype.____constructor(self)
end
function SelectSettingEncoder.prototype.encode(self, decoded, setting)
    local index = __TS__ArrayFindIndex(
        setting:getOptions(),
        function(____, option) return option:getValue() == decoded end
    )
    if index == -1 then
        error(
            __TS__New(
                ErrorWithContext,
                "Could not find a select option matching the given value.",
                {
                    settingName = setting:getName(),
                    settingKey = setting:getKey()
                }
            ),
            0
        )
    end
    return index
end
function SelectSettingEncoder.prototype.decode(self, encoded, setting)
    return setting:getOptions()[encoded + 1]:getValue()
end
SelectSettingEncoder = __TS__DecorateLegacy(
    {Singleton(nil)},
    SelectSettingEncoder
)
____exports.SelectSettingEncoder = SelectSettingEncoder
return ____exports
