local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ObjectFromEntries = ____lualib.__TS__ObjectFromEntries
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____ConfigService = require("services.config.ConfigService")
local ConfigService = ____ConfigService.ConfigService
local ____SettingEncoderService = require("services.extension.SettingEncoderService")
local SettingEncoderService = ____SettingEncoderService.SettingEncoderService
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____ResolvedSettings = require("entities.extension.provider.handle.ResolvedSettings")
local ResolvedSettings = ____ResolvedSettings.ResolvedSettings
____exports.SettingsResolver = __TS__Class()
local SettingsResolver = ____exports.SettingsResolver
SettingsResolver.name = "SettingsResolver"
function SettingsResolver.prototype.____constructor(self, configService, settingEncoderService)
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
    SettingsResolver
)
function SettingsResolver.prototype.resolveSettings(self, provider)
    local resolvedCustomSettingEntries = __TS__ArrayMap(
        provider:getSettings():getSettings(),
        function(____, setting)
            local value = self.configService:getConfig().providerSettings:getCustomSettingValue(
                self.settingEncoderService,
                provider:getExtension(),
                setting
            )
            return {
                setting:getKey(),
                value
            }
        end
    )
    return __TS__New(
        ResolvedSettings,
        {
            color = self.configService:getConfig().providerSettings:getProviderColor(provider),
            custom = __TS__ObjectFromEntries(resolvedCustomSettingEntries)
        }
    )
end
SettingsResolver = __TS__DecorateLegacy(
    {Singleton(nil)},
    SettingsResolver
)
____exports.SettingsResolver = SettingsResolver
return ____exports
