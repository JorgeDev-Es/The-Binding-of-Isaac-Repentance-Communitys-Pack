local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__InstanceOf = ____lualib.__TS__InstanceOf
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____ToggleSettingEncoder = require("services.extension.encoders.ToggleSettingEncoder")
local ToggleSettingEncoder = ____ToggleSettingEncoder.ToggleSettingEncoder
local ____RangeSettingEncoder = require("services.extension.encoders.RangeSettingEncoder")
local RangeSettingEncoder = ____RangeSettingEncoder.RangeSettingEncoder
local ____SelectSettingEncoder = require("services.extension.encoders.SelectSettingEncoder")
local SelectSettingEncoder = ____SelectSettingEncoder.SelectSettingEncoder
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____ProviderToggleSetting = require("entities.extension.provider.settings.ProviderToggleSetting")
local ProviderToggleSetting = ____ProviderToggleSetting.ProviderToggleSetting
local ____ProviderRangeSetting = require("entities.extension.provider.settings.ProviderRangeSetting")
local ProviderRangeSetting = ____ProviderRangeSetting.ProviderRangeSetting
local ____ProviderSelectSetting = require("entities.extension.provider.settings.ProviderSelectSetting")
local ProviderSelectSetting = ____ProviderSelectSetting.ProviderSelectSetting
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
____exports.SettingEncoderService = __TS__Class()
local SettingEncoderService = ____exports.SettingEncoderService
SettingEncoderService.name = "SettingEncoderService"
function SettingEncoderService.prototype.____constructor(self, toggleSettingEncoder, rangeSettingEncoder, selectSettingEncoder)
    self.toggleSettingEncoder = toggleSettingEncoder
    self.rangeSettingEncoder = rangeSettingEncoder
    self.selectSettingEncoder = selectSettingEncoder
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, ToggleSettingEncoder)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, RangeSettingEncoder)
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, SelectSettingEncoder)
        )
    },
    SettingEncoderService
)
function SettingEncoderService.prototype.encodeSetting(self, setting, decoded)
    return self:getEncoderForSetting(setting):encode(decoded, setting)
end
function SettingEncoderService.prototype.decodeSetting(self, setting, encoded)
    return self:getEncoderForSetting(setting):decode(encoded, setting)
end
function SettingEncoderService.prototype.getEncoderForSetting(self, setting)
    if __TS__InstanceOf(setting, ProviderToggleSetting) then
        return self.toggleSettingEncoder
    end
    if __TS__InstanceOf(setting, ProviderRangeSetting) then
        return self.rangeSettingEncoder
    end
    if __TS__InstanceOf(setting, ProviderSelectSetting) then
        return self.selectSettingEncoder
    end
    error(
        __TS__New(ErrorWithContext, "Unknown setting type.", {setting = setting}),
        0
    )
end
SettingEncoderService = __TS__DecorateLegacy(
    {Singleton(nil)},
    SettingEncoderService
)
____exports.SettingEncoderService = SettingEncoderService
return ____exports
