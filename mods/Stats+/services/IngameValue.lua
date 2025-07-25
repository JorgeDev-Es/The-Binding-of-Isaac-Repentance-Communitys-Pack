local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__FunctionBind = ____lualib.__TS__FunctionBind
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local ModCallback = ____isaac_2Dtypescript_2Ddefinitions.ModCallback
local ____EventEmitter = require("util.events.EventEmitter")
local EventEmitter = ____EventEmitter.EventEmitter
____exports.IngameValue = __TS__Class()
local IngameValue = ____exports.IngameValue
IngameValue.name = "IngameValue"
function IngameValue.prototype.____constructor(self, modCallbackService, getter)
    self.modCallbackService = modCallbackService
    self.getter = getter
    self.subject = __TS__New(EventEmitter)
    self.listener = __TS__FunctionBind(self.onPostUpdate, self)
    self.ready = false
    self.modCallbackService:addCallback(ModCallback.POST_UPDATE, self.listener)
end
function IngameValue.prototype.get(self, callback)
    if self.ready then
        callback(nil, self.value)
        return
    end
    self.subject:subscribe(
        "ready",
        function() return callback(nil, self.value) end
    )
end
function IngameValue.prototype.onPostUpdate(self)
    self.value = self:getter()
    self.ready = true
    self.subject:unsubscribeAll("ready")
    self.modCallbackService:removeCallback(ModCallback.POST_UPDATE, self.listener)
    self.subject:broadcast("ready")
end
return ____exports
