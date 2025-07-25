local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local ____exports = {}
local ____LegacyConfigMigration = require("migrations.config.LegacyConfigMigration")
local LegacyConfigMigration = ____LegacyConfigMigration.LegacyConfigMigration
local ____DisableShaderFixConfigMigration = require("migrations.config.DisableShaderFixConfigMigration")
local DisableShaderFixConfigMigration = ____DisableShaderFixConfigMigration.DisableShaderFixConfigMigration
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
____exports.ConfigMigrationFactory = __TS__Class()
local ConfigMigrationFactory = ____exports.ConfigMigrationFactory
ConfigMigrationFactory.name = "ConfigMigrationFactory"
function ConfigMigrationFactory.prototype.____constructor(self)
end
function ConfigMigrationFactory.prototype.createMigrations(self)
    return {
        __TS__New(LegacyConfigMigration),
        __TS__New(DisableShaderFixConfigMigration)
    }
end
ConfigMigrationFactory = __TS__DecorateLegacy(
    {Singleton(nil)},
    ConfigMigrationFactory
)
____exports.ConfigMigrationFactory = ConfigMigrationFactory
return ____exports
