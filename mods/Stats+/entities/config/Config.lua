local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____essentials_2Daddon = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.index")
local D8_MULTIPLIER_PROVIDER_ID = ____essentials_2Daddon.D8_MULTIPLIER_PROVIDER_ID
local DAMAGE_MULTIPLIER_PROVIDER_ID = ____essentials_2Daddon.DAMAGE_MULTIPLIER_PROVIDER_ID
local ESSENTIALS_ADDON_ID = ____essentials_2Daddon.ESSENTIALS_ADDON_ID
local MAP_BUTTON_HELD_CONDITION_ID = ____essentials_2Daddon.MAP_BUTTON_HELD_CONDITION_ID
local ____BracketStyle = require("entities.config.appearance.BracketStyle")
local BracketStyle = ____BracketStyle.BracketStyle
local ____ConditionType = require("entities.extension.condition.ConditionType")
local ConditionType = ____ConditionType.ConditionType
local ____speed = require("core.stats.speed")
local speed = ____speed.speed
local ____tears = require("core.stats.tears")
local tears = ____tears.tears
local ____damage = require("core.stats.damage")
local damage = ____damage.damage
local ____range = require("core.stats.range")
local range = ____range.range
local ____shotSpeed = require("core.stats.shotSpeed")
local shotSpeed = ____shotSpeed.shotSpeed
local ____luck = require("core.stats.luck")
local luck = ____luck.luck
local ____coreAddonConstants = require("core.coreAddonConstants")
local ALWAYS_CONDITION_ID = ____coreAddonConstants.ALWAYS_CONDITION_ID
local CORE_ADDON_ID = ____coreAddonConstants.CORE_ADDON_ID
local NULL_PROVIDER_ID = ____coreAddonConstants.NULL_PROVIDER_ID
____exports.Config = __TS__Class()
local Config = ____exports.Config
Config.name = "Config"
function Config.prototype.____constructor(self, configVersion, appearance, loadout, providerSettings, providerState)
    self.configVersion = configVersion
    self.appearance = appearance
    self.loadout = loadout
    self.providerSettings = providerSettings
    self.providerState = providerState
end
function Config.prototype.clone(self)
    return __TS__New(
        ____exports.Config,
        self.configVersion,
        self.appearance:clone(),
        self.loadout:clone(),
        self.providerSettings:clone(),
        self.providerState:clone()
    )
end
Config.LATEST_CONFIG_VERSION = "2.0.5"
Config.DEFAULT_CONFIG = {
    configVersion = ____exports.Config.LATEST_CONFIG_VERSION,
    appearance = {
        textOpacity = 0.4,
        bracketStyle = BracketStyle.None,
        spacing = 5,
        showProviderChanges = true,
        useShaderColorFix = false
    },
    loadout = {
        {
            stat = speed:getExternalAPI(),
            primaryProvider = {addon = ESSENTIALS_ADDON_ID, id = D8_MULTIPLIER_PROVIDER_ID},
            secondaryProvider = {addon = CORE_ADDON_ID, id = NULL_PROVIDER_ID},
            condition = {type = ConditionType.Standalone, ref = {addon = ESSENTIALS_ADDON_ID, id = MAP_BUTTON_HELD_CONDITION_ID}}
        },
        {
            stat = tears:getExternalAPI(),
            primaryProvider = {addon = ESSENTIALS_ADDON_ID, id = D8_MULTIPLIER_PROVIDER_ID},
            secondaryProvider = {addon = CORE_ADDON_ID, id = NULL_PROVIDER_ID},
            condition = {type = ConditionType.Standalone, ref = {addon = ESSENTIALS_ADDON_ID, id = MAP_BUTTON_HELD_CONDITION_ID}}
        },
        {
            stat = damage:getExternalAPI(),
            primaryProvider = {addon = ESSENTIALS_ADDON_ID, id = D8_MULTIPLIER_PROVIDER_ID},
            secondaryProvider = {addon = ESSENTIALS_ADDON_ID, id = DAMAGE_MULTIPLIER_PROVIDER_ID},
            condition = {type = ConditionType.Standalone, ref = {addon = ESSENTIALS_ADDON_ID, id = MAP_BUTTON_HELD_CONDITION_ID}}
        },
        {
            stat = range:getExternalAPI(),
            primaryProvider = {addon = ESSENTIALS_ADDON_ID, id = D8_MULTIPLIER_PROVIDER_ID},
            secondaryProvider = {addon = CORE_ADDON_ID, id = NULL_PROVIDER_ID},
            condition = {type = ConditionType.Standalone, ref = {addon = ESSENTIALS_ADDON_ID, id = MAP_BUTTON_HELD_CONDITION_ID}}
        },
        {
            stat = shotSpeed:getExternalAPI(),
            primaryProvider = {addon = CORE_ADDON_ID, id = NULL_PROVIDER_ID},
            secondaryProvider = {addon = CORE_ADDON_ID, id = NULL_PROVIDER_ID},
            condition = {type = ConditionType.Standalone, ref = {addon = CORE_ADDON_ID, id = ALWAYS_CONDITION_ID}}
        },
        {
            stat = luck:getExternalAPI(),
            primaryProvider = {addon = CORE_ADDON_ID, id = NULL_PROVIDER_ID},
            secondaryProvider = {addon = CORE_ADDON_ID, id = NULL_PROVIDER_ID},
            condition = {type = ConditionType.Standalone, ref = {addon = CORE_ADDON_ID, id = ALWAYS_CONDITION_ID}}
        }
    },
    providerSettings = {settings = {}},
    providerState = {state = {}}
}
return ____exports
