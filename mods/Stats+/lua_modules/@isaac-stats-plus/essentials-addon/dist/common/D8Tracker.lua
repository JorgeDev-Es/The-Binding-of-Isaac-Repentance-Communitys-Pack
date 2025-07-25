local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__FunctionBind = ____lualib.__TS__FunctionBind
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local CollectibleType = ____isaac_2Dtypescript_2Ddefinitions.CollectibleType
local ModCallback = ____isaac_2Dtypescript_2Ddefinitions.ModCallback
____exports.D8Tracker = __TS__Class()
local D8Tracker = ____exports.D8Tracker
D8Tracker.name = "D8Tracker"
function D8Tracker.prototype.____constructor(self, api, mod, json, player, statType, multiplier, updateListener)
    self.api = api
    self.mod = mod
    self.json = json
    self.player = player
    self.statType = statType
    self.multiplier = multiplier
    self.updateListener = updateListener
    self.preUseListener = __TS__FunctionBind(self.onPreUse, self)
    self.postUseListener = __TS__FunctionBind(self.onPostUse, self)
    self.ignoreNextD8DueToD100Usage = false
    self.mod:AddCallback(ModCallback.PRE_USE_ITEM, self.preUseListener)
    self.mod:AddCallback(ModCallback.POST_USE_ITEM, self.postUseListener)
end
function D8Tracker.prototype.destroy(self)
    self.mod:RemoveCallback(ModCallback.PRE_USE_ITEM, self.preUseListener)
    self.mod:RemoveCallback(ModCallback.POST_USE_ITEM, self.postUseListener)
end
function D8Tracker.prototype.getMultiplier(self)
    return self.multiplier
end
function D8Tracker.prototype.onPreUse(self, collectible, rng, entityPlayer)
    do
        local function ____catch(e)
            Isaac.DebugString("Error during D8 tracker pre-use callback: " .. self.json.encode(e))
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            if self.player.Index ~= entityPlayer.Index then
                return true
            end
            if collectible == CollectibleType.D100 then
                self.ignoreNextD8DueToD100Usage = true
                return true
            end
            if collectible == CollectibleType.D8 and not self.ignoreNextD8DueToD100Usage then
                self.previousValue = self:getNumericStatValue(self.statType)
            end
        end)
        if not ____try then
            ____hasReturned, ____returnValue = ____catch(____hasReturned)
        end
        if ____hasReturned then
            return ____returnValue
        end
    end
end
function D8Tracker.prototype.onPostUse(self, collectible, rng, entityPlayer)
    do
        local function ____catch(e)
            Isaac.DebugString("Error during D8 tracker post-use callback: " .. self.json.encode(e))
        end
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            if collectible ~= CollectibleType.D8 or self.player.Index ~= entityPlayer.Index then
                return true
            end
            if self.ignoreNextD8DueToD100Usage then
                self.ignoreNextD8DueToD100Usage = false
                return true
            end
            if self.previousValue == nil then
                return true
            end
            self.multiplier = self.multiplier * (self:getNumericStatValue(self.statType) / self.previousValue)
            self:updateListener()
        end)
        if not ____try then
            ____hasReturned, ____returnValue = ____catch(____hasReturned)
        end
        if ____hasReturned then
            return ____returnValue
        end
    end
end
function D8Tracker.prototype.getNumericStatValue(self, stat)
    if self.api:compareExtensionRefs(stat, self.api.stat.speed) then
        return self.player.MoveSpeed
    end
    if self.api:compareExtensionRefs(stat, self.api.stat.tears) then
        return 1 / self.player.MaxFireDelay
    end
    if self.api:compareExtensionRefs(stat, self.api.stat.damage) then
        return self.player.Damage
    end
    if self.api:compareExtensionRefs(stat, self.api.stat.range) then
        return self.player.TearRange
    end
    error(
        __TS__New(Error, ((("Unsupported stat type for D8; addon: \"" .. stat.addon) .. "\", id: \"") .. stat.id) .. "\"."),
        0
    )
end
return ____exports
