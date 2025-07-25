local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local ____exports = {}
____exports.ModConfigMenuSpace = __TS__Class()
local ModConfigMenuSpace = ____exports.ModConfigMenuSpace
ModConfigMenuSpace.name = "ModConfigMenuSpace"
function ModConfigMenuSpace.prototype.____constructor(self)
end
function ModConfigMenuSpace.prototype.register(self, ctx)
    ctx.modConfigMenu.AddSpace(ctx.category, ctx.subcategory)
end
return ____exports
