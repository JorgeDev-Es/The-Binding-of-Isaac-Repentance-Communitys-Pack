local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__New = ____lualib.__TS__New
local __TS__ArraySome = ____lualib.__TS__ArraySome
local Set = ____lualib.Set
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local EntityType = ____isaac_2Dtypescript_2Ddefinitions.EntityType
local ModCallback = ____isaac_2Dtypescript_2Ddefinitions.ModCallback
local ____CueTypeAnimationName = require("CueTypeAnimationName")
local CueTypeAnimationName = ____CueTypeAnimationName.CueTypeAnimationName
local ____CueAnimationName = require("CueAnimationName")
local CueAnimationName = ____CueAnimationName.CueAnimationName
local ____CueRenderer = require("CueRenderer")
local CueRenderer = ____CueRenderer.CueRenderer
local ____once = require("once")
local once = ____once.once
____exports.MomsHandCue = __TS__Class()
local MomsHandCue = ____exports.MomsHandCue
MomsHandCue.name = "MomsHandCue"
function MomsHandCue.prototype.____constructor(self)
    self.renderer = __TS__New(CueRenderer, CueTypeAnimationName.Danger, CueAnimationName.MomsHand)
end
function MomsHandCue.prototype.getRenderer(self)
    return self.renderer
end
function MomsHandCue.prototype.register(self, mod, trigger)
    mod:AddCallback(
        ModCallback.POST_UPDATE,
        once(nil, mod, trigger)
    )
    mod:AddCallback(ModCallback.POST_NEW_ROOM, trigger)
    mod:AddCallback(
        ModCallback.PRE_ENTITY_SPAWN,
        function(____, entityType)
            if ____exports.MomsHandCue.MOMS_HAND_ENTITY_TYPES:has(entityType) then
                trigger(nil)
            end
            return nil
        end
    )
end
function MomsHandCue.prototype.evaluate(self)
    return __TS__ArraySome(
        Isaac.GetRoomEntities(),
        function(____, entity) return ____exports.MomsHandCue.MOMS_HAND_ENTITY_TYPES:has(entity.Type) end
    )
end
MomsHandCue.MOMS_HAND_ENTITY_TYPES = __TS__New(Set, {EntityType.MOMS_HAND, EntityType.MOMS_DEAD_HAND})
return ____exports
