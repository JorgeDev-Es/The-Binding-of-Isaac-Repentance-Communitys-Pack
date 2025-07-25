local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__StringSlice = ____lualib.__TS__StringSlice
local ____exports = {}
____exports.ModConfigMenuFormattedText = __TS__Class()
local ModConfigMenuFormattedText = ____exports.ModConfigMenuFormattedText
ModConfigMenuFormattedText.name = "ModConfigMenuFormattedText"
function ModConfigMenuFormattedText.prototype.____constructor(self, text, decoration)
    self.text = text
    self.decoration = decoration
end
function ModConfigMenuFormattedText.getTextFormatted(self, text, decoration)
    return decoration == nil and text or (((decoration .. "  ") .. text) .. "  ") .. decoration
end
function ModConfigMenuFormattedText.trimText(self, text, maxLength)
    if maxLength > #text then
        return text
    end
    local trimmed = __TS__StringSlice(text, 0, maxLength - #____exports.ModConfigMenuFormattedText.MESSAGE_ELLIPSIS)
    return trimmed .. ____exports.ModConfigMenuFormattedText.MESSAGE_ELLIPSIS
end
function ModConfigMenuFormattedText.prototype.getFormattedText(self)
    return ____exports.ModConfigMenuFormattedText:getTextFormatted(
        ____exports.ModConfigMenuFormattedText:trimText(self.text, ____exports.ModConfigMenuFormattedText.MESSAGE_MAX_LENGTH),
        self.decoration
    )
end
ModConfigMenuFormattedText.MESSAGE_MAX_LENGTH = 40
ModConfigMenuFormattedText.MESSAGE_ELLIPSIS = "..."
return ____exports
