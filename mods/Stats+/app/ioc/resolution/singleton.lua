local ____exports = {}
function ____exports.singleton(self, factory)
    local instance
    return function(____, container, ...)
        if instance == nil then
            instance = factory(nil, container, ...)
        end
        return instance
    end
end
return ____exports
