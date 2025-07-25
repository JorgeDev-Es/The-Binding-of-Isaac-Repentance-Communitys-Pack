local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____ModConfigMenuFormattedOption = require("entities.menu.mcm.ModConfigMenuFormattedOption")
local ModConfigMenuFormattedOption = ____ModConfigMenuFormattedOption.ModConfigMenuFormattedOption
____exports.ModConfigMenuReadonlyValue = __TS__Class()
local ModConfigMenuReadonlyValue = ____exports.ModConfigMenuReadonlyValue
ModConfigMenuReadonlyValue.name = "ModConfigMenuReadonlyValue"
function ModConfigMenuReadonlyValue.prototype.____constructor(self, readonlyValue)
    self.readonlyValue = readonlyValue
end
function ModConfigMenuReadonlyValue.prototype.register(self, ctx)
    local option = __TS__New(ModConfigMenuFormattedOption, self.readonlyValue.name, self.readonlyValue.value or ____exports.ModConfigMenuReadonlyValue.FALLBACK_VALUE)
    ctx.modConfigMenu.AddText(
        ctx.category,
        ctx.subcategory,
        function() return option:getFormattedText() end
    )
end
ModConfigMenuReadonlyValue.FALLBACK_VALUE = "?"
return ____exports
