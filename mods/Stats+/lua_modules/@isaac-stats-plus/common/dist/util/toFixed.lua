local ____exports = {}
function ____exports.toFixed(self, value, digits)
    local EPSILON = 1e-8
    return value > 0 and math.floor(value * 10 ^ digits + EPSILON) / 10 ^ digits or math.ceil(value * 10 ^ digits + EPSILON) / 10 ^ digits
end
return ____exports
