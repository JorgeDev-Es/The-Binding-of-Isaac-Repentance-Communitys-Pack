local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local ____exports = {}
local ____ProviderColor = require("entities.config.appearance.ProviderColor")
local ProviderColor = ____ProviderColor.ProviderColor
____exports.ProviderSettings = __TS__Class()
local ProviderSettings = ____exports.ProviderSettings
ProviderSettings.name = "ProviderSettings"
function ProviderSettings.prototype.____constructor(self, customSettings, color)
    self.customSettings = customSettings
    self.color = color
end
function ProviderSettings.empty(self, color)
    if color == nil then
        color = ProviderColor.None
    end
    return __TS__New(____exports.ProviderSettings, {}, color)
end
function ProviderSettings.prototype.getAllCustomSettings(self)
    return __TS__ObjectAssign({}, self.customSettings)
end
function ProviderSettings.prototype.getCustomSettingRawValue(self, key)
    return self.customSettings[key]
end
function ProviderSettings.prototype.setCustomSettingRawValue(self, key, value)
    self.customSettings[key] = value
end
function ProviderSettings.prototype.getColor(self)
    return self.color
end
function ProviderSettings.prototype.setColor(self, color)
    self.color = color
end
return ____exports
