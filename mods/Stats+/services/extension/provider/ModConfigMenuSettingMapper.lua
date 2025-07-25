local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__InstanceOf = ____lualib.__TS__InstanceOf
local __TS__TypeOf = ____lualib.__TS__TypeOf
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____ConfigService = require("services.config.ConfigService")
local ConfigService = ____ConfigService.ConfigService
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____SettingEncoderService = require("services.extension.SettingEncoderService")
local SettingEncoderService = ____SettingEncoderService.SettingEncoderService
local ____ModConfigMenuSelect = require("entities.menu.mcm.entities.ModConfigMenuSelect")
local ModConfigMenuSelect = ____ModConfigMenuSelect.ModConfigMenuSelect
local ____ModConfigMenuRange = require("entities.menu.mcm.entities.ModConfigMenuRange")
local ModConfigMenuRange = ____ModConfigMenuRange.ModConfigMenuRange
local ____ModConfigMenuToggle = require("entities.menu.mcm.entities.ModConfigMenuToggle")
local ModConfigMenuToggle = ____ModConfigMenuToggle.ModConfigMenuToggle
local ____ProviderToggleSetting = require("entities.extension.provider.settings.ProviderToggleSetting")
local ProviderToggleSetting = ____ProviderToggleSetting.ProviderToggleSetting
local ____ProviderRangeSetting = require("entities.extension.provider.settings.ProviderRangeSetting")
local ProviderRangeSetting = ____ProviderRangeSetting.ProviderRangeSetting
local ____ProviderSelectSetting = require("entities.extension.provider.settings.ProviderSelectSetting")
local ProviderSelectSetting = ____ProviderSelectSetting.ProviderSelectSetting
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
____exports.ModConfigMenuSettingMapper = __TS__Class()
local ModConfigMenuSettingMapper = ____exports.ModConfigMenuSettingMapper
ModConfigMenuSettingMapper.name = "ModConfigMenuSettingMapper"
function ModConfigMenuSettingMapper.prototype.____constructor(self, configService, settingEncoderService)
    self.configService = configService
    self.settingEncoderService = settingEncoderService
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, ConfigService)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, SettingEncoderService)
        )
    },
    ModConfigMenuSettingMapper
)
function ModConfigMenuSettingMapper.prototype.map(self, provider, setting)
    if __TS__InstanceOf(setting, ProviderToggleSetting) then
        return self:mapToggle(provider, setting)
    end
    if __TS__InstanceOf(setting, ProviderRangeSetting) then
        return self:mapRange(provider, setting)
    end
    if __TS__InstanceOf(setting, ProviderSelectSetting) then
        return self:mapSelect(provider, setting)
    end
    error(
        __TS__New(
            ErrorWithContext,
            "Unknown MCM setting definition.",
            {
                setting = setting,
                settingType = __TS__TypeOf(setting)
            }
        ),
        0
    )
end
function ModConfigMenuSettingMapper.prototype.mapToggle(self, provider, toggle)
    return __TS__New(
        ModConfigMenuToggle,
        {
            name = toggle:getName(),
            description = {toggle:getDescription()},
            retrieve = function() return self.configService:getConfig().providerSettings:getCustomSettingValue(self.settingEncoderService, provider, toggle) end,
            update = function(____, customSettingValue)
                self.configService:updateConfigAndReload(function(____, config)
                    config.providerSettings:setCustomSettingValue(self.settingEncoderService, provider, toggle, customSettingValue)
                end)
            end
        }
    )
end
function ModConfigMenuSettingMapper.prototype.mapRange(self, provider, range)
    return __TS__New(
        ModConfigMenuRange,
        {
            name = range:getName(),
            description = {range:getDescription()},
            min = range:getMinValue(),
            max = range:getMaxValue(),
            retrieve = function() return self.configService:getConfig().providerSettings:getCustomSettingValue(self.settingEncoderService, provider, range) end,
            update = function(____, customSettingValue)
                self.configService:updateConfigAndReload(function(____, config)
                    config.providerSettings:setCustomSettingValue(self.settingEncoderService, provider, range, customSettingValue)
                end)
            end
        }
    )
end
function ModConfigMenuSettingMapper.prototype.mapSelect(self, provider, select)
    return __TS__New(
        ModConfigMenuSelect,
        {
            fallback = function() return select:getOptions()[1] end,
            name = select:getName(),
            description = {select:getDescription()},
            options = select:getOptions(),
            retrieve = function() return self.configService:getConfig().providerSettings:getCustomSettingValue(self.settingEncoderService, provider, select) end,
            update = function(____, value)
                self.configService:updateConfigAndReload(function(____, config)
                    config.providerSettings:setCustomSettingValue(self.settingEncoderService, provider, select, value)
                end)
            end
        }
    )
end
ModConfigMenuSettingMapper = __TS__DecorateLegacy(
    {Singleton(nil)},
    ModConfigMenuSettingMapper
)
____exports.ModConfigMenuSettingMapper = ModConfigMenuSettingMapper
return ____exports
