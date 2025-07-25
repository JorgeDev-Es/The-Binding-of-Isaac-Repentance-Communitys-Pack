local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
local ____MetricChange = require("entities.metric.MetricChange")
local MetricChange = ____MetricChange.MetricChange
local ____Time = require("entities.Time")
local Time = ____Time.Time
____exports.MetricValue = __TS__Class()
local MetricValue = ____exports.MetricValue
MetricValue.name = "MetricValue"
function MetricValue.prototype.____constructor(self, options)
    self.options = options
    self.baseValue = self.options.initial
    self.value = self.options.initial
    self.formattedValue = self.options:formatValue(self:getValue())
    self.change = MetricChange:empty(Time:never())
    self.changeStartTime = Time:never()
end
function MetricValue.prototype.getValue(self)
    return self.value
end
function MetricValue.prototype.getChangeAt(self, time)
    if self:getChange():isAccumulating(time) then
        return self:getChange()
    end
    return nil
end
function MetricValue.prototype.getChange(self)
    return self.change
end
function MetricValue.prototype.getChangeStartTime(self)
    return self.changeStartTime
end
function MetricValue.prototype.getFormattedValue(self)
    return self.formattedValue
end
function MetricValue.prototype.setValue(self, value, currentTime, silent)
    if silent == nil then
        silent = false
    end
    local formattedValue = self.options:formatValue(value)
    if self.formattedValue == formattedValue then
        return
    end
    self.formattedValue = formattedValue
    if not self.change:isAccumulating(currentTime) then
        self.baseValue = self.value
        self.changeStartTime = currentTime
    end
    if not silent then
        self.change = self.options:computeChange(self.baseValue, value)
    end
    self.value = value
    if not self.change:isAccumulating(currentTime) then
        self.baseValue = value
    end
end
return ____exports
