local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.ProviderRangeSetting = __TS__Class()
local ProviderRangeSetting = ____exports.ProviderRangeSetting
ProviderRangeSetting.name = "ProviderRangeSetting"
function ProviderRangeSetting.prototype.____constructor(self, key, definition)
    self.key = key
    self.definition = definition
end
function ProviderRangeSetting.prototype.getKey(self)
    return self.key
end
function ProviderRangeSetting.prototype.getName(self)
    return self.definition.name
end
function ProviderRangeSetting.prototype.getDescription(self)
    return self.definition.description
end
function ProviderRangeSetting.prototype.getMinValue(self)
    return self.definition.min
end
function ProviderRangeSetting.prototype.getMaxValue(self)
    return self.definition.max
end
function ProviderRangeSetting.prototype.getInitialValue(self)
    return self.definition.initial()
end
return ____exports
