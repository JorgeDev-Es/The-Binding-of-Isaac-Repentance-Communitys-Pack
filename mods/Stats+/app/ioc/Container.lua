local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
____exports.Container = __TS__Class()
local Container = ____exports.Container
Container.name = "Container"
function Container.prototype.____constructor(self)
    self.resolvers = __TS__New(Map)
    self.args = __TS__New(Map)
end
function Container.prototype.register(self, identifier, resolver)
    self.resolvers:set(identifier, resolver)
end
function Container.prototype.registerArg(self, target, identifier, index)
    if not self.args:has(target) then
        self.args:set(target, {})
    end
    local args = self.args:get(target)
    args[index + 1] = identifier
end
function Container.prototype.resolve(self, identifier)
    local resolver = self.resolvers:get(identifier)
    if resolver == nil then
        error(
            __TS__New(ErrorWithContext, "No resolver found for the given dependency.", {identifier = identifier}),
            0
        )
    end
    local args = self:getArgs(identifier)
    return resolver(
        nil,
        self,
        table.unpack(args)
    )
end
function Container.prototype.getArgs(self, identifier)
    local argIdentifiers = self.args:get(identifier) or ({})
    return __TS__ArrayMap(
        argIdentifiers,
        function(____, argIdentifier) return self:resolve(argIdentifier) end
    )
end
return ____exports
