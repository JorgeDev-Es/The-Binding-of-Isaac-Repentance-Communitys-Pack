local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__TypeOf = ____lualib.__TS__TypeOf
local __TS__New = ____lualib.__TS__New
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____ProviderSelectSettingOption = require("entities.extension.provider.settings.ProviderSelectSettingOption")
local ProviderSelectSettingOption = ____ProviderSelectSettingOption.ProviderSelectSettingOption
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
____exports.ProviderSelectSetting = __TS__Class()
local ProviderSelectSetting = ____exports.ProviderSelectSetting
ProviderSelectSetting.name = "ProviderSelectSetting"
function ProviderSelectSetting.prototype.____constructor(self, key, definition)
    self.key = key
    self.definition = definition
end
function ProviderSelectSetting.prototype.getKey(self)
    return self.key
end
function ProviderSelectSetting.prototype.getName(self)
    return self.definition.name
end
function ProviderSelectSetting.prototype.getDescription(self)
    return self.definition.description
end
function ProviderSelectSetting.prototype.getInitialValue(self)
    local initialIndex = self.definition.initial()
    local option = self:getOptions()[initialIndex + 1]
    if option == nil then
        error(
            __TS__New(
                ErrorWithContext,
                "Could not obtain an initial select value by an index.",
                {
                    initialIndex = initialIndex,
                    initialIndexType = __TS__TypeOf(initialIndex)
                }
            ),
            0
        )
    end
    return option:getValue()
end
function ProviderSelectSetting.prototype.getOptions(self)
    return __TS__ArrayMap(
        self.definition.options,
        function(____, option) return __TS__New(ProviderSelectSettingOption, option.name, option.value) end
    )
end
return ____exports
