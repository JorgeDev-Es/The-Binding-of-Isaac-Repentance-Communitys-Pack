local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ObjectValues = ____lualib.__TS__ObjectValues
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__ObjectFromEntries = ____lualib.__TS__ObjectFromEntries
local ____exports = {}
____exports.ResolvedCompanionConditions = __TS__Class()
local ResolvedCompanionConditions = ____exports.ResolvedCompanionConditions
ResolvedCompanionConditions.name = "ResolvedCompanionConditions"
function ResolvedCompanionConditions.prototype.____constructor(self, byKey)
    self.byKey = byKey
    self.byId = __TS__ObjectFromEntries(__TS__ArrayMap(
        __TS__ObjectValues(self.byKey),
        function(____, def) return {def.id, def} end
    ))
end
function ResolvedCompanionConditions.prototype.getExternalAPI(self)
    return self.byKey
end
function ResolvedCompanionConditions.prototype.isActive(self, companionConditionIdentifier)
    local ____opt_0 = self.byId[companionConditionIdentifier]
    local ____temp_2 = ____opt_0 and ____opt_0:isActive()
    if ____temp_2 == nil then
        ____temp_2 = false
    end
    return ____temp_2
end
return ____exports
