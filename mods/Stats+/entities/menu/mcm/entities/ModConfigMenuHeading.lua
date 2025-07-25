local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____ModConfigMenuFormattedText = require("entities.menu.mcm.ModConfigMenuFormattedText")
local ModConfigMenuFormattedText = ____ModConfigMenuFormattedText.ModConfigMenuFormattedText
local ____RGBColor = require("entities.renderer.RGBColor")
local RGBColor = ____RGBColor.RGBColor
____exports.ModConfigMenuHeading = __TS__Class()
local ModConfigMenuHeading = ____exports.ModConfigMenuHeading
ModConfigMenuHeading.name = "ModConfigMenuHeading"
function ModConfigMenuHeading.prototype.____constructor(self, heading)
    self.heading = heading
end
function ModConfigMenuHeading.prototype.register(self, ctx)
    local text = __TS__New(ModConfigMenuFormattedText, self.heading.text, ____exports.ModConfigMenuHeading.DECORATION)
    ctx.modConfigMenu.AddTitle(
        ctx.category,
        ctx.subcategory,
        text:getFormattedText(),
        ____exports.ModConfigMenuHeading.COLOR:asArray()
    )
end
ModConfigMenuHeading.DECORATION = "||||||||||"
ModConfigMenuHeading.COLOR = __TS__New(RGBColor, 0.0549, 0.0549, 0.2157)
return ____exports
