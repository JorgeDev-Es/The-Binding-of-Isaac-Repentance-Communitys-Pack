local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____ResolvedComputables = require("entities.extension.provider.handle.ResolvedComputables")
local ResolvedComputables = ____ResolvedComputables.ResolvedComputables
local ____ExtensionService = require("services.extension.ExtensionService")
local ExtensionService = ____ExtensionService.ExtensionService
local ____ComputableExtension = require("entities.extension.provider.computable.ComputableExtension")
local ComputableExtension = ____ComputableExtension.ComputableExtension
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____Logger = require("Logger")
local Logger = ____Logger.Logger
____exports.ComputablesResolver = __TS__Class()
local ComputablesResolver = ____exports.ComputablesResolver
ComputablesResolver.name = "ComputablesResolver"
function ComputablesResolver.prototype.____constructor(self, extensionService)
    self.extensionService = extensionService
    self.logger = Logger["for"](Logger, ____exports.ComputablesResolver.name)
end
__TS__DecorateLegacy(
    {__TS__DecorateParam(
        0,
        Inject(nil, ExtensionService)
    )},
    ComputablesResolver
)
function ComputablesResolver.prototype.resolveComputables(self, provider)
    local resolvedComputables = {}
    __TS__ArrayForEach(
        provider:getComputables():getComputables(),
        function(____, computableDefinition)
            local function getInitialValue(____, args)
                return computableDefinition:compute(resolvedComputables, args)
            end
            resolvedComputables[computableDefinition:getName()] = self:resolveComputable(
                provider:getExtension(),
                getInitialValue,
                computableDefinition:getName()
            )
        end
    )
    return __TS__New(ResolvedComputables, resolvedComputables)
end
function ComputablesResolver.prototype.resolveComputable(self, providerExtension, getInitialValue, computableName)
    local computable = self.extensionService:getComputable(__TS__New(ComputableExtension, providerExtension, computableName))
    return function(____, ...)
        local args = {...}
        do
            local function ____catch(e)
                self.logger:error("Error while executing a computable", e, {addonId = providerExtension.addonId, providerId = providerExtension.providerId, computableName = computableName})
                error(e, 0)
            end
            local ____try, ____hasReturned, ____returnValue = pcall(function()
                return true, computable:compute(
                    args,
                    getInitialValue(nil, args)
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
end
ComputablesResolver = __TS__DecorateLegacy(
    {Singleton(nil)},
    ComputablesResolver
)
____exports.ComputablesResolver = ComputablesResolver
return ____exports
