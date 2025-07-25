local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____ModConfigMenuFormattedOption = require("entities.menu.mcm.ModConfigMenuFormattedOption")
local ModConfigMenuFormattedOption = ____ModConfigMenuFormattedOption.ModConfigMenuFormattedOption
____exports.ModConfigMenuToggle = __TS__Class()
local ModConfigMenuToggle = ____exports.ModConfigMenuToggle
ModConfigMenuToggle.name = "ModConfigMenuToggle"
function ModConfigMenuToggle.prototype.____constructor(self, toggle)
    self.toggle = toggle
end
function ModConfigMenuToggle.prototype.register(self, ctx)
    local ____this_1
    ____this_1 = self.toggle
    local ____opt_0 = ____this_1.condition
    if (____opt_0 and ____opt_0(____this_1)) == false then
        return
    end
    ctx.modConfigMenu.AddSetting(
        ctx.category,
        ctx.subcategory,
        {
            Type = 4,
            Info = self.toggle.description,
            Display = function()
                local option = __TS__New(
                    ModConfigMenuFormattedOption,
                    self.toggle.name,
                    self.toggle:retrieve() == true and ____exports.ModConfigMenuToggle.TEXT_TRUE or ____exports.ModConfigMenuToggle.TEXT_FALSE
                )
                return option:getFormattedText()
            end,
            CurrentSetting = function()
                local ____temp_2 = self.toggle:retrieve()
                if ____temp_2 == nil then
                    ____temp_2 = false
                end
                return ____temp_2
            end,
            OnChange = function(value)
                self.toggle:update(value == true)
            end
        }
    )
end
ModConfigMenuToggle.TEXT_TRUE = "Yes"
ModConfigMenuToggle.TEXT_FALSE = "No"
return ____exports
