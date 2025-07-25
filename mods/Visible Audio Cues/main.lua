local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local Map = ____lualib.Map
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local ____exports = {}
local ____isaac_2Dtypescript_2Ddefinitions = require("lua_modules.isaac-typescript-definitions.dist.index")
local ModCallback = ____isaac_2Dtypescript_2Ddefinitions.ModCallback
local ____DogToothCrawlspaceCue = require("cues.DogToothCrawlspaceCue")
local DogToothCrawlspaceCue = ____DogToothCrawlspaceCue.DogToothCrawlspaceCue
local ____DogToothSecretRoomCue = require("cues.DogToothSecretRoomCue")
local DogToothSecretRoomCue = ____DogToothSecretRoomCue.DogToothSecretRoomCue
local ____MomsHandCue = require("cues.MomsHandCue")
local MomsHandCue = ____MomsHandCue.MomsHandCue
local ____Renderer = require("Renderer")
local Renderer = ____Renderer.Renderer
local mod = RegisterMod("visible-audio-cues", 1)
local cues = {
    __TS__New(DogToothCrawlspaceCue),
    __TS__New(DogToothSecretRoomCue),
    __TS__New(MomsHandCue)
}
local renderer = __TS__New(Renderer)
local cueRenderContexts = __TS__New(Map)
__TS__ArrayForEach(
    cues,
    function(____, cue)
        cue:register(
            mod,
            function()
                local frame = Game():GetFrameCount()
                local active = cue:evaluate()
                if active then
                    cue:getRenderer():reset()
                end
                cueRenderContexts:set(cue, {cue = cue, active = active, frame = frame})
            end
        )
    end
)
mod:AddCallback(
    ModCallback.POST_GAME_STARTED,
    function()
        cueRenderContexts:clear()
    end
)
mod:AddCallback(
    ModCallback.POST_RENDER,
    function()
        renderer:render(__TS__ArrayFrom(cueRenderContexts:values()))
    end
)
return ____exports
