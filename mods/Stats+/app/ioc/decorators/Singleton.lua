local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____singleton = require("app.ioc.resolution.singleton")
local singleton = ____singleton.singleton
local ____APPLICATION_CONTAINER = require("app.APPLICATION_CONTAINER")
local APPLICATION_CONTAINER = ____APPLICATION_CONTAINER.APPLICATION_CONTAINER
function ____exports.Singleton(self)
    return function(____, target)
        APPLICATION_CONTAINER:register(
            target,
            singleton(
                nil,
                function(____, container, ...) return __TS__New(target, ...) end
            )
        )
    end
end
return ____exports
