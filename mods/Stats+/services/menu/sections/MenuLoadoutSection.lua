local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__New = ____lualib.__TS__New
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ArrayEvery = ____lualib.__TS__ArrayEvery
local __TS__InstanceOf = ____lualib.__TS__InstanceOf
local Map = ____lualib.Map
local ____exports = {}
local ____ConfigService = require("services.config.ConfigService")
local ConfigService = ____ConfigService.ConfigService
local ____ExtensionService = require("services.extension.ExtensionService")
local ExtensionService = ____ExtensionService.ExtensionService
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____CORE_STAT_EXTENSIONS = require("data.stat.CORE_STAT_EXTENSIONS")
local CORE_STAT_EXTENSIONS = ____CORE_STAT_EXTENSIONS.CORE_STAT_EXTENSIONS
local ____HashMap = require("structures.HashMap")
local HashMap = ____HashMap.HashMap
local ____speed = require("core.stats.speed")
local speed = ____speed.speed
local ____tears = require("core.stats.tears")
local tears = ____tears.tears
local ____damage = require("core.stats.damage")
local damage = ____damage.damage
local ____range = require("core.stats.range")
local range = ____range.range
local ____shotSpeed = require("core.stats.shotSpeed")
local shotSpeed = ____shotSpeed.shotSpeed
local ____luck = require("core.stats.luck")
local luck = ____luck.luck
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
local ____ProviderSelectSettingOption = require("entities.extension.provider.settings.ProviderSelectSettingOption")
local ProviderSelectSettingOption = ____ProviderSelectSettingOption.ProviderSelectSettingOption
local ____StandaloneConditionExtension = require("entities.extension.condition.standalone.StandaloneConditionExtension")
local StandaloneConditionExtension = ____StandaloneConditionExtension.StandaloneConditionExtension
____exports.MenuLoadoutSection = __TS__Class()
local MenuLoadoutSection = ____exports.MenuLoadoutSection
MenuLoadoutSection.name = "MenuLoadoutSection"
function MenuLoadoutSection.prototype.____constructor(self, configService, extensionService)
    self.configService = configService
    self.extensionService = extensionService
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, ConfigService)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, ExtensionService)
        )
    },
    MenuLoadoutSection
)
function MenuLoadoutSection.prototype.getIdentifier(self)
    return ____exports.MenuLoadoutSection.SECTION_NAME
end
function MenuLoadoutSection.prototype.register(self, menu)
    __TS__ArrayForEach(
        CORE_STAT_EXTENSIONS,
        function(____, stat)
            local name = ____exports.MenuLoadoutSection.STAT_TYPE_SUBSECTION_NAMES:get(stat)
            if name == nil then
                error(
                    __TS__New(ErrorWithContext, "Could not find a name of the stat.", {stat = stat}),
                    0
                )
            end
            self:registerStatSection(menu, stat, name)
        end
    )
end
function MenuLoadoutSection.prototype.registerStatSection(self, menu, stat, subSectionName)
    local loadoutEntry = self.configService:getConfig().loadout:getLoadoutEntry(stat)
    local availableConditions = __TS__ArrayMap(
        __TS__ArrayFilter(
            __TS__ArrayMap(
                self.extensionService:getAvailableConditions(loadoutEntry),
                function(____, extension) return {
                    extension = extension,
                    condition = self.extensionService:getCondition(extension)
                } end
            ),
            function(____, payload) return payload.condition ~= nil end
        ),
        function(____, ____bindingPattern0)
            local condition
            local extension
            extension = ____bindingPattern0.extension
            condition = ____bindingPattern0.condition
            return __TS__New(
                ProviderSelectSettingOption,
                condition:getName(),
                extension
            )
        end
    )
    local availableProviders = __TS__ArrayMap(
        __TS__ArrayFilter(
            __TS__ArrayMap(
                self.extensionService:getAvailableProviders(),
                function(____, extension) return {
                    extension = extension,
                    provider = self.extensionService:getProvider(extension)
                } end
            ),
            function(____, payload)
                local ____opt_0 = payload.provider
                return (____opt_0 and ____opt_0:isStatSupported(stat)) == true
            end
        ),
        function(____, ____bindingPattern0)
            local provider
            local extension
            extension = ____bindingPattern0.extension
            provider = ____bindingPattern0.provider
            return __TS__New(
                ProviderSelectSettingOption,
                provider:getName(),
                extension
            )
        end
    )
    if __TS__ArrayEvery(
        availableProviders,
        function(____, extension) return extension:getValue():isCoreExtension() end
    ) then
        return
    end
    self:registerStatSectionEntities(
        menu,
        stat,
        subSectionName,
        availableProviders,
        availableConditions
    )
