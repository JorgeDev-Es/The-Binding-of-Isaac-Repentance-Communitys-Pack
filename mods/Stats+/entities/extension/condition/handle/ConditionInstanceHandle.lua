local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
local ____Time = require("entities.Time")
local Time = ____Time.Time
____exports.ConditionInstanceHandle = __TS__Class()
local ConditionInstanceHandle = ____exports.ConditionInstanceHandle
ConditionInstanceHandle.name = "ConditionInstanceHandle"
function ConditionInstanceHandle.prototype.____constructor(self, timeProvider, context)
    self.timeProvider = timeProvider
    self.context = context
    self.active = false
    self.lastChange = Time:never()
    self.cleanup = self.context.condition:mount(
        self.context.providers,
        self:getExternalAPI()
    )
end
function ConditionInstanceHandle.prototype.unregister(self)
    local ____opt_0 = self.cleanup
    if ____opt_0 ~= nil then
        ____opt_0()
    end
end
function ConditionInstanceHandle.prototype.isActive(self)
    return self.active
end
function ConditionInstanceHandle.prototype.getLastChange(self)
    return self.lastChange
end
function ConditionInstanceHandle.prototype.getExternalAPI(self)
    return {
        player = self.context.player.entityPlayer,
        playerIndex = self.context.player.index,
        stat = self.context.stat:getExternalAPI(),
        isActive = function() return self:isActive() end,
        setActive = function(____, active)
            if active == self:isActive() then
                return
            end
            self.active = active
            self.lastChange = self.timeProvider:getLastRenderTime()
        end
    }
end
return ____exports
