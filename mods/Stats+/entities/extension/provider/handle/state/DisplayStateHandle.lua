local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____MetricValue = require("entities.metric.MetricValue")
local MetricValue = ____MetricValue.MetricValue
local ____StateHandle = require("entities.extension.provider.handle.state.StateHandle")
local StateHandle = ____StateHandle.StateHandle
____exports.DisplayStateHandle = __TS__Class()
local DisplayStateHandle = ____exports.DisplayStateHandle
DisplayStateHandle.name = "DisplayStateHandle"
function DisplayStateHandle.prototype.____constructor(self, timeProvider, key, definition, provider, stateEncoder, configService)
    self.timeProvider = timeProvider
    self.key = key
    self.definition = definition
    self.provider = provider
    self.stateEncoder = stateEncoder
    self.configService = configService
    self.stateHandle = __TS__New(
        StateHandle,
        self.provider:getExtension(),
        self.definition,
        self.key,
        self.stateEncoder,
        self.configService
    )
    self.metricValue = __TS__New(
        MetricValue,
        {
            initial = self.stateHandle:getExternalAPI():current(),
            formatValue = function(____, value) return self.provider:getDisplaySettings():formatValue(value) end,
            formatChange = function(____, value) return self.provider:getDisplaySettings():formatChange(value) end,
            computeChange = function(____, prev, next) return self.provider:getDisplaySettings():computeChange(
                prev,
                next,
                self.timeProvider:getLastRenderTime()
            ) end
        }
    )
end
function DisplayStateHandle.prototype.getKey(self)
    return self.key
end
function DisplayStateHandle.prototype.getExternalAPI(self)
    return {
        current = function() return self.stateHandle:getExternalAPI():current() end,
        reset = function(____, silent) return self:setValue(
            self.definition.initial(),
            silent
        ) end,
        set = function(____, value, silent) return self:setValue(value, silent) end
    }
end
function DisplayStateHandle.prototype.getMetricValue(self)
    return self.metricValue
end
function DisplayStateHandle.prototype.setValue(self, value, silent)
    self.metricValue:setValue(
        value,
        self.timeProvider:getLastRenderTime(),
        silent
    )
    self.stateHandle:getExternalAPI():set(value)
end
return ____exports
