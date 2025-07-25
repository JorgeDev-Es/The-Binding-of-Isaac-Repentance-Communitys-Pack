local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__TypeOf = ____lualib.__TS__TypeOf
local ____exports = {}
local ____essentials_2Daddon = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.index")
local DAMAGE_MULTIPLIER_PROVIDER_ID = ____essentials_2Daddon.DAMAGE_MULTIPLIER_PROVIDER_ID
local ESSENTIALS_ADDON_ID = ____essentials_2Daddon.ESSENTIALS_ADDON_ID
local ____BracketStyle = require("entities.config.appearance.BracketStyle")
local BracketStyle = ____BracketStyle.BracketStyle
local ____Config = require("entities.config.Config")
local Config = ____Config.Config
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
local ____ProviderColor = require("entities.config.appearance.ProviderColor")
local ProviderColor = ____ProviderColor.ProviderColor
____exports.LegacyConfigMigration = __TS__Class()
local LegacyConfigMigration = ____exports.LegacyConfigMigration
LegacyConfigMigration.name = "LegacyConfigMigration"
function LegacyConfigMigration.prototype.____constructor(self)
    self.logger = Logger["for"](Logger, ____exports.LegacyConfigMigration.name)
end
function LegacyConfigMigration.prototype.getMigrationName(self)
    return ____exports.LegacyConfigMigration.name
end
function LegacyConfigMigration.prototype.getMigratedConfigVersion(self)
    return ____exports.LegacyConfigMigration.MIGRATED_CONFIG_VERSION
end
function LegacyConfigMigration.prototype.shouldExecute(self, config)
    return (config and config.configVersion) == nil
end
function LegacyConfigMigration.prototype.execute(self, config)
    return {
        configVersion = ____exports.LegacyConfigMigration.MIGRATED_CONFIG_VERSION,
        appearance = {
            textOpacity = self:migrateTextOpacity(config and config.opacity),
            bracketStyle = self:migrateBracketStyle(config and config.brackets),
            spacing = Config.DEFAULT_CONFIG.appearance.spacing
        },
        loadout = Config.DEFAULT_CONFIG.loadout,
        providerSettings = {settings = {{ref = {addon = ESSENTIALS_ADDON_ID, id = DAMAGE_MULTIPLIER_PROVIDER_ID}, settings = {custom = {trackD8 = true}, color = ProviderColor.None}}}}
    }
end
function LegacyConfigMigration.prototype.migrateTextOpacity(self, legacyTextOpacity)
    if type(legacyTextOpacity) ~= "number" then
        self.logger:warn(
            "Expected legacy text opacity to be a number.",
            {
                legacyTextOpacity = legacyTextOpacity,
                type = __TS__TypeOf(legacyTextOpacity)
            }
        )
        return Config.DEFAULT_CONFIG.appearance.textOpacity
    end
    if 0 > legacyTextOpacity or legacyTextOpacity > 100 then
        local defaultValue = Config.DEFAULT_CONFIG.appearance.textOpacity
        self.logger:warn("Expected legacy text to be between 0 and 100, overriding with the default value.", {legacyTextOpacity = legacyTextOpacity, defaultValue = defaultValue})
        return defaultValue
    end
    return legacyTextOpacity / 100
end
function LegacyConfigMigration.prototype.migrateBracketStyle(self, legacyBracketStyle)
    if legacyBracketStyle == "Round" then
        return BracketStyle.Round
    end
    if legacyBracketStyle == "Square" then
        return BracketStyle.Square
    end
    if legacyBracketStyle == "None" then
        return BracketStyle.None
    end
    local defaultValue = Config.DEFAULT_CONFIG.appearance.bracketStyle
    self.logger:warn("Expected legacy bracket style to be either 'Round', 'Square' or 'None', overriding with the default value.", {legacyBracketStyle = legacyBracketStyle, defaultValue = defaultValue})
    return defaultValue
end
LegacyConfigMigration.MIGRATED_CONFIG_VERSION = "2.0.0"
return ____exports
