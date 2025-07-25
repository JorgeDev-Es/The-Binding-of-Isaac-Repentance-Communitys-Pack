local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____ProviderInstanceHandle = require("entities.extension.provider.handle.ProviderInstanceHandle")
local ProviderInstanceHandle = ____ProviderInstanceHandle.ProviderInstanceHandle
____exports.ProviderDefinition = __TS__Class()
local ProviderDefinition = ____exports.ProviderDefinition
ProviderDefinition.name = "ProviderDefinition"
function ProviderDefinition.prototype.____constructor(self, options)
    self.options = options
end
function ProviderDefinition.prototype.getName(self)
    return self.options.name
end
function ProviderDefinition.prototype.getDescription(self)
    return self.options.description
end
function ProviderDefinition.prototype.getPreferredColor(self)
    return self.options.preferredColor
end
function ProviderDefinition.prototype.getExtension(self)
    return self.options.extension
end
function ProviderDefinition.prototype.getComputables(self)
    return self.options.computables
end
function ProviderDefinition.prototype.getCompanionConditions(self)
    return self.options.conditions
end
function ProviderDefinition.prototype.isStatSupported(self, stat)
    if self.options.targets.size == 0 then
        return true
    end
    return self.options.targets:has(stat)
end
function ProviderDefinition.prototype.getSettings(self)
    return self.options.settings
end
function ProviderDefinition.prototype.getState(self)
    return self.options.state
end
function ProviderDefinition.prototype.getDisplaySettings(self)
    return self.options.display
end
function ProviderDefinition.prototype.mount(self, context)
    return __TS__New(
        ProviderInstanceHandle,
        self,
        context,
        self.options:mount(context)
    )
end
return ____exports
