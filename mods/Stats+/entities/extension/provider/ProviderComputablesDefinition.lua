local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ObjectEntries = ____lualib.__TS__ObjectEntries
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____ComputableDefinition = require("entities.extension.provider.computable.ComputableDefinition")
local ComputableDefinition = ____ComputableDefinition.ComputableDefinition
____exports.ProviderComputablesDefinition = __TS__Class()
local ProviderComputablesDefinition = ____exports.ProviderComputablesDefinition
ProviderComputablesDefinition.name = "ProviderComputablesDefinition"
function ProviderComputablesDefinition.prototype.____constructor(self, computables)
    self.computables = computables
end
function ProviderComputablesDefinition.prototype.getComputables(self)
    return __TS__ArrayMap(
        __TS__ObjectEntries(self.computables),
        function(____, ____bindingPattern0)
            local definition
            local name
            name = ____bindingPattern0[1]
            definition = ____bindingPattern0[2]
            return __TS__New(ComputableDefinition, name, definition)
        end
    )
end
return ____exports
