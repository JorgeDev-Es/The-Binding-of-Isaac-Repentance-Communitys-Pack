local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____Time = require("entities.Time")
local Time = ____Time.Time
____exports.MetricChange = __TS__Class()
local MetricChange = ____exports.MetricChange
MetricChange.name = "MetricChange"
function MetricChange.prototype.____constructor(self, value, formattedValue, isPositive, lastUpdate)
    self.value = value
    self.formattedValue = formattedValue
    self.isPositive = isPositive
    self.lastUpdate = lastUpdate
end
function MetricChange.empty(self, currentTime)
    return __TS__New(
        ____exports.MetricChange,
        nil,
        nil,
        false,
        currentTime:minus(____exports.MetricChange.ANIMATION_DURATION)
    )
end
function MetricChange.prototype.isAccumulating(self, time)
    if self.value == nil then
        return false
    end
    return ____exports.MetricChange.ACCUMULATION_DURATION:getTicks() > time:getTicks() - self.lastUpdate:getTicks()
end
MetricChange.ANIMATION_DURATION = Time:ms(4000)
MetricChange.ACCUMULATION_DURATION = Time:ticks(120)
return ____exports
