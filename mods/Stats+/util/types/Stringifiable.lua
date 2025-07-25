local ____exports = {}
function ____exports.isStringifiable(self, value)
    if value == nil then
        return false
    end
    if type(value) == "table" or type(value) == "function" then
        return type(value.toString) == "function"
    end
    return true
end
return ____exports
