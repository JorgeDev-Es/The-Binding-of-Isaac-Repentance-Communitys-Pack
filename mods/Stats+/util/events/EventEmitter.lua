local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Map = ____lualib.Map
local __TS__New = ____lualib.__TS__New
local __TS__Spread = ____lualib.__TS__Spread
local Set = ____lualib.Set
local ____exports = {}
____exports.EventEmitter = __TS__Class()
local EventEmitter = ____exports.EventEmitter
EventEmitter.name = "EventEmitter"
function EventEmitter.prototype.____constructor(self)
    self.subscriptions = __TS__New(Map)
end
function EventEmitter.prototype.broadcast(self, event, ...)
    local args = {...}
    local ____opt_0 = self.subscriptions:get(event)
    if ____opt_0 ~= nil then
        ____opt_0:forEach(function(____, notify) return notify(
            nil,
            __TS__Spread(args)
        ) end)
    end
end
function EventEmitter.prototype.subscribe(self, event, notify)
    local subscription = {
        notify = notify,
        event = event,
        unsubscribe = function() return self:unsubscribe(event, notify) end
    }
    local subscriptions = self.subscriptions:get(event) or __TS__New(Set)
    subscriptions:add(notify)
    self.subscriptions:set(event, subscriptions)
    return subscription
end
function EventEmitter.prototype.unsubscribe(self, event, notify)
    local ____opt_2 = self.subscriptions:get(event)
    if ____opt_2 ~= nil then
        ____opt_2:delete(notify)
    end
end
function EventEmitter.prototype.unsubscribeAll(self, event)
    local ____opt_4 = self.subscriptions:get(event)
    if ____opt_4 ~= nil then
        ____opt_4:clear()
    end
end
function EventEmitter.prototype.asClient(self)
    return self
end
return ____exports
