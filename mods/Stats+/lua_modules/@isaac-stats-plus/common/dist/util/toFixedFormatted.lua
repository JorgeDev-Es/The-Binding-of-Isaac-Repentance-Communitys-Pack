local ____lualib = require("lualib_bundle")
local __TS__StringIncludes = ____lualib.__TS__StringIncludes
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__StringPadEnd = ____lualib.__TS__StringPadEnd
local ____exports = {}
local ____toFixed = require("lua_modules.@isaac-stats-plus.common.dist.util.toFixed")
local toFixed = ____toFixed.toFixed
function ____exports.toFixedFormatted(self, value, digits)
    local str = tostring(toFixed(nil, value, digits))
    local hasFractionalPart = __TS__StringIncludes(str, ".")
    local missingZeroes = hasFractionalPart and digits - #__TS__StringSplit(str, ".")[2] or digits
    if missingZeroes == 0 then
        return str
    end
    return hasFractionalPart and __TS__StringPadEnd(str, #str + missingZeroes, "0") or __TS__StringPadEnd(str .. ".", #str + missingZeroes + 1, "0")
end
return ____exports
