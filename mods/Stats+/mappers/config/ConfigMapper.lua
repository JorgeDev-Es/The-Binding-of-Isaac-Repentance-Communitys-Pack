local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__New = ____lualib.__TS__New
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__InstanceOf = ____lualib.__TS__InstanceOf
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local ____exports = {}
local ____LoadoutConfigEntry = require("entities.config.loadout.LoadoutConfigEntry")
local LoadoutConfigEntry = ____LoadoutConfigEntry.LoadoutConfigEntry
local ____ProviderSettings = require("entities.config.providerSettings.ProviderSettings")
local ProviderSettings = ____ProviderSettings.ProviderSettings
local ____Config = require("entities.config.Config")
local Config = ____Config.Config
local ____AppearanceConfig = require("entities.config.appearance.AppearanceConfig")
local AppearanceConfig = ____AppearanceConfig.AppearanceConfig
local ____LoadoutConfig = require("entities.config.loadout.LoadoutConfig")
local LoadoutConfig = ____LoadoutConfig.LoadoutConfig
local ____ProviderSettingsConfig = require("entities.config.providerSettings.ProviderSettingsConfig")
local ProviderSettingsConfig = ____ProviderSettingsConfig.ProviderSettingsConfig
local ____ProviderStateConfig = require("entities.config.providerState.ProviderStateConfig")
local ProviderStateConfig = ____ProviderStateConfig.ProviderStateConfig
local ____ProviderExtension = require("entities.extension.provider.ProviderExtension")
local ProviderExtension = ____ProviderExtension.ProviderExtension
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____HashMap = require("structures.HashMap")
local HashMap = ____HashMap.HashMap
local ____StandaloneConditionExtension = require("entities.extension.condition.standalone.StandaloneConditionExtension")
local StandaloneConditionExtension = ____StandaloneConditionExtension.StandaloneConditionExtension
local ____CompanionConditionExtension = require("entities.extension.condition.companion.CompanionConditionExtension")
local CompanionConditionExtension = ____CompanionConditionExtension.CompanionConditionExtension
local ____ConditionType = require("entities.extension.condition.ConditionType")
local ConditionType = ____ConditionType.ConditionType
local ____StatExtension = require("entities.extension.stat.StatExtension")
local StatExtension = ____StatExtension.StatExtension
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____ExtensionService = require("services.extension.ExtensionService")
local ExtensionService = ____ExtensionService.ExtensionService
____exports.ConfigMapper = __TS__Class()
local ConfigMapper = ____exports.ConfigMapper
ConfigMapper.name = "ConfigMapper"
function ConfigMapper.prototype.____constructor(self, extensionService)
    self.extensionService = extensionService
end
__TS__DecorateLegacy(
    {__TS__DecorateParam(
        0,
        Inject(nil, ExtensionService)
    )},
    ConfigMapper
)
function ConfigMapper.prototype.toConfig(self, configDTO)
    local loadout = __TS__New(
        HashMap,
        __TS__ArrayMap(
            configDTO.loadout,
            function(____, entry) return {entry.stat, entry} end
        )
    )
    return __TS__New(
        Config,
        configDTO.configVersion,
        __TS__New(AppearanceConfig, {
            textOpacity = configDTO.appearance.textOpacity,
            bracketStyle = configDTO.appearance.bracketStyle,
            spacing = configDTO.appearance.spacing,
            showProviderChanges = configDTO.appearance.showProviderChanges,
            useShaderColorFix = configDTO.appearance.useShaderColorFix
        }),
        __TS__New(
            LoadoutConfig,
            {entries = __TS__New(
                HashMap,
                __TS__ArrayMap(
                    __TS__ArrayFrom(loadout:entries()),
                    function(____, ____bindingPattern0)
                        local loadoutConfigEntryDTO
                        local stat
                        stat = ____bindingPattern0[1]
                        loadoutConfigEntryDTO = ____bindingPattern0[2]
                        return {
                            self:toStatExtension(stat),
                            self:toLoadoutConfigEntry(loadoutConfigEntryDTO)
                        }
                    end
                )
            )}
        ),
        __TS__New(
            ProviderSettingsConfig,
            self.extensionService,
            {providerSettings = __TS__New(
                HashMap,
                __TS__ArrayMap(
                    configDTO.providerSettings.settings,
                    function(____, ____bindingPattern0)
                        local settings
                        local ref
                        ref = ____bindingPattern0.ref
                        settings = ____bindingPattern0.settings
                        return {
                            __TS__New(ProviderExtension, ref),
                            self:toProviderSettings(settings)
                        }
                    end
                )
            )}
        ),
        __TS__New(
            ProviderStateConfig,
            {providerState = __TS__New(
                HashMap,
                __TS__ArrayMap(
                    configDTO.providerState.state,
                    function(____, ____bindingPattern0)
                        local state
                        local ref
                        ref = ____bindingPattern0.ref
                        state = ____bindingPattern0.state
                        return {
                            __TS__New(ProviderExtension, ref),
                            state
                        }
                    end
                )
            )}
        )
    )
