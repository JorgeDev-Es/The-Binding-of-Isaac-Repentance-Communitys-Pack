local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____ConfigDTOValidator = require("validators.dto.config.ConfigDTOValidator")
local ConfigDTOValidator = ____ConfigDTOValidator.ConfigDTOValidator
local ____ConfigMigrator = require("services.config.migration.ConfigMigrator")
local ConfigMigrator = ____ConfigMigrator.ConfigMigrator
local ____ConfigMapper = require("mappers.config.ConfigMapper")
local ConfigMapper = ____ConfigMapper.ConfigMapper
local ____Config = require("entities.config.Config")
local Config = ____Config.Config
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
local ____InjectionToken = require("app.ioc.InjectionToken")
local InjectionToken = ____InjectionToken.InjectionToken
____exports.ConfigRepository = __TS__Class()
local ConfigRepository = ____exports.ConfigRepository
ConfigRepository.name = "ConfigRepository"
function ConfigRepository.prototype.____constructor(self, mod, jsonSerializer, configDTOValidator, configMigrator, configMapper)
    self.mod = mod
    self.jsonSerializer = jsonSerializer
    self.configDTOValidator = configDTOValidator
    self.configMigrator = configMigrator
    self.configMapper = configMapper
    self.logger = Logger["for"](Logger, ____exports.ConfigRepository.name)
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, InjectionToken.ModAPI)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, InjectionToken.JsonSerializer)
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, ConfigDTOValidator)
        ),
        __TS__DecorateParam(
            3,
            Inject(nil, ConfigMigrator)
        ),
        __TS__DecorateParam(
            4,
            Inject(nil, ConfigMapper)
        )
    },
    ConfigRepository
)
function ConfigRepository.prototype.get(self)
    if self.config == nil then
        error(
            __TS__New(Error, "ConfigRepository has not been initialized."),
            0
        )
    end
    return self.config
end
function ConfigRepository.prototype.reload(self)
    self.config = self:load()
    self:save(self.config)
end
function ConfigRepository.prototype.save(self, config)
    do
        local function ____catch(e)
            self.logger:error("Failed to save the given config.", e)
            error(e, 0)
        end
        local ____try, ____hasReturned = pcall(function()
            local configDTO = self.configMapper:toDTO(config)
            local jsonEncoded = self.jsonSerializer:encode(configDTO)
            self.config = config:clone()
            self.mod:SaveData(jsonEncoded)
            self.logger:debug("Successfully saved the given config.")
        end)
        if not ____try then
            ____catch(____hasReturned)
        end
    end
end
function ConfigRepository.prototype.load(self)
    if not self.mod:HasData() then
        self.logger:info("No data stored, returning default config.")
        return self.configMapper:toConfig(Config.DEFAULT_CONFIG)
    end
    do
        local function ____catch(e)
            self.logger:error("Failed to load stored config, returning default config instead.", e)
            return true, self.configMapper:toConfig(Config.DEFAULT_CONFIG)
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            local rawDTO = self.jsonSerializer:decode(self.mod:LoadData())
            local migratedDTO = self.configMigrator:getConfigWithMigrationsPerformed(rawDTO)
            local configDTO = self.configDTOValidator:getValidConfigDTO(migratedDTO)
            local config = self.configMapper:toConfig(configDTO)
            self.logger:info("Successfully loaded stored config.")
            return true, config
        end)
        if not ____try then
            ____hasReturned, ____returnValue = ____catch(____hasReturned)
        end
        if ____hasReturned then
            return ____returnValue
        end
    end
end
ConfigRepository = __TS__DecorateLegacy(
    {Singleton(nil)},
    ConfigRepository
)
____exports.ConfigRepository = ConfigRepository
return ____exports
