local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____ModConfigMenuFormattedText = require("entities.menu.mcm.ModConfigMenuFormattedText")
local ModConfigMenuFormattedText = ____ModConfigMenuFormattedText.ModConfigMenuFormattedText
local ____RGBColor = require("entities.renderer.RGBColor")
local RGBColor = ____RGBColor.RGBColor
____exports.ModConfigMenuSubheading = __TS__Class()
local ModConfigMenuSubheading = ____exports.ModConfigMenuSubheading
ModConfigMenuSubheading.name = "ModConfigMenuSubheading"
function ModConfigMenuSubheading.prototype.____constructor(self, subheading)
    self.subheading = subheading
end
function ModConfigMenuSubheading.prototype.register(self, ctx)
    local text = __TS__New(ModConfigMenuFormattedText, self.subheading.text, ____exports.ModConfigMenuSubheading.DECORATION)
    ctx.modConfigMenu.AddTitle(
        ctx.category,
        ctx.subcategory,
        text:getFormattedText(),
        ____exports.ModConfigMenuSubheading.COLOR:asArray()
    )
end
ModConfigMenuSubheading.DECORATION = "|||"
ModConfigMenuSubheading.COLOR = __TS__New(RGBColor, 0.1922, 0.0627, 0.2353)
return ____exports
