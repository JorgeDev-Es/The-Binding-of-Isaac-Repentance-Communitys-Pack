local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__DecorateParam = ____lualib.__TS__DecorateParam
local __TS__DecorateLegacy = ____lualib.__TS__DecorateLegacy
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local ____exports = {}
local ____ProviderState = require("entities.extension.provider.handle.state.ProviderState")
local ProviderState = ____ProviderState.ProviderState
local ____ConfigService = require("services.config.ConfigService")
local ConfigService = ____ConfigService.ConfigService
local ____Inject = require("app.ioc.decorators.Inject")
local Inject = ____Inject.Inject
local ____Singleton = require("app.ioc.decorators.Singleton")
local Singleton = ____Singleton.Singleton
local ____DisplayStateHandle = require("entities.extension.provider.handle.state.DisplayStateHandle")
local DisplayStateHandle = ____DisplayStateHandle.DisplayStateHandle
local ____TimeProvider = require("services.renderer.TimeProvider")
local TimeProvider = ____TimeProvider.TimeProvider
local ____StateEncoder = require("entities.extension.provider.handle.state.StateEncoder")
local StateEncoder = ____StateEncoder.StateEncoder
local ____StateHandle = require("entities.extension.provider.handle.state.StateHandle")
local StateHandle = ____StateHandle.StateHandle
local ____InjectionToken = require("app.ioc.InjectionToken")
local InjectionToken = ____InjectionToken.InjectionToken
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
____exports.StateResolver = __TS__Class()
local StateResolver = ____exports.StateResolver
StateResolver.name = "StateResolver"
function StateResolver.prototype.____constructor(self, timeProvider, configService, jsonSerializer)
    self.timeProvider = timeProvider
    self.configService = configService
    self.jsonSerializer = jsonSerializer
end
__TS__DecorateLegacy(
    {
        __TS__DecorateParam(
            0,
            Inject(nil, TimeProvider)
        ),
        __TS__DecorateParam(
            1,
            Inject(nil, ConfigService)
        ),
        __TS__DecorateParam(
            2,
            Inject(nil, InjectionToken.JsonSerializer)
        )
    },
    StateResolver
)
function StateResolver.prototype.resolveState(self, provider)
    local resolvedStateEntries = __TS__ArrayMap(
        provider:getState():entries(),
        function(____, ____bindingPattern0)
            local state
            local key
            key = ____bindingPattern0[1]
            state = ____bindingPattern0[2]
            return {
                state,
                self:createStateHandle(key, state, provider)
            }
        end
    )
    return __TS__New(
        ProviderState,
        provider:getState(),
        __TS__New(Map, resolvedStateEntries),
        self:createDisplayStateHandle(provider)
    )
end
function StateResolver.prototype.createStateHandle(self, key, state, provider)
    return __TS__New(
        StateHandle,
        provider:getExtension(),
        state,
        key,
        __TS__New(
            StateEncoder,
            state.encoder or self.jsonSerializer,
            function() return state.initial() end
        ),
        self.configService
    )
end
function StateResolver.prototype.createDisplayStateHandle(self, provider)
    local state = provider:getState()
    if state == nil then
        return
    end
    local displayState = provider:getDisplaySettings():getDisplayState(state)
    if displayState == nil then
        return
    end
    local key = __TS__ArrayFind(
        __TS__ArrayMap(
            state:entries(),
            function(____, ____bindingPattern0)
                local key
                key = ____bindingPattern0[1]
                return key
            end
        ),
        function(____, key) return state:getByKey(key) == displayState end
    )
    if key == nil then
        error(
            __TS__New(
                ErrorWithContext,
                "Could not find a key for the provider display state.",
                {
                    addonId = provider:getExtension().addonId,
                    providerId = provider:getExtension().providerId
                }
            ),
            0
        )
    end
    return __TS__New(
        DisplayStateHandle,
        self.timeProvider,
        key,
        displayState,
        provider,
        __TS__New(
            StateEncoder,
            displayState.encoder or self.jsonSerializer,
            function() return displayState.initial() end
        ),
        self.configService
    )
end
StateResolver = __TS__DecorateLegacy(
    {Singleton(nil)},
    StateResolver
)
____exports.StateResolver = StateResolver
return ____exports
