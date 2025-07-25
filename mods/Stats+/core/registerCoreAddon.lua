local ____exports = {}
local ____coreAddonConstants = require("core.coreAddonConstants")
local CORE_ADDON_ID = ____coreAddonConstants.CORE_ADDON_ID
local ____createNullProvider = require("core.providers.createNullProvider")
local createNullProvider = ____createNullProvider.createNullProvider
local ____createAlwaysCondition = require("core.conditions.createAlwaysCondition")
local createAlwaysCondition = ____createAlwaysCondition.createAlwaysCondition
function ____exports.registerCoreAddon(self, mod)
    mod:AddCallback(
        "STATS_PLUS_REGISTER",
        function(____, statsPlus)
            statsPlus:register({
                id = CORE_ADDON_ID,
                name = "Stats+ Core",
                providers = {createNullProvider(nil, statsPlus)},
                conditions = {createAlwaysCondition(nil, statsPlus)}
            })
        end
    )
end
return ____exports
