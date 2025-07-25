local ____lualib = require("lualib_bundle")
local Set = ____lualib.Set
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__New = ____lualib.__TS__New
local __TS__ArrayEvery = ____lualib.__TS__ArrayEvery
local ____exports = {}
function ____exports.isValidId(self, id)
    local ALLOWED_CHARACTERS = __TS__New(
        Set,
        __TS__StringSplit("abcdefghijklmnopqrstuvwxyz0123456789-", "")
    )
    if #id == 0 then
        return false
    end
    return __TS__ArrayEvery(
        __TS__StringSplit(id, ""),
        function(____, character) return ALLOWED_CHARACTERS:has(character) end
    )
end
return ____exports
