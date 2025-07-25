local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.Interpolation = __TS__Class()
local Interpolation = ____exports.Interpolation
Interpolation.name = "Interpolation"
function Interpolation.prototype.____constructor(self, value, startTime, finishTime)
    self.value = value
    self.startTime = startTime
    self.finishTime = finishTime
end
function Interpolation.prototype.getValue(self)
    return self.value
end
function Interpolation.prototype.getStartTime(self)
    return self.startTime
end
function Interpolation.prototype.getFinishTime(self)
    return self.finishTime
end
Interpolation.easeOut = function(____, progress) return 1 - (1 - progress) ^ 3 end
Interpolation.linear = function(____, progress) return progress end
return ____exports
