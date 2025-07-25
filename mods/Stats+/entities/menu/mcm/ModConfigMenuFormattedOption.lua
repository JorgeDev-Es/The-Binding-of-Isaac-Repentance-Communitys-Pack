local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____ModConfigMenuFormattedText = require("entities.menu.mcm.ModConfigMenuFormattedText")
local ModConfigMenuFormattedText = ____ModConfigMenuFormattedText.ModConfigMenuFormattedText
____exports.ModConfigMenuFormattedOption = __TS__Class()
local ModConfigMenuFormattedOption = ____exports.ModConfigMenuFormattedOption
ModConfigMenuFormattedOption.name = "ModConfigMenuFormattedOption"
function ModConfigMenuFormattedOption.prototype.____constructor(self, name, option, decoration)
    self.name = name
    self.option = option
    self.decoration = decoration
    self.formattedText = __TS__New(ModConfigMenuFormattedText, (self.name .. ": ") .. self.option, self.decoration)
end
function ModConfigMenuFormattedOption.prototype.getFormattedText(self)
    return self.formattedText:getFormattedText()
end
return ____exports
