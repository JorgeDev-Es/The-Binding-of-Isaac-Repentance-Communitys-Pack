local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__New = ____lualib.__TS__New
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local Map = ____lualib.Map
local __TS__Number = ____lualib.__TS__Number
local ____exports = {}
local ____HashMap = require("structures.HashMap")
local HashMap = ____HashMap.HashMap
local ____ModConfigMenuResolvedSelectValue = require("entities.menu.ModConfigMenuResolvedSelectValue")
local ModConfigMenuResolvedSelectValue = ____ModConfigMenuResolvedSelectValue.ModConfigMenuResolvedSelectValue
local ____StructuralComparator = require("services.StructuralComparator")
local StructuralComparator = ____StructuralComparator.StructuralComparator
local ____ModConfigMenuFormattedOption = require("entities.menu.mcm.ModConfigMenuFormattedOption")
local ModConfigMenuFormattedOption = ____ModConfigMenuFormattedOption.ModConfigMenuFormattedOption
local ____RGBColor = require("entities.renderer.RGBColor")
local RGBColor = ____RGBColor.RGBColor
____exports.ModConfigMenuSelect = __TS__Class()
local ModConfigMenuSelect = ____exports.ModConfigMenuSelect
ModConfigMenuSelect.name = "ModConfigMenuSelect"
function ModConfigMenuSelect.prototype.____constructor(self, select)
    self.select = select
    self.structuralComparator = __TS__New(StructuralComparator)
    if #self.select.options == 0 then
        error(
            __TS__New(Error, "ModConfigMenuSelect requires at least one option,  yet none were provided."),
            0
        )
    end
    self.valueToIndexMap = __TS__New(
        HashMap,
        __TS__ArrayMap(
            self.select.options,
            function(____, option, idx) return {
                option:getValue(),
                idx
            } end
        )
    )
    self.indexToValueMap = __TS__New(
        Map,
        __TS__ArrayMap(
            self.select.options,
            function(____, option, idx) return {
                idx,
                option:getValue()
            } end
        )
    )
end
function ModConfigMenuSelect.prototype.register(self, ctx)
    local ____this_1
    ____this_1 = self.select
    local ____opt_0 = ____this_1.condition
    if (____opt_0 and ____opt_0(____this_1)) == false then
        return
    end
    local value = __TS__New(ModConfigMenuResolvedSelectValue, self.select, self.valueToIndexMap)
    ctx.modConfigMenu.AddSetting(
        ctx.category,
        ctx.subcategory,
        {
            Type = 5,
            Info = self.select.description,
            Minimum = 0,
            Maximum = self.valueToIndexMap.size - 1,
            Display = function()
                local option = __TS__New(
                    ModConfigMenuFormattedOption,
                    self.select.name,
                    value.option:getName()
                )
                return option:getFormattedText()
            end,
            Color = value.isUsingFallbackValue and ____exports.ModConfigMenuSelect.FALLBACK_VALUE_COLOR:asArray() or nil,
            CurrentSetting = function()
                local index = self.valueToIndexMap:get(self.select:retrieve()) or 0
                if self.select.options[index + 1] == nil then
                    error(
                        __TS__New(Error, "No matching index found for an option returned by .retrieve()."),
                        0
                    )
                end
                return index
            end,
            OnChange = function(value)
                local ____temp_2 = self.indexToValueMap:get(__TS__Number(value))
                if ____temp_2 == nil then
                    ____temp_2 = self.select.options[1]:getValue()
                end
                local newValue = ____temp_2
                if self.structuralComparator:compare(
                    self.select:retrieve(),
                    newValue
                ) then
                    return
                end
                self.select:update(newValue)
            end
        }
    )
end
ModConfigMenuSelect.FALLBACK_VALUE_COLOR = __TS__New(RGBColor, 0.35294, 0.11765, 0.04706)
return ____exports
