local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local CollectibleType = ____isaac_2Dtypescript_2Ddefinitions.CollectibleType
local ModCallback = ____isaac_2Dtypescript_2Ddefinitions.ModCallback
local ____doesSomePlayerHaveItem = require("doesSomePlayerHaveItem")
local doesSomePlayerHaveItem = ____doesSomePlayerHaveItem.doesSomePlayerHaveItem
local ____CueTypeAnimationName = require("CueTypeAnimationName")
local CueTypeAnimationName = ____CueTypeAnimationName.CueTypeAnimationName
local ____CueAnimationName = require("CueAnimationName")
local CueAnimationName = ____CueAnimationName.CueAnimationName
local ____CueRenderer = require("CueRenderer")
local CueRenderer = ____CueRenderer.CueRenderer
local ____once = require("once")
local once = ____once.once
____exports.DogToothCrawlspaceCue = __TS__Class()
local DogToothCrawlspaceCue = ____exports.DogToothCrawlspaceCue
DogToothCrawlspaceCue.name = "DogToothCrawlspaceCue"
function DogToothCrawlspaceCue.prototype.____constructor(self)
    self.renderer = __TS__New(CueRenderer, CueTypeAnimationName.Info, CueAnimationName.DogToothCrawlspace)
end
function DogToothCrawlspaceCue.prototype.getRenderer(self)
    return self.renderer
end
function DogToothCrawlspaceCue.prototype.register(self, mod, trigger)
    mod:AddCallback(
        ModCallback.POST_UPDATE,
        once(nil, mod, trigger)
    )
    mod:AddCallback(ModCallback.POST_NEW_ROOM, trigger)
end
function DogToothCrawlspaceCue.prototype.evaluate(self)
    if not doesSomePlayerHaveItem(nil, CollectibleType.DOG_TOOTH) then
        return false
    end
    local room = Game():GetRoom()
    local dungeonRockIdx = room:GetDungeonRockIdx()
    if dungeonRockIdx == -1 then
        return false
    end
    local ____opt_0 = room:GetGridEntity(dungeonRockIdx)
    return (____opt_0 and ____opt_0:ToRock()) ~= nil
end
return ____exports
