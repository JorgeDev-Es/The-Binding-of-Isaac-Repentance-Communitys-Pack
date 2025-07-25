local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ArrayToSorted = ____lualib.__TS__ArrayToSorted
local ____exports = {}
____exports.Time = __TS__Class()
local Time = ____exports.Time
Time.name = "Time"
function Time.prototype.____constructor(self, ticks)
    self.ticks = ticks
end
function Time.ms(self, ms)
    return ____exports.Time:ticks(ms / 1000 * ____exports.Time.GAME_FRAMERATE)
end
function Time.ticks(self, ticks)
    return __TS__New(____exports.Time, ticks)
end
function Time.fromNullable(self, time)
    return time or ____exports.Time:never()
end
function Time.never(self)
    return __TS__New(____exports.Time, -math.huge)
end
function Time.max(self, ...)
    local entries = {...}
    local sorted = __TS__ArrayToSorted(
        entries,
        function(____, a, b) return ____exports.Time:fromNullable(b):getTicks() - ____exports.Time:fromNullable(a):getTicks() end
    )
    return sorted[1] or ____exports.Time:never()
end
function Time.prototype.getTicks(self)
    return self.ticks
end
function Time.prototype.plus(self, that)
    return ____exports.Time:ticks(self:getTicks() + that:getTicks())
end
function Time.prototype.minus(self, that)
    return ____exports.Time:ticks(self:getTicks() - that:getTicks())
end
Time.GAME_FRAMERATE = 30
return ____exports
