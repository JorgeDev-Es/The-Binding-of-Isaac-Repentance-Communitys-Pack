local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.ModConfigMenuResolvedSelectValue = __TS__Class()
local ModConfigMenuResolvedSelectValue = ____exports.ModConfigMenuResolvedSelectValue
ModConfigMenuResolvedSelectValue.name = "ModConfigMenuResolvedSelectValue"
function ModConfigMenuResolvedSelectValue.prototype.____constructor(self, select, valueToIndexMap)
    self.select = select
    self.valueToIndexMap = valueToIndexMap
    local index = self:getIndex()
    self.isUsingFallbackValue = index == nil or select.options[index + 1] == nil
    self.option = self.isUsingFallbackValue and select:fallback() or select.options[index + 1]
end
function ModConfigMenuResolvedSelectValue.prototype.getIndex(self)
    local value = self.select:retrieve()
    if value == nil then
        return nil
    end
    return self.valueToIndexMap:get(value)
end
return ____exports
