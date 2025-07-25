local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__Number = ____lualib.__TS__Number
local ____exports = {}
local ____common = require("lua_modules.@isaac-stats-plus.common.dist.index")
local toFixed = ____common.toFixed
local ____rescale = require("util.math.rescale")
local rescale = ____rescale.rescale
local ____ModConfigMenuFormattedOption = require("entities.menu.mcm.ModConfigMenuFormattedOption")
local ModConfigMenuFormattedOption = ____ModConfigMenuFormattedOption.ModConfigMenuFormattedOption
____exports.ModConfigMenuRange = __TS__Class()
local ModConfigMenuRange = ____exports.ModConfigMenuRange
ModConfigMenuRange.name = "ModConfigMenuRange"
function ModConfigMenuRange.prototype.____constructor(self, range)
    self.range = range
end
function ModConfigMenuRange.prototype.register(self, ctx)
    local ____this_1
    ____this_1 = self.range
    local ____opt_0 = ____this_1.condition
    if (____opt_0 and ____opt_0(____this_1)) == false then
        return
    end
    ctx.modConfigMenu.AddSetting(
        ctx.category,
        ctx.subcategory,
        {
            Type = 3,
            Info = self.range.description,
            Display = function()
                local format = self.range.format or (function(____, value) return tostring(value) end)
                local scrollValue = math.floor(rescale(
                    nil,
                    self:getRangeValue(),
                    {self.range.min, self.range.max},
                    {____exports.ModConfigMenuRange.MIN_VALUE, ____exports.ModConfigMenuRange.MAX_VALUE}
                ) + 0.5)
                local option = __TS__New(
                    ModConfigMenuFormattedOption,
                    self.range.name,
                    ((("$scroll" .. tostring(scrollValue)) .. " (") .. format(
                        nil,
                        self:getRangeValue()
                    )) .. ")"
                )
                return option:getFormattedText()
            end,
            CurrentSetting = function() return math.floor(rescale(
                nil,
                toFixed(
                    nil,
                    self:getRangeValue(),
                    ____exports.ModConfigMenuRange.MAX_PRECISION
                ),
                {self.range.min, self.range.max},
                {____exports.ModConfigMenuRange.MIN_VALUE, ____exports.ModConfigMenuRange.MAX_VALUE}
            ) + 0.5) end,
            OnChange = function(value) return self.range:update(toFixed(
                nil,
                rescale(
                    nil,
                    __TS__Number(value),
                    {____exports.ModConfigMenuRange.MIN_VALUE, ____exports.ModConfigMenuRange.MAX_VALUE},
                    {self.range.min, self.range.max}
                ),
                ____exports.ModConfigMenuRange.MAX_PRECISION
            )) end
        }
    )
end
function ModConfigMenuRange.prototype.getRangeValue(self)
    local value = self.range:retrieve()
    if value == nil then
        return (self.range.min + self.range.max) / 2
    end
    return value
end
ModConfigMenuRange.MIN_VALUE = 0
ModConfigMenuRange.MAX_VALUE = 10
ModConfigMenuRange.MAX_PRECISION = 2
return ____exports
