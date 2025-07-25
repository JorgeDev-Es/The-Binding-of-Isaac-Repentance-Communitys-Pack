local ____exports = {}
do
    local ____registerEssentialsAddon = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.registerEssentialsAddon")
    local registerEssentialsAddon = ____registerEssentialsAddon.registerEssentialsAddon
    ____exports.registerEssentialsAddon = registerEssentialsAddon
end
do
    local ____essentialsAddonConstants = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.essentialsAddonConstants")
    local ESSENTIALS_ADDON_ID = ____essentialsAddonConstants.ESSENTIALS_ADDON_ID
    local DAMAGE_MULTIPLIER_PROVIDER_ID = ____essentialsAddonConstants.DAMAGE_MULTIPLIER_PROVIDER_ID
    local D8_MULTIPLIER_PROVIDER_ID = ____essentialsAddonConstants.D8_MULTIPLIER_PROVIDER_ID
    local MAP_BUTTON_HELD_CONDITION_ID = ____essentialsAddonConstants.MAP_BUTTON_HELD_CONDITION_ID
    local DROP_BUTTON_TOGGLED_CONDITION_ID = ____essentialsAddonConstants.DROP_BUTTON_TOGGLED_CONDITION_ID
    ____exports.ESSENTIALS_ADDON_ID = ESSENTIALS_ADDON_ID
    ____exports.DAMAGE_MULTIPLIER_PROVIDER_ID = DAMAGE_MULTIPLIER_PROVIDER_ID
    ____exports.D8_MULTIPLIER_PROVIDER_ID = D8_MULTIPLIER_PROVIDER_ID
    ____exports.MAP_BUTTON_HELD_CONDITION_ID = MAP_BUTTON_HELD_CONDITION_ID
    ____exports.DROP_BUTTON_TOGGLED_CONDITION_ID = DROP_BUTTON_TOGGLED_CONDITION_ID
end
return ____exports
