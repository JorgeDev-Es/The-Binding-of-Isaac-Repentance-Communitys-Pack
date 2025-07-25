local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.ProviderSelectSettingOption = __TS__Class()
local ProviderSelectSettingOption = ____exports.ProviderSelectSettingOption
ProviderSelectSettingOption.name = "ProviderSelectSettingOption"
function ProviderSelectSettingOption.prototype.____constructor(self, name, value)
    self.name = name
    self.value = value
end
function ProviderSelectSettingOption.prototype.getName(self)
    return self.name
end
function ProviderSelectSettingOption.prototype.getValue(self)
    return self.value
end
return ____exports
