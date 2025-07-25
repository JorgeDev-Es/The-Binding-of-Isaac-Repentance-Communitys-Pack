local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____ModConfigMenuToggle = require("entities.menu.mcm.entities.ModConfigMenuToggle")
local ModConfigMenuToggle = ____ModConfigMenuToggle.ModConfigMenuToggle
local ____ModConfigMenuReadonlyValue = require("entities.menu.mcm.entities.ModConfigMenuReadonlyValue")
local ModConfigMenuReadonlyValue = ____ModConfigMenuReadonlyValue.ModConfigMenuReadonlyValue
local ____ModConfigMenuSelect = require("entities.menu.mcm.entities.ModConfigMenuSelect")
local ModConfigMenuSelect = ____ModConfigMenuSelect.ModConfigMenuSelect
local ____ModConfigMenuRange = require("entities.menu.mcm.entities.ModConfigMenuRange")
local ModConfigMenuRange = ____ModConfigMenuRange.ModConfigMenuRange
local ____ModConfigMenuSubheading = require("entities.menu.mcm.entities.ModConfigMenuSubheading")
local ModConfigMenuSubheading = ____ModConfigMenuSubheading.ModConfigMenuSubheading
local ____ModConfigMenuHeading = require("entities.menu.mcm.entities.ModConfigMenuHeading")
local ModConfigMenuHeading = ____ModConfigMenuHeading.ModConfigMenuHeading
local ____ModConfigMenuSpace = require("entities.menu.mcm.entities.ModConfigMenuSpace")
local ModConfigMenuSpace = ____ModConfigMenuSpace.ModConfigMenuSpace
____exports.ModConfigMenu = __TS__Class()
local ModConfigMenu = ____exports.ModConfigMenu
ModConfigMenu.name = "ModConfigMenu"
function ModConfigMenu.prototype.____constructor(self, ctx)
    self.ctx = ctx
end
function ModConfigMenu.prototype.heading(self, heading)
    return self:register(__TS__New(ModConfigMenuHeading, heading))
end
function ModConfigMenu.prototype.subheading(self, subheading)
    return self:register(__TS__New(ModConfigMenuSubheading, subheading))
end
function ModConfigMenu.prototype.range(self, range)
    return self:register(__TS__New(ModConfigMenuRange, range))
end
function ModConfigMenu.prototype.select(self, select)
    return self:register(__TS__New(ModConfigMenuSelect, select))
end
function ModConfigMenu.prototype.readonly(self, readonlyValue)
    return self:register(__TS__New(ModConfigMenuReadonlyValue, readonlyValue))
end
function ModConfigMenu.prototype.toggle(self, toggle)
    return self:register(__TS__New(ModConfigMenuToggle, toggle))
end
function ModConfigMenu.prototype.space(self)
    return self:register(__TS__New(ModConfigMenuSpace))
end
function ModConfigMenu.prototype.register(self, entity)
    entity:register(self.ctx)
    return self
end
return ____exports
