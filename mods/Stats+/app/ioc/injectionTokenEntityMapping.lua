local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local json = require("json")
local ____InjectionToken = require("app.ioc.InjectionToken")
local InjectionToken = ____InjectionToken.InjectionToken
local ____singleton = require("app.ioc.resolution.singleton")
local singleton = ____singleton.singleton
local ____createMod = require("app.createMod")
local createMod = ____createMod.createMod
local ____IngameValue = require("services.IngameValue")
local IngameValue = ____IngameValue.IngameValue
local ____ModCallbackService = require("services.ModCallbackService")
local ModCallbackService = ____ModCallbackService.ModCallbackService
local jsonSerializerAdapter = {
    encode = function(self, decoded)
        return json.encode(decoded)
    end,
    decode = function(self, encoded)
        return json.decode(encoded)
    end
}
____exports.injectionTokenEntityMapping = {
    [InjectionToken.ModConfigMenu] = singleton(
        nil,
        function(____, container) return __TS__New(
            IngameValue,
            container:resolve(ModCallbackService),
            function() return ModConfigMenu end
        ) end
    ),
    [InjectionToken.IsaacAPI] = singleton(
        nil,
        function() return Isaac end
    ),
    [InjectionToken.GameAPI] = singleton(
        nil,
        function() return Game() end
    ),
    [InjectionToken.ModAPI] = singleton(
        nil,
        function() return createMod(nil) end
    ),
    [InjectionToken.OptionsAPI] = singleton(
        nil,
        function() return Options end
    ),
    [InjectionToken.JsonSerializer] = singleton(
        nil,
        function() return jsonSerializerAdapter end
    )
}
return ____exports
