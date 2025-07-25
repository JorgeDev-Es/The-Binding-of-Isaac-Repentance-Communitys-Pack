local ____lualib = require("lualib_bundle")
local __TS__ParseInt = ____lualib.__TS__ParseInt
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ArrayEvery = ____lualib.__TS__ArrayEvery
local __TS__ArraySome = ____lualib.__TS__ArraySome
local ____exports = {}
function ____exports.isVersionGreaterThan(self, version, than)
    local firstSegments = __TS__ArrayMap(
        __TS__StringSplit(version, "."),
        function(____, segment) return __TS__ParseInt(segment, 10) end
    )
    local secondSegments = __TS__ArrayMap(
        __TS__StringSplit(than, "."),
        function(____, segment) return __TS__ParseInt(segment, 10) end
    )
    return __TS__ArrayEvery(
        firstSegments,
        function(____, segment, idx) return segment >= (secondSegments[idx + 1] or 0) end
    ) and __TS__ArraySome(
        firstSegments,
        function(____, segment, idx) return segment > (secondSegments[idx + 1] or 0) end
    )
end
return ____exports
