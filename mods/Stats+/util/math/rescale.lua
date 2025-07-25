local ____exports = {}
function ____exports.rescale(self, value, ____bindingPattern0, ____bindingPattern1)
    local inMax
    local inMin
    inMin = ____bindingPattern0[1]
    inMax = ____bindingPattern0[2]
    local outMax
    local outMin
    outMin = ____bindingPattern1[1]
    outMax = ____bindingPattern1[2]
    return outMin + (outMax - outMin) / (inMax - inMin) * (value - inMin)
end
return ____exports
