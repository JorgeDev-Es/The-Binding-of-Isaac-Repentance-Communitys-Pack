local ____exports = {}
local ____APPLICATION_CONTAINER = require("app.APPLICATION_CONTAINER")
local APPLICATION_CONTAINER = ____APPLICATION_CONTAINER.APPLICATION_CONTAINER
function ____exports.Inject(self, identifier)
    return function(____, target, propertyKey, parameterIndex)
        APPLICATION_CONTAINER:registerArg(target, identifier, parameterIndex)
        return nil
    end
end
return ____exports