end
function ConfigMapper.prototype.toDTO(self, config)
    return {
        configVersion = config.configVersion,
        appearance = {
            textOpacity = config.appearance:getTextOpacity(),
            bracketStyle = config.appearance:getBracketStyle(),
            spacing = config.appearance:getSpacing(),
            showProviderChanges = config.appearance:showsProviderChanges(),
            useShaderColorFix = config.appearance:usesShaderColorFix()
        },
        loadout = __TS__ArrayMap(
            __TS__ArrayFilter(
                __TS__ArrayMap(
                    config.loadout:getActiveStats(),
                    function(____, stat) return config.loadout:getLoadoutEntry(stat) end
                ),
                function(____, entryOrUndefined) return entryOrUndefined ~= nil end
            ),
            function(____, entry) return self:toLoadoutEntryDTO(entry) end
        ),
        providerSettings = {settings = __TS__ArrayMap(
            __TS__ArrayFrom(config.providerSettings:getProviderSettingsMap():entries()),
            function(____, ____bindingPattern0)
                local settings
                local providerExtension
                providerExtension = ____bindingPattern0[1]
                settings = ____bindingPattern0[2]
                return {
                    ref = self:toProviderExtensionDTO(providerExtension),
                    settings = self:toProviderSettingsDTO(settings)
                }
            end
        )},
        providerState = {state = __TS__ArrayMap(
            __TS__ArrayFrom(config.providerState:getProviderStateMap():entries()),
            function(____, ____bindingPattern0)
                local state
                local providerExtension
                providerExtension = ____bindingPattern0[1]
                state = ____bindingPattern0[2]
                return {
                    ref = self:toProviderExtensionDTO(providerExtension),
                    state = state
                }
            end
        )}
    }
end
function ConfigMapper.prototype.toConditionExtensionDTO(self, conditionExtension)
    if __TS__InstanceOf(conditionExtension, StandaloneConditionExtension) then
        return {type = ConditionType.Standalone, ref = {addon = conditionExtension.addonId, id = conditionExtension.standaloneConditionId}}
    end
    if __TS__InstanceOf(conditionExtension, CompanionConditionExtension) then
        return {
            type = ConditionType.Companion,
            providerRef = self:toProviderExtensionDTO(conditionExtension.providerExtension),
            id = conditionExtension.id
        }
    end
    error(
        __TS__New(Error, "Could not map a condition extension: it is neither an instance of StandaloneConditionExtension nor CompanionConditionExtension."),
        0
    )
end
function ConfigMapper.prototype.toProviderExtensionDTO(self, providerExtension)
    return {addon = providerExtension.addonId, id = providerExtension.providerId}
end
function ConfigMapper.prototype.toProviderSettings(self, providerSettingsDTO)
    return __TS__New(ProviderSettings, providerSettingsDTO.custom, providerSettingsDTO.color)
end
function ConfigMapper.prototype.toProviderSettingsDTO(self, providerSettings)
    return {
        custom = providerSettings:getAllCustomSettings(),
        color = providerSettings:getColor()
    }
end
function ConfigMapper.prototype.toLoadoutConfigEntry(self, loadoutConfigEntryDTO)
    return __TS__New(
        LoadoutConfigEntry,
        {
            stat = self:toStatExtension(loadoutConfigEntryDTO.stat),
            primaryProvider = self:toProviderExtension(loadoutConfigEntryDTO.primaryProvider),
            secondaryProvider = self:toProviderExtension(loadoutConfigEntryDTO.secondaryProvider),
            condition = self:toConditionExtension(loadoutConfigEntryDTO.condition)
        }
    )
end
function ConfigMapper.prototype.toLoadoutEntryDTO(self, loadoutConfigEntry)
    return {
        stat = self:toStatExtensionDTO(loadoutConfigEntry:getStat()),
        primaryProvider = self:toProviderExtensionDTO(loadoutConfigEntry:getPrimaryProvider()),
        secondaryProvider = self:toProviderExtensionDTO(loadoutConfigEntry:getSecondaryProvider()),
        condition = self:toConditionExtensionDTO(loadoutConfigEntry:getCondition())
    }
end
function ConfigMapper.prototype.toConditionExtension(self, conditionDTO)
    if conditionDTO.type == ConditionType.Standalone then
        return __TS__New(StandaloneConditionExtension, conditionDTO.ref)
    end
    if conditionDTO.type == ConditionType.Companion then
        return __TS__New(
            CompanionConditionExtension,
            __TS__New(ProviderExtension, conditionDTO.providerRef),
            conditionDTO.id
        )
    end
    error(
        __TS__New(Error, "Could not map a condition extension DTO: its' type is neither ConditionType.Standalone nor ConditionType.Companion."),
        0
    )
end
function ConfigMapper.prototype.toProviderExtension(self, providerExtensionDTO)
    return __TS__New(ProviderExtension, providerExtensionDTO)
end
function ConfigMapper.prototype.toStatExtension(self, statExtensionDTO)
    return __TS__New(StatExtension, statExtensionDTO)
end
function ConfigMapper.prototype.toStatExtensionDTO(self, statExtension)
    return {addon = statExtension.addonId, id = statExtension.statId}
end
ConfigMapper = __TS__DecorateLegacy(
    {Singleton(nil)},
    ConfigMapper
)
____exports.ConfigMapper = ConfigMapper
return ____exports
