local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____StatExtension = require("entities.extension.stat.StatExtension")
local StatExtension = ____StatExtension.StatExtension
local ____coreAddonConstants = require("core.coreAddonConstants")
local CORE_ADDON_ID = ____coreAddonConstants.CORE_ADDON_ID
____exports.luck = __TS__New(StatExtension, {addon = CORE_ADDON_ID, id = "luck-stat"})
return ____exports
