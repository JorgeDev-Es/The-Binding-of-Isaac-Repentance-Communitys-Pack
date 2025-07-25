local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray
local __TS__TypeOf = ____lualib.__TS__TypeOf
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ObjectValues = ____lualib.__TS__ObjectValues
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____ProviderColor = require("entities.config.appearance.ProviderColor")
local ProviderColor = ____ProviderColor.ProviderColor
local ____isExtensionRef = require("util.validation.isExtensionRef")
local isExtensionRef = ____isExtensionRef.isExtensionRef
local ____Config = require("entities.config.Config")
local Config = ____Config.Config
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
local ____ProviderStateConfigDTOValidator = require("validators.dto.config.ProviderStateConfigDTOValidator")
local ProviderStateConfigDTOValidator = ____ProviderStateConfigDTOValidator.ProviderStateConfigDTOValidator
____exports.ProviderSettingsConfigDTOValidator = __TS__Class()
local ProviderSettingsConfigDTOValidator = ____exports.ProviderSettingsConfigDTOValidator
ProviderSettingsConfigDTOValidator.name = "ProviderSettingsConfigDTOValidator"
function ProviderSettingsConfigDTOValidator.prototype.____constructor(self)
    self.logger = Logger["for"](Logger, ProviderStateConfigDTOValidator.name)
end
function ProviderSettingsConfigDTOValidator.prototype.validate(self, providerSettings)
    return {settings = self:validateSettings(providerSettings and providerSettings.settings)}
end
function ProviderSettingsConfigDTOValidator.prototype.validateSettings(self, settings)
    if not __TS__ArrayIsArray(settings) then
        self.logger:warn(
            "Expected provider settings entry to be an array.",
            {
                settings = settings,
                type = __TS__TypeOf(settings)
            }
        )
        return Config.DEFAULT_CONFIG.providerSettings.settings
    end
    return __TS__ArrayFilter(
        __TS__ArrayMap(
            settings,
            function(____, entry) return self:validateOptionsEntry(entry) end
        ),
        function(____, entry) return entry ~= nil end
    )
end
function ProviderSettingsConfigDTOValidator.prototype.validateOptionsEntry(self, entry)
    if entry == nil then
        self.logger:warn("Provider settings entry is undefined.")
        return
    end
    if not isExtensionRef(nil, entry.ref) then
        self.logger:warn(
            "Expected ref of the provider settings to be a valid extension ref object.",
            {
                ref = entry.ref,
                type = __TS__TypeOf(entry.ref)
            }
        )
        return
    end
    return {
        ref = entry.ref,
        settings = self:validateSettingsField(entry.settings)
    }
end
function ProviderSettingsConfigDTOValidator.prototype.validateSettingsField(self, settings)
    return {
        color = self:validateProviderColorSetting(settings and settings.color),
        custom = self:validateCustomSettings(settings and settings.custom)
    }
end
function ProviderSettingsConfigDTOValidator.prototype.validateProviderColorSetting(self, color)
    if color == nil or not __TS__ArrayIncludes(
        __TS__ObjectValues(ProviderColor),
        color
    ) then
        self.logger:warn(
            "Invalid value of provider color.",
            {
                color = color,
                type = __TS__TypeOf(color)
            }
        )
        return ProviderColor.None
    end
    return color
end
function ProviderSettingsConfigDTOValidator.prototype.validateCustomSettings(self, customSettings)
    if type(customSettings) ~= "table" then
        self.logger:warn(
            "Expected custom provider settings to an object.",
            {
                customSettings = customSettings,
                type = __TS__TypeOf(customSettings)
            }
        )
        return {}
    end
    return customSettings
end
ProviderSettingsConfigDTOValidator = __TS__DecorateLegacy(
    {Singleton(nil)},
    ProviderSettingsConfigDTOValidator
)
____exports.ProviderSettingsConfigDTOValidator = ProviderSettingsConfigDTOValidator
return ____exports
