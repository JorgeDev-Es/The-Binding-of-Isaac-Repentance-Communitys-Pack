local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.CompanionConditionContext = __TS__Class()
local CompanionConditionContext = ____exports.CompanionConditionContext
CompanionConditionContext.name = "CompanionConditionContext"
function CompanionConditionContext.prototype.____constructor(self, id)
    self.id = id
    self.active = false
end
function CompanionConditionContext.prototype.isActive(self)
    return self.active
end
function CompanionConditionContext.prototype.setActive(self, active)
    self.active = active
end
return ____exports
