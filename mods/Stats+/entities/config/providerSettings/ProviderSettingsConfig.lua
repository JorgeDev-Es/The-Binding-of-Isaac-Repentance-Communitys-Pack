local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____ProviderSettings = require("entities.config.providerSettings.ProviderSettings")
local ProviderSettings = ____ProviderSettings.ProviderSettings
____exports.ProviderSettingsConfig = __TS__Class()
local ProviderSettingsConfig = ____exports.ProviderSettingsConfig
ProviderSettingsConfig.name = "ProviderSettingsConfig"
function ProviderSettingsConfig.prototype.____constructor(self, extensionService, options)
    self.extensionService = extensionService
    self.providerSettings = options.providerSettings
end
function ProviderSettingsConfig.prototype.clone(self)
    return __TS__New(
        ____exports.ProviderSettingsConfig,
        self.extensionService,
        {providerSettings = self.providerSettings:clone()}
    )
end
function ProviderSettingsConfig.prototype.getProviderSettingsMap(self)
    return self.providerSettings:clone()
end
function ProviderSettingsConfig.prototype.getProviderColor(self, provider)
    local ____opt_0 = self.providerSettings:get(provider:getExtension())
    return ____opt_0 and ____opt_0:getColor() or provider:getPreferredColor()
end
function ProviderSettingsConfig.prototype.getCustomSettingValue(self, settingEncoderService, provider, setting)
    local ____opt_2 = self.providerSettings:get(provider)
    local value = ____opt_2 and ____opt_2:getCustomSettingRawValue(setting:getKey())
    if value == nil then
        return setting:getInitialValue()
    end
    return settingEncoderService:decodeSetting(setting, value)
end
function ProviderSettingsConfig.prototype.setProviderColor(self, provider, providerColor)
    local field = self.providerSettings:get(provider) or ProviderSettings:empty()
    field:setColor(providerColor)
    self.providerSettings:set(provider, field)
end
function ProviderSettingsConfig.prototype.setCustomSettingValue(self, settingEncoderService, provider, setting, value)
    local ____opt_4 = self.extensionService:getProvider(provider)
    local preferredColor = ____opt_4 and ____opt_4:getPreferredColor()
    local field = self.providerSettings:get(provider) or ProviderSettings:empty(preferredColor)
    field:setCustomSettingRawValue(
        setting:getKey(),
        settingEncoderService:encodeSetting(setting, value)
    )
    self.providerSettings:set(provider, field)
end
return ____exports
