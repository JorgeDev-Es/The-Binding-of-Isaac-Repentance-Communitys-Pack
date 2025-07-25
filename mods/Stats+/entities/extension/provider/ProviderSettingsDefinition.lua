local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ObjectEntries = ____lualib.__TS__ObjectEntries
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____ProviderRangeSetting = require("entities.extension.provider.settings.ProviderRangeSetting")
local ProviderRangeSetting = ____ProviderRangeSetting.ProviderRangeSetting
local ____ProviderToggleSetting = require("entities.extension.provider.settings.ProviderToggleSetting")
local ProviderToggleSetting = ____ProviderToggleSetting.ProviderToggleSetting
local ____ProviderSelectSetting = require("entities.extension.provider.settings.ProviderSelectSetting")
local ProviderSelectSetting = ____ProviderSelectSetting.ProviderSelectSetting
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
____exports.ProviderSettingsDefinition = __TS__Class()
local ProviderSettingsDefinition = ____exports.ProviderSettingsDefinition
ProviderSettingsDefinition.name = "ProviderSettingsDefinition"
function ProviderSettingsDefinition.prototype.____constructor(self, settings)
    self.settings = settings
end
function ProviderSettingsDefinition.prototype.getSettings(self)
    return __TS__ArrayMap(
        __TS__ObjectEntries(self.settings),
        function(____, ____bindingPattern0)
            local definition
            local key
            key = ____bindingPattern0[1]
            definition = ____bindingPattern0[2]
            if definition.type == "RANGE" then
                return __TS__New(ProviderRangeSetting, key, definition)
            end
            if definition.type == "TOGGLE" then
                return __TS__New(ProviderToggleSetting, key, definition)
            end
            if definition.type == "SELECT" then
                return __TS__New(ProviderSelectSetting, key, definition)
            end
            error(
                __TS__New(ErrorWithContext, "Unknown setting type.", {settingType = definition.type}),
                0
            )
        end
    )
end
return ____exports
