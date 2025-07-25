local ____exports = {}
local ____coreAddonConstants = require("core.coreAddonConstants")
local ALWAYS_CONDITION_ID = ____coreAddonConstants.ALWAYS_CONDITION_ID
function ____exports.createAlwaysCondition(self, statsPlus)
    return statsPlus:condition({
        id = ALWAYS_CONDITION_ID,
        name = "Always",
        description = "Always active.",
        mount = function(ctx)
            ctx:setActive(true)
        end
    })
end
return ____exports
