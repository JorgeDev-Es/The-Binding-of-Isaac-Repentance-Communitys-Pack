local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
____exports.RGBAColor = __TS__Class()
local RGBAColor = ____exports.RGBAColor
RGBAColor.name = "RGBAColor"
function RGBAColor.prototype.____constructor(self, red, green, blue, alpha)
    self.red = red
    self.green = green
    self.blue = blue
    self.alpha = alpha
end
function RGBAColor.fromArray(self, rgba)
    local r, g, b, a = table.unpack(rgba)
    return __TS__New(
        ____exports.RGBAColor,
        r,
        g,
        b,
        a
    )
end
function RGBAColor.prototype.asArray(self)
    return {self.red, self.green, self.blue, self.alpha}
end
function RGBAColor.prototype.withAlpha(self, alpha)
    return __TS__New(
        ____exports.RGBAColor,
        self.red,
        self.green,
        self.blue,
        alpha
    )
end
return ____exports
