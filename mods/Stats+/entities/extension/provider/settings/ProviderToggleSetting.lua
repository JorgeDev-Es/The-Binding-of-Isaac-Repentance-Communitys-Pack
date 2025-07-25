local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.ProviderToggleSetting = __TS__Class()
local ProviderToggleSetting = ____exports.ProviderToggleSetting
ProviderToggleSetting.name = "ProviderToggleSetting"
function ProviderToggleSetting.prototype.____constructor(self, key, definition)
    self.key = key
    self.definition = definition
end
function ProviderToggleSetting.prototype.getKey(self)
    return self.key
end
function ProviderToggleSetting.prototype.getName(self)
    return self.definition.name
end
function ProviderToggleSetting.prototype.getDescription(self)
    return self.definition.description
end
function ProviderToggleSetting.prototype.getInitialValue(self)
    return self.definition.initial()
end
return ____exports
