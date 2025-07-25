local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local ____exports = {}
____exports.Renderer = __TS__Class()
local Renderer = ____exports.Renderer
Renderer.name = "Renderer"
function Renderer.prototype.____constructor(self)
end
function Renderer.prototype.reset(self, cues)
    __TS__ArrayForEach(
        cues,
        function(____, cue)
            cue:getRenderer():reset()
        end
    )
end
function Renderer.prototype.render(self, ctxs)
    local hudOffsetX = Options.HUDOffset * ____exports.Renderer.HUD_OFFSET_X_MULTIPLIER
    local hudOffsetY = Options.HUDOffset * ____exports.Renderer.HUD_OFFSET_Y_MULTIPLIER
    __TS__ArrayForEach(
        __TS__ArrayFilter(
            ctxs,
            function(____, ctx) return ctx.active end
        ),
        function(____, ctx, idx)
            ctx.cue:getRenderer():render(
                Isaac.GetScreenWidth() + Game().ScreenShakeOffset.X - hudOffsetX - ____exports.Renderer.SCREEN_OFFSET,
                Isaac.GetScreenHeight() + Game().ScreenShakeOffset.Y - hudOffsetY - ____exports.Renderer.SCREEN_OFFSET - ____exports.Renderer.ROW_GAP * idx,
                ctx.frame
            )
        end
    )
end
Renderer.HUD_OFFSET_X_MULTIPLIER = 20
Renderer.HUD_OFFSET_Y_MULTIPLIER = 12
Renderer.SCREEN_OFFSET = 48
Renderer.ROW_GAP = 24
return ____exports