end
function MenuLoadoutSection.prototype.registerStatSectionEntities(self, menu, stat, subSectionName, providerOptions, conditionOptions)
    local providerOptionsMap = __TS__New(
        HashMap,
        __TS__ArrayMap(
            providerOptions,
            function(____, key) return {
                key:getValue(),
                key
            } end
        )
    )
    menu:subheading({text = subSectionName}):select({
        name = "When",
        description = {self.extensionService:resolveCondition(self.configService:getConfig().loadout:getLoadoutEntry(stat)):getDescription()},
        options = conditionOptions,
        fallback = function() return __TS__New(
            ProviderSelectSettingOption,
            self.extensionService:getFallbackCondition():getName(),
            self.extensionService:getFallbackCondition():getExtension()
        ) end,
        retrieve = function() return self.configService:getConfig().loadout:getCondition(stat) end,
        update = function(____, condition)
            self.configService:updateConfigAndReload(function(____, config)
                config.loadout:setCondition(stat, condition)
            end)
        end
    }):select({
        name = "Then",
        description = {self.extensionService:resolveProvider(self.configService:getConfig().loadout:getPrimaryProvider(stat)):getDescription()},
        options = providerOptions,
        fallback = function() return __TS__New(
            ProviderSelectSettingOption,
            self.extensionService:getFallbackProvider():getName(),
            self.extensionService:getFallbackProvider():getExtension()
        ) end,
        retrieve = function()
            local current = self.configService:getConfig().loadout:getPrimaryProvider(stat)
            local matching = providerOptionsMap:get(current)
            return matching and matching:getValue()
        end,
        update = function(____, provider)
            self.configService:updateConfigAndReload(function(____, config)
                config.loadout:setPrimaryProvider(stat, provider)
            end)
        end
    }):select({
        name = "Else",
        description = {self.extensionService:resolveProvider(self.configService:getConfig().loadout:getSecondaryProvider(stat)):getDescription()},
        options = providerOptions,
        fallback = function() return __TS__New(
            ProviderSelectSettingOption,
            self.extensionService:getFallbackProvider():getName(),
            self.extensionService:getFallbackProvider():getExtension()
        ) end,
        condition = function()
            local condition = self.configService:getConfig().loadout:getCondition(stat)
            if __TS__InstanceOf(condition, StandaloneConditionExtension) then
                return not condition:isAlwaysCondition()
            end
            return true
        end,
        retrieve = function()
            local current = self.configService:getConfig().loadout:getSecondaryProvider(stat)
            local matching = providerOptionsMap:get(current)
            return matching and matching:getValue()
        end,
        update = function(____, provider)
            self.configService:updateConfigAndReload(function(____, config)
                config.loadout:setSecondaryProvider(stat, provider)
            end)
        end
    }):space()
end
MenuLoadoutSection.SECTION_NAME = "Loadout"
MenuLoadoutSection.STAT_TYPE_SUBSECTION_NAMES = __TS__New(Map, {
    {speed, "Speed"},
    {tears, "Tears"},
    {damage, "Damage"},
    {range, "Range"},
    {shotSpeed, "Shot Speed"},
    {luck, "Luck"}
})
MenuLoadoutSection = __TS__DecorateLegacy(
    {Singleton(nil)},
    MenuLoadoutSection
)
____exports.MenuLoadoutSection = MenuLoadoutSection
return ____exports
