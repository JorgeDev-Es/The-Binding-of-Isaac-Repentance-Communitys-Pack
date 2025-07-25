local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__TypeOf = ____lualib.__TS__TypeOf
local ____exports = {}
local ____AppearanceConfigDTOValidator = require("validators.dto.config.AppearanceConfigDTOValidator")
local AppearanceConfigDTOValidator = ____AppearanceConfigDTOValidator.AppearanceConfigDTOValidator
local ____LoadoutConfigDTOValidator = require("validators.dto.config.LoadoutConfigDTOValidator")
local LoadoutConfigDTOValidator = ____LoadoutConfigDTOValidator.LoadoutConfigDTOValidator
local ____ProviderSettingsConfigDTOValidator = require("validators.dto.config.ProviderSettingsConfigDTOValidator")
local ProviderSettingsConfigDTOValidator = ____ProviderSettingsConfigDTOValidator.ProviderSettingsConfigDTOValidator
local ____ProviderStateConfigDTOValidator = require("validators.dto.config.ProviderStateConfigDTOValidator")
local ProviderStateConfigDTOValidator = ____ProviderStateConfigDTOValidator.ProviderStateConfigDTOValidator
local ____Config = require("entities.config.Config")
local Config = ____Config.Config
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
____exports.ConfigDTOValidator = __TS__Class()
local ConfigDTOValidator = ____exports.ConfigDTOValidator
ConfigDTOValidator.name = "ConfigDTOValidator"
function ConfigDTOValidator.prototype.____constructor(self, appearanceConfigDTOValidator, loadoutConfigDTOValidator, providerSettingsConfigDTOValidator, stateConfigDTOValidator)
    self.appearanceConfigDTOValidator = appearanceConfigDTOValidator
    self.loadoutConfigDTOValidator = loadoutConfigDTOValidator
    self.providerSettingsConfigDTOValidator = providerSettingsConfigDTOValidator
    self.stateConfigDTOValidator = stateConfigDTOValidator
    self.logger = Logger["for"](Logger, ____exports.ConfigDTOValidator.name)
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, AppearanceConfigDTOValidator)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, LoadoutConfigDTOValidator)
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, ProviderSettingsConfigDTOValidator)
        ),
        __TS__DecorateParam(
            3,
            Inject(nil, ProviderStateConfigDTOValidator)
        )
    },
    ConfigDTOValidator
)
function ConfigDTOValidator.prototype.getValidConfigDTO(self, baseConfigDTO)
    if baseConfigDTO == nil then
        return Config.DEFAULT_CONFIG
    end
    if baseConfigDTO.configVersion ~= Config.LATEST_CONFIG_VERSION then
        self.logger:warn(
            "Expected config version to equal the latest one, overriding given config with the default one.",
            {
                configVersion = baseConfigDTO.configVersion,
                type = __TS__TypeOf(baseConfigDTO.configVersion),
                latestConfigVersion = Config.LATEST_CONFIG_VERSION
            }
        )
        return Config.DEFAULT_CONFIG
    end
    return {
        configVersion = baseConfigDTO.configVersion,
        appearance = self.appearanceConfigDTOValidator:validate(baseConfigDTO.appearance),
        loadout = self.loadoutConfigDTOValidator:validate(baseConfigDTO.loadout),
        providerSettings = self.providerSettingsConfigDTOValidator:validate(baseConfigDTO.providerSettings),
        providerState = self.stateConfigDTOValidator:validate(baseConfigDTO.providerState)
    }
end
ConfigDTOValidator = __TS__DecorateLegacy(
    {Singleton(nil)},
    ConfigDTOValidator
)
____exports.ConfigDTOValidator = ConfigDTOValidator
return ____exports
