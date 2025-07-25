local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__New = ____lualib.__TS__New
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____ProviderDefinition = require("entities.extension.provider.ProviderDefinition")
local ProviderDefinition = ____ProviderDefinition.ProviderDefinition
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____ProviderExtension = require("entities.extension.provider.ProviderExtension")
local ProviderExtension = ____ProviderExtension.ProviderExtension
local ____HashSet = require("structures.HashSet")
local HashSet = ____HashSet.HashSet
local ____StatExtension = require("entities.extension.stat.StatExtension")
local StatExtension = ____StatExtension.StatExtension
local ____ProviderConditionsDefinition = require("entities.extension.provider.ProviderConditionsDefinition")
local ProviderConditionsDefinition = ____ProviderConditionsDefinition.ProviderConditionsDefinition
local ____ProviderSettingsDefinition = require("entities.extension.provider.ProviderSettingsDefinition")
local ProviderSettingsDefinition = ____ProviderSettingsDefinition.ProviderSettingsDefinition
local ____ProviderStateDefinition = require("entities.extension.provider.ProviderStateDefinition")
local ProviderStateDefinition = ____ProviderStateDefinition.ProviderStateDefinition
local ____ProviderDisplaySettingsDefinition = require("entities.extension.provider.ProviderDisplaySettingsDefinition")
local ProviderDisplaySettingsDefinition = ____ProviderDisplaySettingsDefinition.ProviderDisplaySettingsDefinition
local ____ProviderComputablesDefinition = require("entities.extension.provider.ProviderComputablesDefinition")
local ProviderComputablesDefinition = ____ProviderComputablesDefinition.ProviderComputablesDefinition
local ____ProviderColor = require("entities.config.appearance.ProviderColor")
local ProviderColor = ____ProviderColor.ProviderColor
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____ModCallbackService = require("services.ModCallbackService")
local ModCallbackService = ____ModCallbackService.ModCallbackService
____exports.APIProviderMapper = __TS__Class()
local APIProviderMapper = ____exports.APIProviderMapper
APIProviderMapper.name = "APIProviderMapper"
function APIProviderMapper.prototype.____constructor(self, modCallbackService)
    self.modCallbackService = modCallbackService
end
__TS__DecorateLegacy(
    {__TS__DecorateParam(
        0,
        Inject(nil, ModCallbackService)
    )},
    APIProviderMapper
)
function APIProviderMapper.prototype.mapAPIProvider(self, addonId, apiProvider)
    local providerExtension = __TS__New(ProviderExtension, {addon = addonId, id = apiProvider.id})
    local ____ProviderDefinition_5 = ProviderDefinition
    local ____apiProvider_name_3 = apiProvider.name
    local ____apiProvider_description_4 = apiProvider.description
    local ____HashSet_2 = HashSet
    local ____opt_0 = apiProvider.targets
    return __TS__New(
        ____ProviderDefinition_5,
        {
            name = ____apiProvider_name_3,
            description = ____apiProvider_description_4,
            extension = providerExtension,
            targets = __TS__New(
                ____HashSet_2,
                ____opt_0 and __TS__ArrayMap(
                    apiProvider.targets,
                    function(____, ref) return __TS__New(StatExtension, ref) end
                )
            ),
            preferredColor = self:mapAPIProviderColor(apiProvider.color),
            conditions = __TS__New(ProviderConditionsDefinition, providerExtension, apiProvider.conditions or ({}), self.modCallbackService),
            settings = __TS__New(ProviderSettingsDefinition, apiProvider.settings or ({})),
            state = __TS__New(ProviderStateDefinition, apiProvider.state or ({})),
            display = __TS__New(ProviderDisplaySettingsDefinition, apiProvider.display),
            computables = __TS__New(ProviderComputablesDefinition, apiProvider.computables or ({})),
            mount = function(self, ctx)
                return apiProvider.mount(ctx:getExternalAPI())
            end
        }
    )
end
function APIProviderMapper.prototype.mapAPIProviderColor(self, apiProviderColor)
    if apiProviderColor == "GREY" then
        return ProviderColor.Grey
    end
    if apiProviderColor == "RED" then
        return ProviderColor.Red
    end
    if apiProviderColor == "GREEN" then
        return ProviderColor.Green
    end
    if apiProviderColor == "BLUE" then
        return ProviderColor.Blue
    end
    if apiProviderColor == "ORANGE" then
        return ProviderColor.Orange
    end
    if apiProviderColor == "MAGENTA" then
        return ProviderColor.Magenta
    end
    if apiProviderColor == "CYAN" then
        return ProviderColor.Cyan
    end
    return ProviderColor.None
end
APIProviderMapper = __TS__DecorateLegacy(
    {Singleton(nil)},
    APIProviderMapper
)
____exports.APIProviderMapper = APIProviderMapper
return ____exports
