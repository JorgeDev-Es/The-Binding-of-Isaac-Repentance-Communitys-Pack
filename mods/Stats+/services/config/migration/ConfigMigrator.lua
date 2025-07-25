local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ArrayReduce = ____lualib.__TS__ArrayReduce
local ____exports = {}
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
local ____ConfigMigrationFactory = require("services.config.migration.ConfigMigrationFactory")
local ConfigMigrationFactory = ____ConfigMigrationFactory.ConfigMigrationFactory
local ____Config = require("entities.config.Config")
local Config = ____Config.Config
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
____exports.ConfigMigrator = __TS__Class()
local ConfigMigrator = ____exports.ConfigMigrator
ConfigMigrator.name = "ConfigMigrator"
function ConfigMigrator.prototype.____constructor(self, configMigrationFactory)
    self.configMigrationFactory = configMigrationFactory
    self.logger = Logger["for"](Logger, ____exports.ConfigMigrator.name)
end
__TS__DecorateLegacy(
    {__TS__DecorateParam(
        0,
        Inject(nil, ConfigMigrationFactory)
    )},
    ConfigMigrator
)
function ConfigMigrator.prototype.getConfigWithMigrationsPerformed(self, config)
    if config == nil then
        return Config.DEFAULT_CONFIG
    end
    local migrationsToExecute = __TS__ArrayFilter(
        self.configMigrationFactory:createMigrations(),
        function(____, migration) return migration:shouldExecute(config) end
    )
    do
        local function ____catch(e)
            self.logger:warn("Config migration failed, overriding config with the default one.", e)
            return true, Config.DEFAULT_CONFIG
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            return true, __TS__ArrayReduce(
                migrationsToExecute,
                function(____, currentConfig, migration)
                    local migrationName = migration:getMigrationName()
                    local migratedConfigVersion = migration:getMigratedConfigVersion()
                    local currentConfigVersion = type(currentConfig and currentConfig.configVersion) == "string" and currentConfig.configVersion or "?"
                    self.logger:info(((((("Executing config migration \"" .. migrationName) .. "\" (") .. currentConfigVersion) .. " -> ") .. migratedConfigVersion) .. ")...")
                    local migratedConfig = migration:execute(currentConfig)
                    self.logger:info(("Migration \"" .. migrationName) .. "\" finished successfully.")
                    return migratedConfig
                end,
                config
            )
        end)
        if not ____try then
            ____hasReturned, ____returnValue = ____catch(____hasReturned)
        end
        if ____hasReturned then
            return ____returnValue
        end
    end
end
ConfigMigrator = __TS__DecorateLegacy(
    {Singleton(nil)},
    ConfigMigrator
)
____exports.ConfigMigrator = ConfigMigrator
return ____exports
