local ____exports = {}
local ____essentialsAddonConstants = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.essentialsAddonConstants")
local ESSENTIALS_ADDON_ID = ____essentialsAddonConstants.ESSENTIALS_ADDON_ID
local ____createDamageMultiplierProvider = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.providers.damageMultiplierProvider.createDamageMultiplierProvider")
local createDamageMultiplierProvider = ____createDamageMultiplierProvider.createDamageMultiplierProvider
local ____createD8MultiplierProvider = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.providers.d8MultiplierProvider.createD8MultiplierProvider")
local createD8MultiplierProvider = ____createD8MultiplierProvider.createD8MultiplierProvider
local ____createMapButtonHeldCondition = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.conditions.createMapButtonHeldCondition")
local createMapButtonHeldCondition = ____createMapButtonHeldCondition.createMapButtonHeldCondition
local ____createToggledViaDropButtonCondition = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.conditions.createToggledViaDropButtonCondition")
local createToggledViaDropButtonCondition = ____createToggledViaDropButtonCondition.createToggledViaDropButtonCondition
function ____exports.registerEssentialsAddon(self, mod, json)
    mod:AddCallback(
        "STATS_PLUS_REGISTER",
        function(____, api)
            api:register({
                id = ESSENTIALS_ADDON_ID,
                name = "Stats+ Essentials",
                providers = {
                    createDamageMultiplierProvider(nil, api, mod, json),
                    createD8MultiplierProvider(nil, api, mod, json)
                },
                conditions = {
                    createMapButtonHeldCondition(nil, api, mod),
                    createToggledViaDropButtonCondition(nil, api, mod)
                }
            })
        end
    )
end
return ____exports
