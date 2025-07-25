local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local ____exports = {}
local ____isVersionGreaterThan = require("util.isVersionGreaterThan")
local isVersionGreaterThan = ____isVersionGreaterThan.isVersionGreaterThan
____exports.DisableShaderFixConfigMigration = __TS__Class()
local DisableShaderFixConfigMigration = ____exports.DisableShaderFixConfigMigration
DisableShaderFixConfigMigration.name = "DisableShaderFixConfigMigration"
function DisableShaderFixConfigMigration.prototype.____constructor(self)
end
function DisableShaderFixConfigMigration.prototype.getMigrationName(self)
    return ____exports.DisableShaderFixConfigMigration.name
end
function DisableShaderFixConfigMigration.prototype.getMigratedConfigVersion(self)
    return ____exports.DisableShaderFixConfigMigration.MIGRATED_CONFIG_VERSION
end
function DisableShaderFixConfigMigration.prototype.shouldExecute(self, config)
    if type(config and config.configVersion) ~= "string" then
        return false
    end
    return isVersionGreaterThan(nil, ____exports.DisableShaderFixConfigMigration.MIGRATED_CONFIG_VERSION, config.configVersion)
end
function DisableShaderFixConfigMigration.prototype.execute(self, config)
    local ____config_5 = config
    local ____exports_DisableShaderFixConfigMigration_MIGRATED_CONFIG_VERSION_6 = ____exports.DisableShaderFixConfigMigration.MIGRATED_CONFIG_VERSION
    local ____temp_4 = config and config.appearance
    if ____temp_4 == nil then
        ____temp_4 = {}
    end
    return __TS__ObjectAssign(
        {},
        ____config_5,
        {
            configVersion = ____exports_DisableShaderFixConfigMigration_MIGRATED_CONFIG_VERSION_6,
            appearance = __TS__ObjectAssign({}, ____temp_4, {useShaderColorFix = false})
        }
    )
end
DisableShaderFixConfigMigration.MIGRATED_CONFIG_VERSION = "2.0.5"
return ____exports
