local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____MetricChange = require("entities.metric.MetricChange")
local MetricChange = ____MetricChange.MetricChange
____exports.ProviderDisplaySettingsDefinition = __TS__Class()
local ProviderDisplaySettingsDefinition = ____exports.ProviderDisplaySettingsDefinition
ProviderDisplaySettingsDefinition.name = "ProviderDisplaySettingsDefinition"
function ProviderDisplaySettingsDefinition.prototype.____constructor(self, settings)
    self.settings = settings
end
function ProviderDisplaySettingsDefinition.prototype.getDisplayState(self, state)
    return self.settings.value.get(state:getExternalAPI())
end
function ProviderDisplaySettingsDefinition.prototype.formatValue(self, value)
    return self.settings.value.format(value)
end
function ProviderDisplaySettingsDefinition.prototype.formatChange(self, change)
    local ____opt_0 = self.settings.change
    return ____opt_0 and ____opt_0.format(
        change,
        self:isChangePositive(change)
    )
end
function ProviderDisplaySettingsDefinition.prototype.isChangePositive(self, value)
    local ____opt_4 = self.settings.change
    local ____opt_2 = ____opt_4 and ____opt_4.isPositive
    local ____temp_6 = ____opt_2 and ____opt_2(value)
    if ____temp_6 == nil then
        ____temp_6 = true
    end
    return ____temp_6
end
function ProviderDisplaySettingsDefinition.prototype.computeChange(self, prev, next, currentRenderTime)
    local ____opt_7 = self.settings.change
    local value = ____opt_7 and ____opt_7.compute(prev, next)
    if value == nil then
        return MetricChange:empty(currentRenderTime)
    end
    local ____opt_11 = self.settings.change
    local ____opt_9 = ____opt_11 and ____opt_11.isPositive
    local ____temp_13 = ____opt_9 and ____opt_9(value)
    if ____temp_13 == nil then
        ____temp_13 = false
    end
    local isPositive = ____temp_13
    local ____opt_14 = self.settings.change
    local formattedValue = ____opt_14 and ____opt_14.format(value, isPositive)
    return __TS__New(
        MetricChange,
        value,
        formattedValue,
        isPositive,
        currentRenderTime
    )
end
return ____exports
