local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__TypeOf = ____lualib.__TS__TypeOf
local ____exports = {}
local ____isExtensionRef = require("util.validation.isExtensionRef")
local isExtensionRef = ____isExtensionRef.isExtensionRef
local ____Config = require("entities.config.Config")
local Config = ____Config.Config
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
local ____ConditionType = require("entities.extension.condition.ConditionType")
local ConditionType = ____ConditionType.ConditionType
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____ExtensionService = require("services.extension.ExtensionService")
local ExtensionService = ____ExtensionService.ExtensionService
local ____ConfigMapper = require("mappers.config.ConfigMapper")
local ConfigMapper = ____ConfigMapper.ConfigMapper
____exports.LoadoutConfigDTOValidator = __TS__Class()
local LoadoutConfigDTOValidator = ____exports.LoadoutConfigDTOValidator
LoadoutConfigDTOValidator.name = "LoadoutConfigDTOValidator"
function LoadoutConfigDTOValidator.prototype.____constructor(self, configMapper, extensionService)
    self.configMapper = configMapper
    self.extensionService = extensionService
    self.logger = Logger["for"](Logger, ____exports.LoadoutConfigDTOValidator.name)
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, ConfigMapper)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, ExtensionService)
        )
    },
    LoadoutConfigDTOValidator
)
function LoadoutConfigDTOValidator.prototype.validate(self, loadout)
    if loadout == nil or not __TS__ArrayIsArray(loadout) then
        self.logger:warn("Expected loadout config to be an array.")
        return Config.DEFAULT_CONFIG.loadout
    end
    return __TS__ArrayFilter(
        __TS__ArrayMap(
            loadout,
            function(____, entry) return self:getValidatedLoadoutEntry(entry) end
        ),
        function(____, entry) return entry ~= nil end
    )
end
function LoadoutConfigDTOValidator.prototype.getValidatedLoadoutEntry(self, loadoutEntry)
    if type(loadoutEntry) ~= "table" or loadoutEntry == nil then
        self.logger:warn("Expected loadout config entry to be an object.")
        return nil
    end
    local stat = self:getValidatedStatExtension(loadoutEntry.stat)
    if stat == nil then
        return nil
    end
    return {
        stat = stat,
        primaryProvider = self:getValidatedPrimaryProvider(stat, loadoutEntry.primaryProvider),
        secondaryProvider = self:getValidatedSecondaryProvider(stat, loadoutEntry.secondaryProvider),
        condition = self:getValidatedCondition(stat, loadoutEntry.condition)
    }
end
function LoadoutConfigDTOValidator.prototype.getValidatedPrimaryProvider(self, stat, primaryProvider)
    if not isExtensionRef(nil, primaryProvider) then
        self.logger:warn(
            "Expected the primary provider to be an extension ref.",
            {
                stat = stat,
                primaryProvider = primaryProvider,
                primaryProviderType = __TS__TypeOf(primaryProvider)
            }
        )
        return self.configMapper:toProviderExtensionDTO(self.extensionService:getFallbackProvider():getExtension())
    end
    return primaryProvider
end
function LoadoutConfigDTOValidator.prototype.getValidatedSecondaryProvider(self, stat, secondaryProvider)
    if not isExtensionRef(nil, secondaryProvider) then
        self.logger:warn(
            "Expected the secondary provider to be an extension ref.",
            {
                stat = stat,
                secondaryProvider = secondaryProvider,
                secondaryProviderType = __TS__TypeOf(secondaryProvider)
            }
        )
        return self.configMapper:toProviderExtensionDTO(self.extensionService:getFallbackProvider():getExtension())
    end
    return secondaryProvider
end
function LoadoutConfigDTOValidator.prototype.getValidatedCondition(self, stat, condition)
    if (condition and condition.type) == ConditionType.Standalone then
        return self:getValidatedStandaloneCondition(stat, condition)
    end
    if (condition and condition.type) == ConditionType.Companion then
        return self:getValidatedCompanionCondition(stat, condition)
    end
    self.logger:warn(
        "Expected the condition to be either a standalone or companion condition extension.",
        {
            stat = stat,
            condition = condition,
            conditionType = __TS__TypeOf(condition)
        }
    )
    return self.configMapper:toConditionExtensionDTO(self.extensionService:getFallbackCondition():getExtension())
