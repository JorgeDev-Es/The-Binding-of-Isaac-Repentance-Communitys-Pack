local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local ____exports = {}
local ____ProviderColor = require("entities.config.appearance.ProviderColor")
local ProviderColor = ____ProviderColor.ProviderColor
____exports.ResolvedSettings = __TS__Class()
local ResolvedSettings = ____exports.ResolvedSettings
ResolvedSettings.name = "ResolvedSettings"
function ResolvedSettings.prototype.____constructor(self, options)
    self.options = options
end
function ResolvedSettings.prototype.getProviderColor(self)
    return self.options.color
end
function ResolvedSettings.prototype.getExternalAPI(self)
    return __TS__ObjectAssign(
        {},
        self.options,
        {color = self:getAPIProviderColor(self:getProviderColor())}
    )
end
function ResolvedSettings.prototype.getAPIProviderColor(self, color)
    if color == ProviderColor.Grey then
        return "GREY"
    end
    if color == ProviderColor.Red then
        return "RED"
    end
    if color == ProviderColor.Green then
        return "GREEN"
    end
    if color == ProviderColor.Blue then
        return "BLUE"
    end
    if color == ProviderColor.Orange then
        return "ORANGE"
    end
    if color == ProviderColor.Magenta then
        return "MAGENTA"
    end
    if color == ProviderColor.Cyan then
        return "CYAN"
    end
    return "NONE"
end
return ____exports
