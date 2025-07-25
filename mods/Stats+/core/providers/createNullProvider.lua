local ____exports = {}
local ____coreAddonConstants = require("core.coreAddonConstants")
local NULL_PROVIDER_ID = ____coreAddonConstants.NULL_PROVIDER_ID
function ____exports.createNullProvider(self, statsPlus)
    return statsPlus:provider({
        id = NULL_PROVIDER_ID,
        name = "None",
        description = "Displays no value.",
        display = {
            value = {
                get = function() return nil end,
                format = function() return nil end
            },
            change = {
                compute = function() return nil end,
                format = function() return nil end
            }
        },
        mount = function() return nil end
    })
end
return ____exports
