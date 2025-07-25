local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local __TS__InstanceOf = ____lualib.__TS__InstanceOf
local __TS__ArrayFlatMap = ____lualib.__TS__ArrayFlatMap
local ____exports = {}
local ____StandaloneConditionExtension = require("entities.extension.condition.standalone.StandaloneConditionExtension")
local StandaloneConditionExtension = ____StandaloneConditionExtension.StandaloneConditionExtension
local ____HashSet = require("structures.HashSet")
local HashSet = ____HashSet.HashSet
local ____ErrorWithContext = require("errors.ErrorWithContext")
local ErrorWithContext = ____ErrorWithContext.ErrorWithContext
____exports.LoadoutConfig = __TS__Class()
local LoadoutConfig = ____exports.LoadoutConfig
LoadoutConfig.name = "LoadoutConfig"
function LoadoutConfig.prototype.____constructor(self, options)
    self.loadoutEntries = options.entries
end
function LoadoutConfig.prototype.clone(self)
    return __TS__New(
        ____exports.LoadoutConfig,
        {entries = self.loadoutEntries:clone()}
    )
end
function LoadoutConfig.prototype.getActiveStats(self)
    return __TS__ArrayFrom(self.loadoutEntries:keys())
end
function LoadoutConfig.prototype.getPrimaryProvider(self, stat)
    return self:getLoadoutEntry(stat):getPrimaryProvider()
end
function LoadoutConfig.prototype.getSecondaryProvider(self, stat)
    return self:getLoadoutEntry(stat):getSecondaryProvider()
end
function LoadoutConfig.prototype.getCondition(self, stat)
    return self:getLoadoutEntry(stat):getCondition()
end
function LoadoutConfig.prototype.setPrimaryProvider(self, stat, primaryProvider)
    self:getLoadoutEntry(stat):setPrimaryProvider(primaryProvider)
end
function LoadoutConfig.prototype.setSecondaryProvider(self, stat, secondaryProvider)
    self:getLoadoutEntry(stat):setSecondaryProvider(secondaryProvider)
end
function LoadoutConfig.prototype.setCondition(self, stat, condition)
    self:getLoadoutEntry(stat):setCondition(condition)
end
function LoadoutConfig.prototype.getLoadoutEntry(self, stat)
    local entry = self.loadoutEntries:get(stat)
    if entry == nil then
        error(
            __TS__New(ErrorWithContext, "Could not find entry for the given stat.", {addonId = stat.addonId, statId = stat.statId}),
            0
        )
    end
    return entry
end
function LoadoutConfig.prototype.getCurrentlyUsedProviders(self)
    local providers = __TS__New(
        HashSet,
        __TS__ArrayFlatMap(
            __TS__ArrayFrom(self.loadoutEntries:values()),
            function(____, entry)
                local condition = entry:getCondition()
                if __TS__InstanceOf(condition, StandaloneConditionExtension) and condition:isAlwaysCondition() then
                    return {entry:getPrimaryProvider()}
                end
                return {
                    entry:getPrimaryProvider(),
                    entry:getSecondaryProvider()
                }
            end
        )
    )
    return __TS__ArrayFrom(providers:values())
end
return ____exports
