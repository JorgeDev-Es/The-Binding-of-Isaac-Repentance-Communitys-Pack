local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__New = ____lualib.__TS__New
local __TS__ObjectValues = ____lualib.__TS__ObjectValues
local ____exports = {}
local ____ProviderColor = require("entities.config.appearance.ProviderColor")
local ProviderColor = ____ProviderColor.ProviderColor
local ____ExtensionService = require("services.extension.ExtensionService")
local ExtensionService = ____ExtensionService.ExtensionService
local ____ConfigService = require("services.config.ConfigService")
local ConfigService = ____ConfigService.ConfigService
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
local ____ModConfigMenuSettingMapper = require("services.extension.provider.ModConfigMenuSettingMapper")
local ModConfigMenuSettingMapper = ____ModConfigMenuSettingMapper.ModConfigMenuSettingMapper
local ____ProviderSelectSettingOption = require("entities.extension.provider.settings.ProviderSelectSettingOption")
local ProviderSelectSettingOption = ____ProviderSelectSettingOption.ProviderSelectSettingOption
____exports.MenuProvidersSection = __TS__Class()
local MenuProvidersSection = ____exports.MenuProvidersSection
MenuProvidersSection.name = "MenuProvidersSection"
function MenuProvidersSection.prototype.____constructor(self, configService, extensionService, modConfigMenuSettingMapper)
    self.configService = configService
    self.extensionService = extensionService
    self.modConfigMenuSettingMapper = modConfigMenuSettingMapper
    self.logger = Logger["for"](Logger, ____exports.MenuProvidersSection.name)
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
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, ModConfigMenuSettingMapper)
        )
    },
    MenuProvidersSection
)
function MenuProvidersSection.prototype.getIdentifier(self)
    return ____exports.MenuProvidersSection.SUBCATEGORY_NAME
end
function MenuProvidersSection.prototype.register(self, menu)
    self:registerCurrentlyInUseSubsection(menu)
    menu:space()
    self:registerAllProvidersSubsection(menu)
end
function MenuProvidersSection.prototype.registerCurrentlyInUseSubsection(self, menu)
    menu:heading({text = ____exports.MenuProvidersSection.CURRENTLY_IN_USE_SUBSECTION_NAME})
    menu:space()
    self:registerProviders(
        menu,
        self.configService:getConfig().loadout:getCurrentlyUsedProviders()
    )
end
function MenuProvidersSection.prototype.registerAllProvidersSubsection(self, menu)
    menu:heading({text = ____exports.MenuProvidersSection.ALL_PROVIDERS_SUBSECTION_NAME})
    menu:space()
    self:registerProviders(
        menu,
        self.extensionService:getAvailableProviders()
    )
end
function MenuProvidersSection.prototype.registerProviders(self, menu, providers)
    __TS__ArrayForEach(
        providers,
        function(____, extension)
            local provider = self.extensionService:getProvider(extension)
            if provider == nil then
                self.logger:warn("Could not find provider for extension, skipping provider options registration.", {providerId = extension.providerId, addonId = extension.addonId})
                return
            end
            if provider:getExtension():isCoreExtension() then
                return
            end
            menu:subheading({text = provider:getName()})
            self:registerBuiltInSettings(menu, provider)
            self:registerCustomSettings(menu, provider)
            menu:space()
        end
    )
end
function MenuProvidersSection.prototype.registerBuiltInSettings(self, menu, provider)
    menu:select({
        fallback = function() return __TS__New(ProviderSelectSettingOption, "None", ProviderColor.None) end,
        name = "Color",
        description = {"Color of the provider"},
        options = ____exports.MenuProvidersSection.AVAILABLE_COLOR_OPTIONS,
        retrieve = function() return self.configService:getConfig().providerSettings:getProviderColor(provider) end,
        update = function(____, value)
            self.configService:updateConfigAndReload(function(____, config)
                config.providerSettings:setProviderColor(
                    provider:getExtension(),
                    value
                )
            end)
        end
    })
end
function MenuProvidersSection.prototype.registerCustomSettings(self, menu, provider)
    __TS__ArrayForEach(
        __TS__ObjectValues(provider:getSettings():getSettings()),
        function(____, setting)
            local entity = self.modConfigMenuSettingMapper:map(
                provider:getExtension(),
                setting
            )
            menu:register(entity)
        end
    )
end
MenuProvidersSection.SUBCATEGORY_NAME = "Providers"
MenuProvidersSection.CURRENTLY_IN_USE_SUBSECTION_NAME = "Currently In Use"
MenuProvidersSection.ALL_PROVIDERS_SUBSECTION_NAME = "All Providers"
MenuProvidersSection.AVAILABLE_COLOR_OPTIONS = {
    __TS__New(ProviderSelectSettingOption, "None", ProviderColor.None),
    __TS__New(ProviderSelectSettingOption, "Grey", ProviderColor.Grey),
    __TS__New(ProviderSelectSettingOption, "Red", ProviderColor.Red),
    __TS__New(ProviderSelectSettingOption, "Green", ProviderColor.Green),
    __TS__New(ProviderSelectSettingOption, "Blue", ProviderColor.Blue),
    __TS__New(ProviderSelectSettingOption, "Orange", ProviderColor.Orange),
    __TS__New(ProviderSelectSettingOption, "Magenta", ProviderColor.Magenta),
    __TS__New(ProviderSelectSettingOption, "Cyan", ProviderColor.Cyan)
}
MenuProvidersSection = __TS__DecorateLegacy(
    {Singleton(nil)},
    MenuProvidersSection
)
____exports.MenuProvidersSection = MenuProvidersSection
return ____exports
