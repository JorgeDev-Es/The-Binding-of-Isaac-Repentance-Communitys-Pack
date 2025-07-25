local ____exports = {}
function ____exports.constrain(self, value, ____bindingPattern0)
    local max
    local min
    min = ____bindingPattern0[1]
    max = ____bindingPattern0[2]
    return math.min(
        max,
        math.max(min, value)
    )
end
return ____exports
