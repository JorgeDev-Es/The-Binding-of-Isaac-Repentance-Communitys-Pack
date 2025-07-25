local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____RGBAColor = require("entities.renderer.RGBAColor")
local RGBAColor = ____RGBAColor.RGBAColor
____exports.RGBColor = __TS__Class()
local RGBColor = ____exports.RGBColor
RGBColor.name = "RGBColor"
function RGBColor.prototype.____constructor(self, red, green, blue)
    self.red = red
    self.green = green
    self.blue = blue
end
function RGBColor.prototype.asArray(self)
    return {self.red, self.green, self.blue}
end
function RGBColor.prototype.asRGBA(self, opacity)
    return __TS__New(
        RGBAColor,
        self.red,
        self.green,
        self.blue,
        opacity
    )
end
return ____exports
