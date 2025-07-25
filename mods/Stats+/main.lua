local ____lualib = require("lualib_bundle")
local __TS__ObjectEntries = ____lualib.__TS__ObjectEntries
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local ____exports = {}
local ____essentials_2Daddon = require("lua_modules.@isaac-stats-plus.essentials-addon.dist.index")
local registerEssentialsAddon = ____essentials_2Daddon.registerEssentialsAddon
local json = require("json")
local ____ApplicationLifecycleManager = require("services.ApplicationLifecycleManager")
local ApplicationLifecycleManager = ____ApplicationLifecycleManager.ApplicationLifecycleManager
local ____APPLICATION_CONTAINER = require("app.APPLICATION_CONTAINER")
local APPLICATION_CONTAINER = ____APPLICATION_CONTAINER.APPLICATION_CONTAINER
local ____registerCoreAddon = require("core.registerCoreAddon")
local registerCoreAddon = ____registerCoreAddon.registerCoreAddon
local ____injectionTokenEntityMapping = require("app.ioc.injectionTokenEntityMapping")
local injectionTokenEntityMapping = ____injectionTokenEntityMapping.injectionTokenEntityMapping
local ____InjectionToken = require("app.ioc.InjectionToken")
local InjectionToken = ____InjectionToken.InjectionToken
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
do
    local function ____catch(e)
        local ____Isaac_DebugString_4 = Isaac.DebugString
        local ____opt_result_2
        if e ~= nil then
            ____opt_result_2 = e.message
        end
        local ____opt_result_2_3 = ____opt_result_2
        if ____opt_result_2_3 == nil then
            ____opt_result_2_3 = e
        end
        ____Isaac_DebugString_4(("(FATAL) [Stats+] Uncaught error: \"" .. tostring(____opt_result_2_3)) .. "\"")
        error(e, 0)
    end
    local ____try, ____hasReturned = pcall(function()
        __TS__ArrayForEach(
            __TS__ObjectEntries(injectionTokenEntityMapping),
            function(____, ____bindingPattern0)
                local resolver
                local token
                token = ____bindingPattern0[1]
                resolver = ____bindingPattern0[2]
                APPLICATION_CONTAINER:register(token, resolver)
            end
        )
        local logger = Logger["for"](Logger, "main")
        logger:debug("Registering the core addon...")
        registerCoreAddon(
            nil,
            APPLICATION_CONTAINER:resolve(InjectionToken.ModAPI)
        )
        logger:debug("Core addon registered.")
        logger:debug("Registering the essentials addon...")
        registerEssentialsAddon(
            nil,
            APPLICATION_CONTAINER:resolve(InjectionToken.ModAPI),
            json
        )
        logger:debug("Essentials addon registered.")
        logger:debug("Setting up ApplicationLifecycleManager...")
        APPLICATION_CONTAINER:resolve(ApplicationLifecycleManager):setup()
        logger:debug("ApplicationLifecycleManager ready.")
    end)
    if not ____try then
        ____catch(____hasReturned)
    end
end
return ____exports
