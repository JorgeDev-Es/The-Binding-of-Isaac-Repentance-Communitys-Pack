local ____exports = {}
function ____exports.transient(self, factory)
    return function(____, container, ...) return factory(nil, container, ...) end
end
return ____exports