end
function LoadoutConfigDTOValidator.prototype.getValidatedStandaloneCondition(self, stat, condition)
    local ____opt_4 = condition and condition.ref
    if type(____opt_4 and ____opt_4.id) ~= "string" then
        local ____self_18 = self.logger
        local ____self_18_warn_19 = ____self_18.warn
        local ____stat_16 = stat
        local ____opt_8 = condition and condition.ref
        local ____temp_17 = ____opt_8 and ____opt_8.id
        local ____opt_12 = condition and condition.ref
        ____self_18_warn_19(
            ____self_18,
            "Expected standalone condition's ref.id to be a string",
            {
                stat = ____stat_16,
                refId = ____temp_17,
                refIdType = __TS__TypeOf(____opt_12 and ____opt_12.id)
            }
        )
        return self.configMapper:toConditionExtensionDTO(self.extensionService:getFallbackCondition():getExtension())
    end
    local ____opt_20 = condition and condition.ref
    if type(____opt_20 and ____opt_20.addon) ~= "string" then
        local ____self_34 = self.logger
        local ____self_34_warn_35 = ____self_34.warn
        local ____stat_32 = stat
        local ____opt_24 = condition and condition.ref
        local ____temp_33 = ____opt_24 and ____opt_24.addon
        local ____opt_28 = condition and condition.ref
        ____self_34_warn_35(
            ____self_34,
            "Expected standalone condition's ref.addon to be a string",
            {
                stat = ____stat_32,
                refAddon = ____temp_33,
                refAddonType = __TS__TypeOf(____opt_28 and ____opt_28.addon)
            }
        )
        return self.configMapper:toConditionExtensionDTO(self.extensionService:getFallbackCondition():getExtension())
    end
    return condition
end
function LoadoutConfigDTOValidator.prototype.getValidatedCompanionCondition(self, stat, condition)
    if type(condition and condition.id) ~= "string" then
        self.logger:warn(
            "Expected companion's condition id to be a string",
            {
                stat = stat,
                id = condition and condition.id,
                idType = __TS__TypeOf(condition and condition.id)
            }
        )
        return self.configMapper:toConditionExtensionDTO(self.extensionService:getFallbackCondition():getExtension())
    end
    local ____opt_42 = condition and condition.providerRef
    if type(____opt_42 and ____opt_42.id) ~= "string" then
        local ____self_56 = self.logger
        local ____self_56_warn_57 = ____self_56.warn
        local ____stat_54 = stat
        local ____opt_46 = condition and condition.providerRef
        local ____temp_55 = ____opt_46 and ____opt_46.id
        local ____opt_50 = condition and condition.providerRef
        ____self_56_warn_57(
            ____self_56,
            "Expected companion's condition providerRef.id to be a string",
            {
                stat = ____stat_54,
                refId = ____temp_55,
                refIdType = __TS__TypeOf(____opt_50 and ____opt_50.id)
            }
        )
        return self.configMapper:toConditionExtensionDTO(self.extensionService:getFallbackCondition():getExtension())
    end
    local ____opt_58 = condition and condition.providerRef
    if type(____opt_58 and ____opt_58.addon) ~= "string" then
        local ____self_72 = self.logger
        local ____self_72_warn_73 = ____self_72.warn
        local ____stat_70 = stat
        local ____opt_62 = condition and condition.providerRef
        local ____temp_71 = ____opt_62 and ____opt_62.addon
        local ____opt_66 = condition and condition.providerRef
        ____self_72_warn_73(
            ____self_72,
            "Expected companion's condition providerRef.addon to be a string",
            {
                stat = ____stat_70,
                refAddon = ____temp_71,
                refAddonType = __TS__TypeOf(____opt_66 and ____opt_66.addon)
            }
        )
        return self.configMapper:toConditionExtensionDTO(self.extensionService:getFallbackCondition():getExtension())
    end
    return condition
end
function LoadoutConfigDTOValidator.prototype.getValidatedStatExtension(self, statExtensionDTO)
    if type(statExtensionDTO and statExtensionDTO.id) ~= "string" then
        self.logger:warn("Expected stat extension id to be a string.")
        return nil
    end
    if type(statExtensionDTO and statExtensionDTO.addon) ~= "string" then
        self.logger:warn("Expected stat extension addon to be a string.")
        return nil
    end
    return statExtensionDTO
end
LoadoutConfigDTOValidator = __TS__DecorateLegacy(
    {Singleton(nil)},
    LoadoutConfigDTOValidator
)
____exports.LoadoutConfigDTOValidator = LoadoutConfigDTOValidator
return ____exports
